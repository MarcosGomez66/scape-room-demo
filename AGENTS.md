# scape-room

Demo 3D de escape room en primera persona, **Godot 4.7** (GDScript, Forward+).
`GDD.md` es la fuente de verdad del diseño (en español): 3 puzles con progresión por
llaves a través de 5 habitaciones + exterior. `NOTES.md` es el checklist de tareas
(el segundo puzle ya figura como `[Hecho]`). Documentación y conversación en español;
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
  `move_backward`, `move_left`, `move_right`, `run`, `toggle_mouse`, `interact` (E),
  `drop_item` (F) y `slot_1` / `slot_2` / `slot_3` (1, 2 y 3 de la fila superior).
- Capas de física (con nombre en `project.godot`): 1 = `world`, 2 = `player`,
  3 = `furniture`, 4 = `interactable`. El jugador no se ve a sí mismo: su
  `collision_mask` es 13 (world + furniture + interactable), así que choca con los
  muebles; el raycast de interacción usa máscara 9 (world + interactable) y por eso
  ignora los muebles de la capa `furniture`.
- HUD (`scripts/ui/hud.gd`, `class_name Hud`): mira (`assets/player/crosshair.png`; ver
  `THIRD_PARTY.md`), prompt de interacción debajo de la mira, panel de mensajes temporal,
  barra de 3 slots de inventario abajo al centro y contador de fallos (`StrikeLabel`,
  arriba a la derecha, formato `Fallos: X - -`).
- Objeto en mano: `HandAnchor` (`Player/CameraHolder/Camera/HandAnchor`) recibe la
  instancia de `ItemData.held_scene` del slot seleccionado. `_refresh_held_item()`
  reacciona a `slots_changed` / `selection_changed` y `_try_drop_item()` (F) instancia
  `dropped_scene`, la añade al árbol con `add_child()` **antes** de asignar
  `global_position` (hacerlo antes dispara `Condition "!is_inside_tree()"`) y llama a
  `Inventory.remove_selected()`.
- `scenes/test/house_test_level.tscn` es el nivel jugable actual
  (`application/run/main_scene`); `scenes/test/test_level.tscn` es el nivel plano viejo.

## Interacción, puertas e inventario

- **Base:** `scripts/interactables/interactable.gd` (`class_name Interactable extends
  StaticBody3D`). Expone `prompt_text`, `enabled`, `get_prompt()` e `interact() -> String`
  (el string es el mensaje para el HUD). Los interactuables que no deben bloquear el paso
  usan solo la capa 4; los sólidos, 1 + 4 (valor 9). Los muebles que no son
  interactuables pero deben detener al jugador (como el sofá) van solo en capa 3
  (`furniture`, valor 4): el jugador choca con ellos y el rayo de interacción los ignora.
- **Raycast:** `Player/CameraHolder/Camera/InteractionRay` (`RayCast3D`, 2.2 m, máscara 9,
  `scripts/player/interaction_ray.gd`) actualiza el prompt cada frame y con E llama a
  `interact()` del objetivo.
- **Inventario:** autoload `Inventory` (`scripts/managers/inventory.gd`): 3 slots fijos,
  `selected_slot`, señales `slots_changed` / `selection_changed`. `add_item` autoselecciona
  el slot nuevo; `remove_item` se usa para consumir la llave y `remove_selected()` para
  soltar el objeto con F. Los objetos son `ItemData` (`scripts/inventory/item_data.gd`),
  con `held_scene` (vista en mano) y `dropped_scene` (instancia al soltar). La llave del
  dormitorio vive en `resources/items/key_bedroom.tres` y la almohada en
  `resources/items/pillow.tres`.
- **Puerta:** `scenes/interactables/Door.tscn` + `scripts/interactables/door.gd`
  (`class_name Door`). Usa `SM_Puerta.glb`: el marco queda fijo y `_ready` reparenta
  `SM_Hoja` + `SM_Pomo` bajo `Hinge`. **El `CollisionShape3D` de la hoja es hijo directo
  del `StaticBody3D`** (Godot no registra shapes colgadas de un `Node3D` intermedio) y el
  tween lo rota junto con la bisagra. Exportados: `required_item_id`, `locked`,
  `open_angle_degrees`, `open_time`, `is_open`. `unlock()` la desbloquea sin consumir
  ningún objeto: lo usa la cerradura numérica al ingresar la contraseña correcta.
- **Llave:** `scenes/collectibles/Key.tscn` + `scripts/collectibles/key.gd`
  (`class_name KeyPickup`), capa 4 con luz de acento (`Glow`) para que se vea en la casa
  nocturna. `set_item(value)` inyecta el `ItemData`: **no se serializa `item` en el
  `.tscn`**, porque `key_bedroom.tres` referencia a `Key.tscn` y eso crea un ciclo de
  recursos. `wardrobe.gd` usa `KEY_SCENE` + `KEY_ITEM` al spawnearla. Al recogerla se
  libera `Glow` antes que el cuerpo, si no aparece un error de `Transform3D()` con el
  nodo fuera del árbol.

## Puzle del dormitorio: estado de partida y UI modal

