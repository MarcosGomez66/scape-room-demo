extends Interactable

class_name Card

## Invitation card hidden under a pillow. It can only be read, never taken.


func set_covered(value: bool) -> void:
	visible = not value
	enabled = not value
	collision_layer = 0 if value else 8


func get_prompt() -> String:
	return "Ver tarjeta"


func interact() -> String:
	if not enabled:
		return ""
	PuzzleUI.open_card()
	return ""
