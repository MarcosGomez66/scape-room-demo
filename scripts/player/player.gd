extends CharacterBody3D

class_name PlayerController

## Minimal first-person controller for the escape room demo.
## WASD to move, hold Shift to run, mouse to look, Escape to open the pause menu.
## Keys 1-3 select an inventory slot; F drops the selected item.

const SLOT_ACTIONS: Array[StringName] = [&"slot_1", &"slot_2", &"slot_3"]

const DROP_DISTANCE: float = 1.2
const DROP_HEIGHT: float = 0.45

@export_group("Movement")
@export var walk_speed: float = 4.5
@export var run_speed: float = 7.5
@export var acceleration: float = 10.0
@export var deceleration: float = 12.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.0025
@export var max_pitch_degrees: float = 89.0

@onready var camera_holder: Node3D = $CameraHolder
@onready var camera: Camera3D = %Camera
@onready var hand_anchor: Node3D = get_node_or_null("CameraHolder/Camera/HandAnchor") as Node3D
@onready var hud: Hud = get_node_or_null("HUD") as Hud

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var _held_instance: Node3D = null


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Inventory.slots_changed.connect(_refresh_held_item)
	Inventory.selection_changed.connect(_refresh_held_item)
	_refresh_held_item()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotation.x = clampf(
			camera.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-max_pitch_degrees),
			deg_to_rad(max_pitch_degrees),
		)
		return

	if event.is_action_pressed("drop_item"):
		_try_drop_item()
		return

	for i: int in SLOT_ACTIONS.size():
		if event.is_action_pressed(SLOT_ACTIONS[i]):
			Inventory.select_slot(i)
			return

	if event.is_action_pressed("toggle_mouse"):
		PuzzleUI.open_pause()
		get_viewport().set_input_as_handled()
		return


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (camera_holder.global_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var speed: float = run_speed if Input.is_action_pressed("run") else walk_speed

	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	var rate: float = acceleration if direction != Vector3.ZERO else deceleration
	horizontal = horizontal.move_toward(direction * speed, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	move_and_slide()


func _refresh_held_item(_slot_index: int = 0) -> void:
	if _held_instance != null and is_instance_valid(_held_instance):
		_held_instance.queue_free()
	_held_instance = null
	if hand_anchor == null:
		return
	var item: ItemData = Inventory.get_selected_item()
	if item == null or item.held_scene == null:
		return
	_held_instance = item.held_scene.instantiate() as Node3D
	if _held_instance == null:
		return
	hand_anchor.add_child(_held_instance)
	_held_instance.transform = Transform3D.IDENTITY


func _try_drop_item() -> void:
	if get_tree().paused:
		return
	var item: ItemData = Inventory.get_selected_item()
	if item == null or item.dropped_scene == null:
		return
	var dropped: Node3D = item.dropped_scene.instantiate() as Node3D
	if dropped == null:
		return
	var forward: Vector3 = -camera.global_transform.basis.z
	var flat: Vector3 = Vector3(forward.x, 0.0, forward.z)
	if flat.length() < 0.01:
		flat = Vector3(0.0, 0.0, -1.0)
	var target: Vector3 = global_position + flat.normalized() * DROP_DISTANCE
	target.x = clampf(target.x, -3.4, 3.4)
	target.y = DROP_HEIGHT
	target.z = clampf(target.z, -4.0, 1.9)
	get_tree().current_scene.add_child(dropped)
	dropped.global_position = target
	if dropped.has_method("set_item"):
		dropped.call("set_item", item)
	elif dropped is KeyPickup:
		dropped.item = item
	Inventory.remove_selected()
	if hud != null:
		hud.show_message("Soltaste: %s." % item.display_name)
	for node: Node in get_tree().get_nodes_in_group("sofa_controller"):
		if node.has_method("refresh_cover"):
			node.call("refresh_cover")
