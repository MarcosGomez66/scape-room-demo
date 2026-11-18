extends Node

## Tracks failed safe combinations. Three strikes end the run.

signal strikes_changed(strikes: int)
signal game_over

const MAX_STRIKES: int = 3

var strikes: int = 0
var is_game_over: bool = false


func add_strike() -> void:
	if is_game_over:
		return
	strikes += 1
	strikes_changed.emit(strikes)
	if strikes >= MAX_STRIKES:
		is_game_over = true
		game_over.emit()


## Resets run state, regenerates the puzzle and reloads the level.
func restart_game() -> void:
	strikes = 0
	is_game_over = false
	strikes_changed.emit(0)
	Inventory.clear()
	PuzzleManager.generate()
	var ui: Node = get_node_or_null("/root/PuzzleUI")
	if ui != null:
		ui.close_all()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().reload_current_scene()
