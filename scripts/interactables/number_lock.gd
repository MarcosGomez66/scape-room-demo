extends Interactable

class_name NumberLock

## Four-digit lock for the kitchen door. Wrong codes use the global strike
## counter; a correct code unlocks the linked door without consuming an item.

signal solved

@export var password: int = 2805
@export var linked_door: NodePath = NodePath()
@export var digit_count: int = 4

var is_solved: bool = false


func get_prompt() -> String:
	return "Usar cerradura"


func interact() -> String:
	if is_solved:
		return ""
	PuzzleUI.open_lock(self)
	return ""


func submit(code: String) -> bool:
	if is_solved:
		return true
	if code.length() != digit_count or not code.is_valid_int():
		return false
	if int(code) == password:
		_mark_solved()
		return true
	GameManager.add_strike()
	return false


func _mark_solved() -> void:
	is_solved = true
	enabled = false
	collision_layer = 0
	var door: Door = get_node_or_null(linked_door) as Door
	if door != null:
		door.unlock()
	solved.emit()
