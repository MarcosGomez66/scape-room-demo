# scape-room

Demo 3D de escape room en primera persona, **Godot 4.7** (GDScript, Forward+).
`GDD.md` es la fuente de verdad del diseño (en español): 3 puzles con progresión por
llaves a través de 5 habitaciones + exterior. Documentación y conversación en español;
identificadores y comentarios de código en inglés.

## MCP de Godot: cómo está conectado

El proyecto se opera a través del plugin **Godot MCP Toolkit**
(`addons/godot_mcp_toolkit`, activo en `project.godot`). Gotchas que importan:

- **OpenCode NO lee `.mcp.json`.** Ese archivo de la raíz es el formato de Claude
  Code/Cursor/Windsurf. El server de OpenCode vive en `opencode.json`, bajo
  `mcp.servers` (ahí se fija `@npgamedev/godot-mcp-server@1.1.2` para que coincida con
  la versión del plugin). Si las herramientas MCP no aparecen, revisá ese archivo primero.
- **El editor Godot tiene que estar abierto** con el plugin activo: el server se
  conecta por WebSocket al editor. Verificá con `cmd /c "opencode mcp list"` →
  `✓ godot-mcp-toolkit connected`.
- No hay `godot` en el PATH. El binario está en
  `C:\Users\marco\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
- Con **Code Mode** (default de OpenCode) las herramientas se llaman desde `execute`,
  como `tools["godot-mcp-toolkit"].<tool>({...})`. La superficie arranca reducida:
  usá `discover_tools` para activar más grupos.
- El server resuelve el proyecto por el **working directory**, por eso se lanza con
  `cwd` en la raíz del proyecto.

### Reglas al editar con el editor

- **No edites a mano un `.tscn` existente.** Usá `scene_create`, `scene_create_node`,
  `node_set_property`, `node_set_script` y **guardá con `editor_save_scene`** (no se
  guarda solo).
- Escribí/editá `.gd` con `script_write` / `script_edit`: compilan y quedan registrados
  en el editor vivo. `script_check` valida un archivo suelto;
  `lsp_project_diagnostics` valida todo el proyecto.
- Referencia completa de flujo:
  `addons/godot_mcp_toolkit/CompanionSkills/godot-mcp-toolkit/SKILL.md`.

## PowerShell en Windows

La ExecutionPolicy bloquea los shims `.ps1`: `opencode`, `npx` y `npm` fallan si se
invocan directo desde PowerShell. Usá `cmd /c "opencode ..."` (o la variante `.cmd`).

## Jugador

`scenes/player/Player.tscn` + `scripts/player/player.gd` (`class_name PlayerController`)
son un **controlador propio mínimo, sin FSM**: WASD para caminar, mantener Shift para
correr, mouse para mirar, Escape libera/recaptura el mouse. Sin salto, agacharse, slide,
dash ni vuelo.

- Acciones de input definidas en `project.godot` (physical keycodes): `move_forward`,
  `move_backward`, `move_left`, `move_right`, `run`, `toggle_mouse`, `interact` (E) y
  `slot_1` / `slot_2` / `slot_3` (1, 2 y 3 de la fila superior).
- Capas de física (con nombre en `project.godot`): 1 = `world`, 2 = `player`,
  4 = `interactable`. El jugador no se ve a sí mismo y el raycast de interacción usa
  máscara 9 (world + interactable), así que lo ignora.
- HUD (`scripts/ui/hud.gd`, `class_name Hud`): mira (`assets/player/crosshair.png`; ver
  `THIRD_PARTY.md`), prompt de interacción debajo de la mira, panel de mensajes temporal,
  barra de 3 slots de inventario abajo al centro y contador de fallos (`StrikeLabel`,
  arriba a la derecha, formato `Fallos: X - -`).
- `scenes/test/house_test_level.tscn` es el nivel jugable actual
  (`application/run/main_scene`); `scenes/test/test_level.tscn` es el nivel plano viejo.

## Interacción, puertas e inventario

- **Base:** `scripts/interactables/interactable.gd` (`class_name Interactable extends
  StaticBody3D`). Expone `prompt_text`, `enabled`, `get_prompt()` e `interact() -> String`
  (el string es el mensaje para el HUD). Los interactuables que no deben bloquear el paso
  usan solo la capa 4; los sólidos, 1 + 4 (valor 9).
- **Raycast:** `Player/CameraHolder/Camera/InteractionRay` (`RayCast3D`, 2.2 m, máscara 9,
  `scripts/player/interaction_ray.gd`) actualiza el prompt cada frame y con E llama a
  `interact()` del objetivo.
- **Inventario:** autoload `Inventory` (`scripts/managers/inventory.gd`): 3 slots fijos,
  `selected_slot`, señales `slots_changed` / `selection_changed`. `add_item` autoselecciona
  el slot nuevo; `remove_item` se usa para consumir la llave. Los objetos son
  `ItemData` (`scripts/inventory/item_data.gd`); la llave del dormitorio vive en
  `resources/items/key_bedroom.tres`.
- **Puerta:** `scenes/interactables/Door.tscn` + `scripts/interactables/door.gd`
  (`class_name Door`). Usa `SM_Puerta.glb`: el marco queda fijo y `_ready` reparenta
  `SM_Hoja` + `SM_Pomo` bajo `Hinge`. **El `CollisionShape3D` de la hoja es hijo directo
  del `StaticBody3D`** (Godot no registra shapes colgadas de un `Node3D` intermedio) y el
  tween lo rota junto con la bisagra. Exportados: `required_item_id`, `locked`,
  `open_angle_degrees`, `open_time`, `is_open`.
- **Llave:** `scenes/collectibles/Key.tscn` + `scripts/collectibles/key.gd`
  (`class_name KeyPickup`), capa 4 con luz de acento para que se vea en la casa nocturna.

## Puzle del dormitorio: estado de partida y UI modal

Tres autoloads (registrados en `project.godot`) sostienen el puzle:

- **`PuzzleManager`** (`scripts/managers/puzzle_manager.gd`): paleta de 5 colores
  (`COLORS`: id, nombre, pista y textura) y datos generados. `picture_colors` son los 3
  colores distintos que cuelgan en los cuadros; `sequence` es un reordenamiento
  aleatorio independiente de esos mismos 3 colores y es la combinación de la caja.
  `safe_solved` + señal `safe_solved_changed`; helpers `color_data`, `texture_for`,
  `clue_for`, `check_answer`, `mark_solved` y `generate()`. Las 5 imágenes viven en
  `assets/test/img/` (`orquidea_magenta`, `taxi_amarillo`, `globo_azul`,
  `telefono_rojo`, `cactus_verde`), todas de 1200×896.
- **`GameManager`** (`scripts/managers/game_manager.gd`): `MAX_STRIKES = 3`, `strikes`,
  `is_game_over`, señales `strikes_changed(strikes)` / `game_over`. `add_strike()` y
  `restart_game()`, que resetea fallos, llama `Inventory.clear()` y
  `PuzzleManager.generate()`, cierra la UI, despausa y recarga la escena actual.
- **`PuzzleUI`** (`scripts/ui/puzzle_ui.gd`): `CanvasLayer` con `layer = 100` y
  `PROCESS_MODE_ALWAYS`; instancia `scenes/ui/safe_window.tscn`,
  `scenes/ui/note_window.tscn` y `scenes/ui/game_over_window.tscn`. Cualquier
  interactuable llama `PuzzleUI.open_safe()` / `open_note()`; mientras hay un modal
  abierto pausa el árbol y muestra el mouse. Escape (`toggle_mouse`) y el botón Cerrar
  vuelven al juego.

Ventanas:

- **Caja fuerte** (`scripts/ui/safe_window.gd`): fila de 5 foquitos (uno por botón) y
  fila de 5 botones circulares en orden **magenta, amarillo, azul, rojo, verde**.
  Máximo 3 pulsaciones; un botón ya pulsado no se puede repetir en el mismo intento.
  3 aciertos → `mark_solved()` y cierre; 3 fallos → strike, se limpia el intento tras
  1 s. Con 3 strikes totales se dispara el game over y se bloquea el puzle.
- **Nota** (`scripts/ui/note_window.gd`): fondo tipo papel con 3 labels en el orden
  exacto de la solución, formato `1. <pista>`; la pista nunca nombra el objeto ni el
  color.
- **Game over** (`scripts/ui/game_over_window.gd`): overlay a pantalla completa con
  botón Reiniciar (`GameManager.restart_game()`), que genera una combinación nueva.

### Muebles e interactuables del puzle

- **Ropero** (`scenes/environment/furniture/Wardrobe.tscn`, root `StaticBody3D` con
  `scripts/environment/wardrobe.gd`): colisiones huecas (fondo, laterales, techo, base,
  estante y divisor) y `KeySpawn` (`Marker3D`) para la llave. `LeftDoor`
  (`scripts/interactables/wardrobe_door.gd`) abre una sola vez a −90° y se deshabilita;
  `SafeDoor` (`scripts/interactables/safe_door.gd`) abre la ventana del puzle y, al
  resolverse, gira +90° y se deshabilita. Ambas usan el **origen del `StaticBody3D` como
  bisagra** (`reparent(self, true)` de la hoja) para que mesh y colisión giren juntos,
  sin nodo `Hinge`; el `SafeDoor` reparenta además los cinco `SM_Boton*`, que en el GLB
  son piezas sueltas sobre la hoja. La puerta de la caja anima con
  `Tween.TWEEN_PAUSE_PROCESS`, porque la ventana tiene el árbol pausado.
- **Escritorio** (`scenes/environment/furniture/Desk.tscn`): `Drawer`
  (`scripts/interactables/desk_drawer.gd`) extrae el cajón 0.3 m (reparenta las piezas
  del GLB), y al terminar habilita `Drawer/Note` (`scripts/interactables/note_item.gd`),
  que arranca con capa 0, `enabled = false` e invisible. Dentro hay un `Paper` blanco.
- **Cuadros** (`scenes/environment/props/PictureFrame.tscn` +
  `scripts/environment/picture_frame.gd`): `picture_slot`, `picture_color` y
  `texture_override` permiten fijar la imagen al instanciar; por defecto toman
  `PuzzleManager.picture_colors[slot]` y aplican la textura como `material_override`
  unshaded sobre `Model/SM_Img`. El GLB exporta la placa con UV de atlas recortadas y
  ejes intercambiados (se veía un cuadrante girado 90°), así que el script le reemplaza
  el mesh por un `QuadMesh` de 0.40×0.30 en `z = 0.002` con UV 0–1.

Gotchas del GLB: los nodos importados reemplazan puntos por guiones bajos
(`SM_Frente_001`, `SM_Boton_001`). Todo `CollisionShape3D` va como hijo directo del
`CollisionObject3D`.

### Prueba jugable del dormitorio

En `house_test_level.tscn`: el jugador arranca encerrado en el dormitorio mirando la
puerta (`BedroomDoor`, bloqueada). No hay llave en el piso: el flujo es abrir la puerta
izquierda del ropero (`Wardrobe`) → interactuar con la caja fuerte → resolver la
combinación de 3 colores → la puerta de la caja se abre y aparece la llave en
`KeySpawn` → recogerla (queda en el slot 1) → E en `BedroomDoor` la consume y la abre
hacia el dormitorio. La nota del cajón (`Desk/Drawer/Note`) da el orden
correcto; los 3 cuadros indican qué color corresponde a cada pista. Tres intentos
fallidos en la caja terminan la partida y el botón Reiniciar relanza la escena con una
combinación nueva.

El nivel coloca `Wardrobe` en `(-3.05, 0.30, -3.86)`, `Desk` en
`(-1.65, 0.30, -3.86)` y los cuadros `PictureFrameLeft/Center/Right` en
`x = -3.0 / -2.25 / -1.5`, `y = 1.55`, `z = -1.17`, rotados 180° en Y, con slots 0/1/2.

## Assets de terceros

`assets/player/crosshair.png` es lo único que queda de un addon de terceros: viene de
**JehenoAdvancedFirstPersonController** (MIT, © 2024 Jeh3no). El addon se eliminó por
completo del proyecto; la atribución vive en `THIRD_PARTY.md`.

## Ajustes del motor

`project.godot`: Godot 4.7, Forward+, **Jolt Physics**, driver **D3D12** en Windows,
stretch `canvas_items` / `expand`. `.godot/` está ignorado por git.
