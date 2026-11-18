extends Control

class_name NoteWindow

## Read-only note window. Shows the three clues in the safe's solution order,
## without naming the objects or their colors.

signal closed

@onready var panel: PanelContainer = %Paper
@onready var close_button: Button = %CloseButton
@onready var clues: Array[Label] = [%Clue1, %Clue2, %Clue3]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_request_close)
	_build_style()
	visible = false


func open() -> void:
	for i: int in clues.size():
		if i < PuzzleManager.sequence.size():
			clues[i].text = "%d. %s" % [i + 1, PuzzleManager.clue_for(PuzzleManager.sequence[i])]
		else:
			clues[i].text = ""
	visible = true


func _request_close() -> void:
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("toggle_mouse"):
		_request_close()
		get_viewport().set_input_as_handled()


func _build_style() -> void:
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.94, 0.92, 0.86, 1.0)
	paper.border_color = Color(0.62, 0.58, 0.48, 1.0)
	paper.set_border_width_all(2)
	paper.set_corner_radius_all(4)
	paper.content_margin_left = 36.0
	paper.content_margin_right = 36.0
	paper.content_margin_top = 26.0
	paper.content_margin_bottom = 30.0
	panel.add_theme_stylebox_override("panel", paper)
