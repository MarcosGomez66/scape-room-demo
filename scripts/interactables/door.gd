extends Interactable

class_name Door

## Hinged door with an optional key requirement.
## The GLB provides the frame and the leaf as separate nodes; _ready reparents
## the leaf (and the handle) under Hinge so the frame stays put while it swings.
## The leaf collider is a direct child of the body (Godot only registers
## CollisionShape3D nodes that way) and is rotated around the hinge by the tween.

const HINGE_X: float = 0.45
const LEAF_CENTER: Vector3 = Vector3(0.0, 1.05, 0.0)

@export var required_item_id: StringName = &"key_bedroom"
@export var locked: bool = true
@export var open_angle_degrees: float = -90.0
@export var open_time: float = 0.9
@export var is_open: bool = false

@onready var hinge: Node3D = $Hinge
@onready var model: Node3D = $Model
@onready var leaf_collision: CollisionShape3D = $LeafCollision

var _angle: float = 0.0
var _tween: Tween


func _ready() -> void:
	hinge.position.x = HINGE_X
	_move_leaf_to_hinge("SM_Hoja")
	_move_leaf_to_hinge("SM_Pomo")
	_apply_angle(0.0)


func get_prompt() -> String:
	return "Cerrar puerta" if is_open else "Abrir puerta"


func interact() -> String:
	if locked:
		var selected: ItemData = Inventory.get_selected_item()
		if selected != null and selected.id == required_item_id:
			locked = false
			Inventory.remove_item(required_item_id)
			_set_open(true)
			return "Usaste la llave. Puerta desbloqueada."
		if Inventory.has_item(required_item_id):
			return "Tenés la llave. Seleccionala con 1, 2 o 3."
		return "La puerta está bloqueada. Necesitás una llave."
	_set_open(not is_open)
	return ""


## Unlocks without consuming an item. Used by the numeric lock puzzle.
func unlock() -> void:
	if is_open and not locked:
		return
	locked = false
	_set_open(true)
	enabled = false
	collision_layer = 0


func _move_leaf_to_hinge(part_name: String) -> void:
	var part: Node3D = model.get_node_or_null(part_name) as Node3D
	if part != null:
		part.reparent(hinge, true)


func _set_open(value: bool) -> void:
	is_open = value
	if _tween != null:
		_tween.kill()
	var target: float = deg_to_rad(open_angle_degrees) if value else 0.0
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(_apply_angle, _angle, target, open_time)


## Rotates the hinge and the leaf collider around the hinge pivot.
func _apply_angle(angle: float) -> void:
	_angle = angle
	hinge.rotation.y = angle
	var basis := Basis(Vector3.UP, angle)
	var hinge_point := Vector3(HINGE_X, 0.0, 0.0)
	leaf_collision.transform = Transform3D(
		basis, hinge_point + basis * (LEAF_CENTER - hinge_point)
	)
