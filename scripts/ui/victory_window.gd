extends Control

class_name VictoryWindow

## Full-screen win overlay with restart and quit buttons.

@onready var panel: PanelContainer = %Panel
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)
	_build_style()
	visible = false


func open() -> void:
	visible = true


func _on_restart() -> void:
	GameManager.restart_game()


func _on_quit() -> void:
	get_tree().quit()


func _build_style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.09, 0.07, 0.98)
	panel_style.border_color = Color(0.45, 0.85, 0.5, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left = 40.0
	panel_style.content_margin_right = 40.0
	panel_style.content_margin_top = 32.0
	panel_style.content_margin_bottom = 34.0
	panel.add_theme_stylebox_override("panel", panel_style)
