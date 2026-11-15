extends RayCast3D

## Turns the camera raycast into interaction: prompt under the crosshair,
## E to trigger the focused Interactable and HUD messages.

@onready var hud: Hud = %HUD

var _target: Interactable = null


func _physics_process(_delta: float) -> void:
	if _target != null and not is_instance_valid(_target):
		_target = null

	var next_target: Interactable = null
	if is_colliding():
		var collider: Object = get_collider()
		if collider is Interactable and (collider as Interactable).enabled:
			next_target = collider as Interactable

	if next_target != null:
		hud.show_prompt(next_target.get_prompt())
	else:
		hud.hide_prompt()

	if next_target != _target:
		_target = next_target
		hud.set_focused(_target != null)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if _target == null or not is_instance_valid(_target) or not _target.enabled:
		return
	var message: String = _target.interact()
	if not message.is_empty():
		hud.show_message(message)
