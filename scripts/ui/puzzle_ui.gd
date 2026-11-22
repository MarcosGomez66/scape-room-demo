extends CanvasLayer

## Autoload that owns the modal windows and the pause/mouse state while they
## are open. Any interactable can call PuzzleUI.open_safe() or open_note().

const SAFE_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/safe_window.tscn")
const NOTE_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/note_window.tscn")
const GAME_OVER_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/game_over_window.tscn")
const CARD_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/card_window.tscn")
const NUMBER_LOCK_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/number_lock_window.tscn")
const VICTORY_WINDOW_SCENE: PackedScene = preload("res://scenes/ui/victory_window.tscn")

var safe_window: SafeWindow
var note_window: NoteWindow
var game_over_window: GameOverWindow
var card_window: CardWindow
var number_lock_window: NumberLockWindow
var victory_window: VictoryWindow

var _modal_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	safe_window = SAFE_WINDOW_SCENE.instantiate() as SafeWindow
	note_window = NOTE_WINDOW_SCENE.instantiate() as NoteWindow
	game_over_window = GAME_OVER_WINDOW_SCENE.instantiate() as GameOverWindow
	card_window = CARD_WINDOW_SCENE.instantiate() as CardWindow
	number_lock_window = NUMBER_LOCK_WINDOW_SCENE.instantiate() as NumberLockWindow
	victory_window = VICTORY_WINDOW_SCENE.instantiate() as VictoryWindow
	add_child(safe_window)
	add_child(note_window)
	add_child(game_over_window)
	add_child(card_window)
	add_child(number_lock_window)
	add_child(victory_window)
	safe_window.closed.connect(close)
	note_window.closed.connect(close)
	card_window.closed.connect(close)
	number_lock_window.closed.connect(close)
	GameManager.game_over.connect(_on_game_over)
	GameManager.victory.connect(_on_victory)
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


## Read-only short note, used by the fridge warning.
func open_message(title: String, text: String) -> void:
	if _modal_open:
		return
	_modal_open = true
	note_window.open_custom(title, [text])
	_show_modal()


func open_card() -> void:
	if _modal_open:
		return
	_modal_open = true
	card_window.open()
	_show_modal()


func open_lock(lock: NumberLock) -> void:
	if _modal_open:
		return
	_modal_open = true
	number_lock_window.open(lock)
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
	card_window.visible = false
	number_lock_window.visible = false
	victory_window.visible = false


func _show_modal() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_game_over() -> void:
	_modal_open = false
	hide_all()
	game_over_window.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_victory() -> void:
	_modal_open = false
	hide_all()
	victory_window.open()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
