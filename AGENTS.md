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
  `THIRD_PARTY.md`), prompt de interacción debajo de la mira, panel de mensajes temporal
  y barra de 3 slots de inventario abajo al centro.
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

### Prueba jugable del dormitorio

En `house_test_level.tscn`: el jugador arranca encerrado en el dormitorio mirando la
puerta (`BedroomDoor`, bloqueada), la llave está tirada en el piso (`BedroomKey`) y el
flujo esperado es: E en la puerta → mensaje de bloqueo; recoger la llave → queda en el
slot 1; E en la puerta con la llave seleccionada → se consume la llave y la puerta se
abre hacia el dormitorio.

## Assets de terceros

`assets/player/crosshair.png` es lo único que queda de un addon de terceros: viene de
**JehenoAdvancedFirstPersonController** (MIT, © 2024 Jeh3no). El addon se eliminó por
completo del proyecto; la atribución vive en `THIRD_PARTY.md`.

## Ajustes del motor

`project.godot`: Godot 4.7, Forward+, **Jolt Physics**, driver **D3D12** en Windows,
stretch `canvas_items` / `expand`. `.godot/` está ignorado por git.
