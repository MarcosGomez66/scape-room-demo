extends Interactable

class_name WardrobeDoor

## Left wardrobe door: it swings open once and stays that way, with no further
## interaction. The body origin sits on the hinge, so rotating the body moves
## both the visual leaf and its collider around the same pivot.

@export var open_angle_degrees: float = -90.0
@export var open_time: float = 0.9

@onready var model: Node3D = get_node("../Model") as Node3D

var _tween: Tween


func _ready() -> void:
	_take_part("SM_HojaIzq")
	_take_part("SM_PomoIzq")


func get_prompt() -> String:
	return "Abrir ropero"


func interact() -> String:
	enabled = false
	collision_layer = 0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "rotation:y", deg_to_rad(open_angle_degrees), open_time)
	return "Abriste el ropero."


## Moves a leaf part out of the model and under this body, keeping its place.
func _take_part(part_name: String) -> void:
	var part: Node3D = model.get_node_or_null(part_name) as Node3D
	if part != null:
		part.reparent(self, true)
