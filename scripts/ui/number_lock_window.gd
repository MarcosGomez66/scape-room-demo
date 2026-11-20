extends Control

class_name NumberLockWindow

## Modal keypad for the kitchen lock. Shows the typed digits, clears with X
## and validates with the check button; failures use the global strikes.

signal closed

@onready var panel: PanelContainer = %Panel
@onready var close_button: Button = %CloseButton
@onready var digits_label: Label = %DigitsLabel
@onready var status_label: Label = %StatusLabel
@onready var clear_button: Button = %ClearButton
@onready var submit_button: Button = %SubmitButton

var _lock: NumberLock = null
var _digits: String = ""
var _locked: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_request_close)
	clear_button.pressed.connect(_clear)
	submit_button.pressed.connect(_submit)
	for digit: int in 10:
		var button: Button = get_node("%%Digit%d" % digit) as Button
		if button != null:
			button.pressed.connect(_on_digit.bind(digit))
	_build_style()
	visible = false


func open(lock: NumberLock) -> void:
	_lock = lock
	_digits = ""
	_locked = false
	_update_digits()
	status_label.text = ""
	status_label.visible = false
	visible = true


func _on_digit(digit: int) -> void:
	if _locked or _lock == null or _digits.length() >= _lock.digit_count:
		return
	_digits += str(digit)
	_update_digits()


func _clear() -> void:
	if _locked:
		return
	_digits = ""
	_update_digits()


func _submit() -> void:
	if _locked or _lock == null:
		return
	if _digits.length() != _lock.digit_count:
		_show_status("Ingresá %d dígitos." % _lock.digit_count)
		return
	_locked = true
	if _lock.submit(_digits):
		_show_status("¡Código correcto!")
		await get_tree().create_timer(1.0, true).timeout
		closed.emit()
		return
	if GameManager.is_game_over:
		return
	_show_status("Código incorrecto. Fallo %d de %d." % [
		GameManager.strikes, GameManager.MAX_STRIKES
	])
	await get_tree().create_timer(1.0, true).timeout
	_digits = ""
	_update_digits()
	status_label.visible = false
	_locked = false


func _request_close() -> void:
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("toggle_mouse"):
		_request_close()
		get_viewport().set_input_as_handled()


func _update_digits() -> void:
	var missing: int = 4 - _digits.length()
	digits_label.text = _digits + "_".repeat(missing)


func _show_status(text: String) -> void:
	status_label.text = text
	status_label.visible = true


func _build_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.065, 0.085, 0.97)
	style.border_color = Color(0.28, 0.32, 0.38, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 22.0
	style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", style)
