extends Interactable

class_name DeskDrawer

## Desk drawer: pulling it out reveals the white paper and enables the note.

const MOVING_PARTS: Array[String] = [
	"SM_Frente", "SM_Pomo", "SM_Base", "SM_Der_001", "SM_Izq_001", "SM_Atras_001"
]

@export var pull_distance: float = 0.3
@export var pull_time: float = 0.5

@onready var model: Node3D = get_node("../Model") as Node3D
@onready var note: Interactable = $Note

var _open: bool = false


func _ready() -> void:
	for part_name: String in MOVING_PARTS:
		var part: Node3D = model.get_node_or_null(part_name) as Node3D
		if part != null:
			part.reparent(self, true)
	note.enabled = false
	note.visible = false


func get_prompt() -> String:
	return "Abrir cajón"


func interact() -> String:
	if _open:
		return ""
	_open = true
	enabled = false
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:z", pull_distance, pull_time)
	tween.finished.connect(_on_pull_finished)
	return "Abriste el cajón. Hay una nota adentro."


func _on_pull_finished() -> void:
	collision_layer = 0
	note.collision_layer = 8
	note.enabled = true
	note.visible = true
