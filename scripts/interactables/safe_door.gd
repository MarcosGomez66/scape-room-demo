extends Interactable

class_name SafeDoor

## Safe door inside the wardrobe. Interacting opens the modal puzzle; solving
## the puzzle swings the door open for good, even while the modal paused the
## scene tree. The buttons live on the leaf in the GLB, so they are reparented
## too and swing with it.

const DOOR_PARTS: Array[String] = [
	"SM_Hoja",
	"SM_Boton", "SM_Boton_001", "SM_Boton_002", "SM_Boton_003", "SM_Boton_004",
]

@export var open_angle_degrees: float = 90.0
@export var open_time: float = 0.9

@onready var model: Node3D = get_node("../Model") as Node3D

var _tween: Tween


func _ready() -> void:
	for part_name: String in DOOR_PARTS:
		_take_part(part_name)
	PuzzleManager.safe_solved_changed.connect(_on_safe_solved)
	if PuzzleManager.safe_solved:
		_open(false)


func get_prompt() -> String:
	return "Abrir caja fuerte"


func interact() -> String:
	PuzzleUI.open_safe()
	return ""


func _on_safe_solved() -> void:
	_open(true)


func _open(animated: bool) -> void:
	enabled = false
	collision_layer = 0
	if _tween != null:
		_tween.kill()
	if not animated:
		rotation.y = deg_to_rad(open_angle_degrees)
		return
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "rotation:y", deg_to_rad(open_angle_degrees), open_time)


func _take_part(part_name: String) -> void:
	var part: Node3D = model.get_node_or_null(part_name) as Node3D
	if part != null:
		part.reparent(self, true)
