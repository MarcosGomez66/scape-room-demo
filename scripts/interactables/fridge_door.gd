extends Interactable

class_name FridgeDoor

## Fridge door: swings open once around the body origin and stays disabled.
## The GLB leaf is reparented so mesh and collider share the hinge pivot.

const DOOR_PARTS: Array[String] = ["SM_Puerta"]

@export var open_angle_degrees: float = 90.0
@export var open_time: float = 0.9

@onready var model: Node3D = get_node("../Model") as Node3D

var _opened: bool = false
var _tween: Tween


func _ready() -> void:
	for part_name: String in DOOR_PARTS:
		var part: Node3D = model.get_node_or_null(part_name) as Node3D
		if part != null:
			part.reparent(self, true)


func get_prompt() -> String:
	return "Abrir heladera"


func interact() -> String:
	if _opened:
		return ""
	_opened = true
	enabled = false
	collision_layer = 0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "rotation:y", deg_to_rad(open_angle_degrees), open_time)
	return "Abriste la heladera."
