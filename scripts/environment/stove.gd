extends Interactable

class_name Stove

## Gas stove for the third puzzle. The player can place the can and light the
## burner in any order; when both are true a 5 s cooking sequence starts.

const CAN_SCENE: PackedScene = preload("res://scenes/collectibles/Can.tscn")
const NEED_LIGHT_MESSAGE: String = "La cocina tiene gas pero necesito algo para encenderlo"

@export var burner_spot: NodePath = ^"BurnerSpot"
@export var cook_time: float = 5.0

@onready var model: Node3D = get_node_or_null("Model") as Node3D
@onready var cook_timer: Timer = get_node_or_null("CookTimer") as Timer

var is_lit: bool = false
var is_cooking: bool = false
var is_done: bool = false
var is_can_placed: bool = false
var _can: CanPickup = null
var _flames: Array[Node3D] = []


func _ready() -> void:
	if model != null:
		for child: Node in model.get_children():
			if child.name.begins_with("SM_Flama"):
				child.visible = false
				_flames.append(child as Node3D)
	if cook_timer != null:
		cook_timer.one_shot = true
		cook_timer.wait_time = cook_time
		cook_timer.timeout.connect(_on_cook_finished)


func get_prompt() -> String:
	return "Usar cocina"


func interact() -> String:
	if is_cooking:
		return "La lata se está calentando..."
	if is_done:
		return ""
	var selected: ItemData = Inventory.get_selected_item()
	if selected == null:
		return NEED_LIGHT_MESSAGE
	match selected.id:
		&"can":
			return _place_can()
		&"match":
			return _ignite()
		_:
			return NEED_LIGHT_MESSAGE


func _ignite() -> String:
	if is_lit:
		return "La cocina ya está encendida."
	if not Inventory.has_item(&"match"):
		return NEED_LIGHT_MESSAGE
	Inventory.remove_item(&"match")
	is_lit = true
	for flame: Node3D in _flames:
		if flame != null:
			flame.visible = true
	_maybe_start_cooking()
	return "Encendiste la cocina con los fósforos."


func _place_can() -> String:
	if is_can_placed:
		return "Ya hay una lata en la hornalla."
	if not Inventory.remove_item(&"can"):
		return NEED_LIGHT_MESSAGE
	var spot: Node3D = get_node_or_null(burner_spot) as Node3D
	if spot == null:
		return ""
	_can = CAN_SCENE.instantiate() as CanPickup
	add_child(_can)
	_can.global_position = spot.global_position
	_can.enabled = false
	_can.collision_layer = 0
	is_can_placed = true
	_maybe_start_cooking()
	return "Colocaste la lata sobre la hornalla 002."


func _maybe_start_cooking() -> void:
	if is_cooking or is_done or not is_lit or not is_can_placed:
		return
	if _can == null or not is_instance_valid(_can):
		return
	is_cooking = true
	enabled = false
	_can.start_cooking()
	if cook_timer != null:
		cook_timer.start(cook_time)


func _on_cook_finished() -> void:
	is_cooking = false
	is_done = true
	if _can != null and is_instance_valid(_can):
		_can.burst()
