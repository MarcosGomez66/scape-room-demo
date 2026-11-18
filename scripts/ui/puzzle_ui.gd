extends CanvasLayer

## Autoload that owns the modal windows and the pause/mouse state while they
## are open. Any interactable can call PuzzleUI.open_safe() or open_note().

const SAFE_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/safe_window.tscn")
const NOTE_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/note_window.tscn")
const GAME_OVER_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/game_over_window.tscn")

var safe_window: SafeWindow
var note_window: NoteWindow
var game_over_window: GameOverWindow

var _modal_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	safe_window = SAFE_WINDOW_SCENE.instantiate() as SafeWindow
	note_window = NOTE_WINDOW_SCENE.instantiate() as NoteWindow
	game_over_window = GAME_OVER_WINDOW_SCENE.instantiate() as GameOverWindow
	add_child(safe_window)
	add_child(note_window)
	add_child(game_over_window)
	safe_window.closed.connect(close)
	note_window.closed.connect(close)
	GameManager.game_over.connect(_on_game_over)
	hide_all()


func open_safe() -> void:
	if _modal_open:
		return
	_modal_open = true
	safe_window.open()
	_show_modal()


func open_note() -> void:
	if _modal_open:
		return
	_modal_open = true
	note_window.open()
	_show_modal()


func close() -> void:
	if not _modal_open:
		return
	_modal_open = false
	hide_all()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Used by GameManager before reloading the level.
func close_all() -> void:
	_modal_open = false
	hide_all()
	get_tree().paused = false


func hide_all() -> void:
	safe_window.visible = false
	note_window.visible = false
	game_over_window.visible = false


func _show_modal() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_game_over() -> void:
	_modal_open = false
	hide_all()
	game_over_window.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
