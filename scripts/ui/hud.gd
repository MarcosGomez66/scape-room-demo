extends CanvasLayer

class_name Hud

## Screen UI: interaction prompt, timed messages and the three inventory slots.

const SLOT_COUNT: int = 3

@onready var prompt_label: Label = %InteractionPrompt
@onready var message_panel: PanelContainer = %MessagePanel
@onready var message_label: Label = %MessageLabel
@onready var crosshair: TextureRect = $Crosshair
@onready var strike_label: Label = %StrikeLabel
@onready var slot_panels: Array[PanelContainer] = [%Slot1, %Slot2, %Slot3]
@onready var slot_labels: Array[Label] = [%Slot1Label, %Slot2Label, %Slot3Label]

var _message_tween: Tween
var _selected_style: StyleBoxFlat
var _filled_style: StyleBoxFlat
var _empty_style: StyleBoxFlat


func _ready() -> void:
	_build_styles()
	_style_labels()
	Inventory.slots_changed.connect(_refresh_slots)
	Inventory.selection_changed.connect(_on_selection_changed)
	GameManager.strikes_changed.connect(_on_strikes_changed)
	prompt_label.visible = false
	message_panel.visible = false
	_refresh_slots()
	_on_strikes_changed(GameManager.strikes)


func show_prompt(text: String) -> void:
	if text.is_empty():
		hide_prompt()
		return
	prompt_label.text = "[E] %s" % text
	prompt_label.visible = true


func hide_prompt() -> void:
	prompt_label.visible = false


func show_message(text: String) -> void:
	if text.is_empty():
		return
	message_label.text = text
	message_panel.visible = true
	message_panel.modulate.a = 1.0
	if _message_tween != null:
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_interval(2.6)
	_message_tween.tween_property(message_panel, "modulate:a", 0.0, 0.6)
	_message_tween.tween_callback(func() -> void: message_panel.visible = false)


func set_focused(focused: bool) -> void:
	crosshair.modulate = Color(1.0, 0.84, 0.42) if focused else Color.WHITE


func _on_selection_changed(_slot_index: int) -> void:
	_refresh_slots()


func _on_strikes_changed(count: int) -> void:
	var text: String = "Fallos:"
	for i: int in GameManager.MAX_STRIKES:
		text += " X" if i < count else " -"
	strike_label.text = text
	var color: Color = Color(0.92, 0.94, 0.96)
	if count > 0:
		color = Color(1.0, 0.42, 0.34) if count >= GameManager.MAX_STRIKES else Color(1.0, 0.72, 0.32)
	strike_label.add_theme_color_override("font_color", color)


func _refresh_slots() -> void:
	for i: int in SLOT_COUNT:
		var item: ItemData = Inventory.slots[i] if i < Inventory.slots.size() else null
		var item_text: String = "—" if item == null else item.display_name
		slot_labels[i].text = "%d · %s" % [i + 1, item_text]

		var selected: bool = i == Inventory.selected_slot
		var style: StyleBoxFlat = _selected_style if selected else (_filled_style if item != null else _empty_style)
		slot_panels[i].add_theme_stylebox_override("panel", style)

		var color: Color
		if selected:
			color = Color(1.0, 0.86, 0.45)
		elif item != null:
			color = Color(0.92, 0.94, 0.96)
		else:
			color = Color(0.55, 0.58, 0.62)
		slot_labels[i].add_theme_color_override("font_color", color)


func _style_labels() -> void:
	prompt_label.add_theme_font_size_override("font_size", 18)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68))
	prompt_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	prompt_label.add_theme_constant_override("outline_size", 6)

	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(0.95, 0.96, 0.98))

	strike_label.add_theme_font_size_override("font_size", 17)
	strike_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	strike_label.add_theme_constant_override("outline_size", 5)

	for label: Label in slot_labels:
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
		label.add_theme_constant_override("outline_size", 4)

	var bar: HBoxContainer = $InventoryBar
	bar.add_theme_constant_override("separation", 10)


func _build_styles() -> void:
	_empty_style = _make_slot_style(Color(0.04, 0.05, 0.07, 0.72), Color(0.2, 0.23, 0.27, 0.8))
	_filled_style = _make_slot_style(Color(0.06, 0.08, 0.11, 0.8), Color(0.35, 0.4, 0.46, 0.9))
	_selected_style = _make_slot_style(Color(0.1, 0.09, 0.05, 0.88), Color(1.0, 0.78, 0.32, 1.0))

	var message_style := StyleBoxFlat.new()
	message_style.bg_color = Color(0.03, 0.04, 0.06, 0.85)
	message_style.border_color = Color(0.35, 0.4, 0.46, 0.9)
	message_style.set_border_width_all(1)
	message_style.set_corner_radius_all(8)
	message_style.content_margin_left = 22.0
	message_style.content_margin_right = 22.0
	message_style.content_margin_top = 12.0
	message_style.content_margin_bottom = 12.0
	message_panel.add_theme_stylebox_override("panel", message_style)


func _make_slot_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
