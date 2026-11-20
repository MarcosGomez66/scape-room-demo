extends Control

class_name CardWindow

## Modal that shows the invitation card texture found under a sofa pillow.

signal closed

@onready var close_button: Button = %CloseButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_request_close)
	visible = false


func open() -> void:
	visible = true


func _request_close() -> void:
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("toggle_mouse"):
		_request_close()
		get_viewport().set_input_as_handled()