Tres autoloads (registrados en `project.godot`) sostienen los puzles:

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
  `PROCESS_MODE_ALWAYS`; instancia cinco ventanas: `scenes/ui/safe_window.tscn`,
  `note_window.tscn`, `game_over_window.tscn`, `card_window.tscn` y
  `number_lock_window.tscn`. Los interactuables llaman `PuzzleUI.open_safe()` /
  `open_note()` / `open_card()` / `open_lock(lock)`; mientras hay un modal abierto pausa
  el árbol y muestra el mouse. Escape (`toggle_mouse`) y el botón Cerrar vuelven al juego.

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

## Puzle del salón: tarjeta y cerradura numérica

- **Sofá** (`scenes/environment/furniture/Sofa.tscn` + `scripts/environment/sofa.gd`,
  `class_name Sofa`): `StaticBody3D` en capa `furniture` (4) con colisiones de base,
  brazos y respaldo. Los `SM_AlmohadonBase*` del GLB **se dejan visibles**; encima de
  cada uno se coloca una almohada recogible en `PillowSpot0/1/2`.
- **Almohadas** (`scenes/collectibles/Pillow.tscn` + `scripts/collectibles/pillow.gd`,
  `class_name Pillow`): capa 4, se recogen con E y se sueltan con F. `sofa.gd` inyecta
  el recurso `PILLOW_ITEM` (`resources/items/pillow.tres`) con `set_item()` para no
  repetir el ciclo de recursos de la llave. Al recogerse salen del grupo `sofa_pillow`
  y llaman a `refresh_cover()`; `player.gd` también lo llama después de un drop.
- **Tarjeta** (`scenes/collectibles/Card.tscn` + `scripts/collectibles/card.gd`,
  `class_name Card`): capa 4 cuando está descubierta, solo lectura →
  `PuzzleUI.open_card()` → `CardWindow` con `assets/test/img/tarjeta_de_invitacion.png`.
  `sofa.gd` la elige en un `card_slot` aleatorio y la pone en
  `spot.global_position + (0, -0.07, 0)`, es decir entre el almohadón baked y la
  almohada de arriba. `refresh_cover()` usa el grupo `sofa_pillow` y `COVER_RADIUS =
  0.24`: si hay una almohada encima, `set_covered(true)` la vuelve invisible, la
  deshabilita y le pone capa 0.
- **Cerradura** (`scenes/interactables/NumberLock.tscn` +
  `scripts/interactables/number_lock.gd`, `class_name NumberLock`): `password = 2805`
  fijo, `digit_count = 4`, `linked_door` y señal `solved`. `submit(code)` valida la
  longitud, llama a `GameManager.add_strike()` si falla y, si acierta, emite `solved`,
  se deshabilita (capa 0) y llama `Door.unlock()`.
- **Ventana** (`scripts/ui/number_lock_window.gd`, `class_name NumberLockWindow`):
  teclado modal con X (limpiar), 0 y ✓ (comprobar) más 1–9; muestra los dígitos con
  guiones bajos y usa un temporizador de 1 s para el feedback antes de limpiar o cerrar.
- **Colocación en `house_test_level.tscn`:** `Sofa` en `(-2.1, 0.3, 0.5)`,
  `KitchenDoor` en `(0.615, 0.3, -1.19)` y `NumberLock` en `(0.5, 1.25, -0.55)` con
  `linked_door = NodePath("../KitchenDoor")`.
- **Flujo:** levantar almohadas hasta encontrar la tarjeta → leer la contraseña →
  interactuar con la cerradura e ingresar `2805` → la puerta a la cocina se desbloquea
  y se abre. Los códigos incorrectos suman strikes **globales** (los mismos que la
  caja fuerte); con 3 se dispara el game over y el reinicio genera una combinación nueva.

### Gotchas de prueba y validación

- `game_start` usa la escena abierta en el editor: abrir siempre
  `res://scenes/test/house_test_level.tscn` antes de iniciar la partida de prueba.
- `debugger_get_log` se reinicia con `game_stop` / `game_start`; conviene filtrar
  `text_filter: "ERROR"`. Los mensajes de `editor_get_console` sobre "progress dialog
  while flushing" o `!tasks.has(p_task)` son ruido del editor generado por
  `extensions_refresh` / LSP, no errores del juego.
- `execute_code` es **expression-only** (sin `var`, `if`, `for`) y no resuelve globals
  (`Vector3`, autoloads): usar rutas absolutas `/root/...` y, para posiciones,
  `runtime_set_property` con `{"type": "Vector3", "x": ..., "y": ..., "z": ...}`.
- `input_simulate` con `events: {event_type: "action", event_data: {action:
  "drop_item"}}` permite probar la tecla F.
- El editor puede revertir `scripts/player/player.gd` si se edita por MCP y luego se
  reasigna el script: verificar el archivo en disco y llamar `extensions_refresh()`.
- `lsp_project_diagnostics` da 26 archivos escaneados, 25 limpios; el único aviso es
  el preexistente `SHADOWED_VARIABLE_BASE_CLASS` en `scripts/interactables/door.gd:84`.

## Assets de terceros

`assets/player/crosshair.png` es lo único que queda de un addon de terceros: viene de
**JehenoAdvancedFirstPersonController** (MIT, © 2024 Jeh3no). El addon se eliminó por
completo del proyecto; la atribución vive en `THIRD_PARTY.md`.

## Ajustes del motor

`project.godot`: Godot 4.7, Forward+, **Jolt Physics**, driver **D3D12** en Windows,
stretch `canvas_items` / `expand`. `.godot/` está ignorado por git.
