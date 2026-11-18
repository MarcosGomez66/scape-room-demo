extends Control

class_name SafeWindow

## Modal safe puzzle: press three of the five color buttons in the right order.
## Each button has its own red indicator light. A button can only be pressed
## once per attempt; three wrong colors reset the attempt and add a strike.

signal closed

const COLOR_IDS: Array[StringName] = [&"magenta", &"amarillo", &"azul", &"rojo", &"verde"]
const BUTTON_COLORS: Array[Color] = [
	Color(1.0, 0.0, 1.0),
	Color(1.0, 1.0, 0.0),
	Color(0.05, 0.35, 1.0),
	Color(1.0, 0.0, 0.0),
	Color(0.05, 0.8, 0.15),
]
const MAX_PRESSES: int = 3

@onready var panel: PanelContainer = %Panel
@onready var close_button: Button = %CloseButton
@onready var status_label: Label = %StatusLabel
@onready var lights: Array[Panel] = [%Light1, %Light2, %Light3, %Light4, %Light5]
@onready var buttons: Array[Button] = [
	%MagentaButton, %YellowButton, %BlueButton, %RedButton, %GreenButton
]

var _attempt: Array[StringName] = []
var _pressed: Array[int] = []
var _locked: bool = false

var _light_off: StyleBoxFlat
var _light_on: StyleBoxFlat


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_request_close)
	for i: int in buttons.size():
		buttons[i].pressed.connect(_on_color_pressed.bind(i))
	_build_styles()
	reset_puzzle()
	visible = false


func open() -> void:
	reset_puzzle()
	visible = true


func reset_puzzle() -> void:
	_attempt.clear()
	_pressed.clear()
	_locked = false
	status_label.text = ""
	status_label.visible = false
	for i: int in lights.size():
		_set_light(i, false)


func _on_color_pressed(index: int) -> void:
	if _locked or _pressed.has(index):
		return
	_pressed.append(index)
	_set_light(index, true)
	_attempt.append(COLOR_IDS[index])
	if _attempt.size() < MAX_PRESSES:
		return
	_locked = true
	if PuzzleManager.check_answer(_attempt):
		_on_correct()
	else:
		_on_wrong()


func _on_correct() -> void:
	PuzzleManager.mark_solved()
	status_label.text = "¡Combinación correcta!"
	status_label.visible = true
	await get_tree().create_timer(1.0, true).timeout
	closed.emit()


func _on_wrong() -> void:
	GameManager.add_strike()
	status_label.text = "Combinación incorrecta. Fallo %d de %d." % [
		GameManager.strikes, GameManager.MAX_STRIKES
	]
	status_label.visible = true
	await get_tree().create_timer(1.0, true).timeout
	if GameManager.is_game_over:
		return
	_attempt.clear()
	_pressed.clear()
	_locked = false
	status_label.visible = false
	for i: int in lights.size():
		_set_light(i, false)


func _request_close() -> void:
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("toggle_mouse"):
		_request_close()
		get_viewport().set_input_as_handled()


func _set_light(index: int, lit: bool) -> void:
	lights[index].add_theme_stylebox_override("panel", _light_on if lit else _light_off)


func _build_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.065, 0.085, 0.97)
	panel_style.border_color = Color(0.28, 0.32, 0.38, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left = 28.0
	panel_style.content_margin_right = 28.0
	panel_style.content_margin_top = 22.0
	panel_style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", panel_style)

	_light_off = StyleBoxFlat.new()
	_light_off.bg_color = Color(0.09, 0.1, 0.12, 1.0)
	_light_off.border_color = Color(0.3, 0.33, 0.38, 1.0)
	_light_off.set_border_width_all(2)
	_light_off.set_corner_radius_all(4)

	_light_on = StyleBoxFlat.new()
	_light_on.bg_color = Color(0.95, 0.13, 0.1, 1.0)
	_light_on.border_color = Color(1.0, 0.55, 0.5, 1.0)
	_light_on.set_border_width_all(2)
	_light_on.set_corner_radius_all(4)

	for i: int in buttons.size():
		var base: Color = BUTTON_COLORS[i]
		buttons[i].add_theme_stylebox_override("normal", _make_round_style(base, base.darkened(0.35)))
		buttons[i].add_theme_stylebox_override("hover", _make_round_style(base.lightened(0.18), Color.WHITE))
		buttons[i].add_theme_stylebox_override("pressed", _make_round_style(base.darkened(0.2), Color.WHITE))
		buttons[i].add_theme_stylebox_override("focus", _make_round_style(base, Color.WHITE))


func _make_round_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(28)
	return style
