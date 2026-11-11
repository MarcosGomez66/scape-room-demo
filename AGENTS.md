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

- Acciones de input definidas en `project.godot`: `move_forward`, `move_backward`,
  `move_left`, `move_right`, `run`, `toggle_mouse` (physical keycodes).
  **`interact` (E) todavía no existe**: lo tiene que agregar el sistema de interacción del GDD.
- Capas de física: 1 = mundo, 2 = jugador (el jugador no se ve a sí mismo y los raycasts
  de interacción pueden ignorarlo).
- HUD: solo la mira (`assets/player/crosshair.png`; ver `THIRD_PARTY.md`).
- `scenes/test/test_level.tscn` es el nivel de prueba; `application/run/main_scene` apunta
  ahí de forma temporal.

## Assets de terceros

`assets/player/crosshair.png` es lo único que queda de un addon de terceros: viene de
**JehenoAdvancedFirstPersonController** (MIT, © 2024 Jeh3no). El addon se eliminó por
completo del proyecto; la atribución vive en `THIRD_PARTY.md`.

## Ajustes del motor

`project.godot`: Godot 4.7, Forward+, **Jolt Physics**, driver **D3D12** en Windows,
stretch `canvas_items` / `expand`. `.godot/` está ignorado por git.
