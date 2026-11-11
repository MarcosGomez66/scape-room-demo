extends CharacterBody3D

class_name PlayerController

## Minimal first-person controller for the escape room demo.
## WASD to move, hold Shift to run, mouse to look, Escape to release/recapture the mouse.

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

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotation.x = clampf(
			camera.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-max_pitch_degrees),
			deg_to_rad(max_pitch_degrees),
		)
	elif event.is_action_pressed("toggle_mouse"):
		var captured: bool = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED)


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
