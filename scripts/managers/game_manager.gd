extends Node

## Tracks failed safe combinations. Three strikes end the run.

signal strikes_changed(strikes: int)
signal game_over
signal victory

const MAX_STRIKES: int = 3

var strikes: int = 0
var is_game_over: bool = false
var has_won: bool = false


func add_strike() -> void:
	if is_game_over:
		return
	strikes += 1
	strikes_changed.emit(strikes)
	if strikes >= MAX_STRIKES:
		is_game_over = true
		game_over.emit()


## Called when the player walks out through the main door.
func win_game() -> void:
	if is_game_over or has_won:
		return
	has_won = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	victory.emit()


## Resets run state, regenerates the puzzle and reloads the level.
func restart_game() -> void:
	strikes = 0
	is_game_over = false
	has_won = false
	strikes_changed.emit(0)
	Inventory.clear()
	PuzzleManager.generate()
	var ui: Node = get_node_or_null("/root/PuzzleUI")
	if ui != null:
		ui.close_all()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().reload_current_scene()
