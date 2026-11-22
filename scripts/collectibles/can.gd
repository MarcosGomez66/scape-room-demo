extends Interactable

class_name CanPickup

## Food can from the fridge. It can be carried, dropped with F, and later
## placed on the stove. The stove drives the cooking animation and lid burst.

const KEY_SCENE: PackedScene = preload("res://scenes/collectibles/Key.tscn")
const KEY_ITEM: ItemData = preload("res://resources/items/key_main.tres")

@export var item: ItemData = null

var _vibrating: bool = false
var _elapsed: float = 0.0
var _body_base: Vector3 = Vector3.ZERO


func set_item(value: ItemData) -> void:
	item = value


func get_prompt() -> String:
	if item == null:
		return "Agarrar lata"
	return "Agarrar %s" % item.display_name.to_lower()


func interact() -> String:
	if item == null:
		return ""
	if not Inventory.add_item(item):
		return "No tenés espacio en el inventario."
	var collected_name: String = item.display_name
	var glow: Node = get_node_or_null("Glow")
	if glow != null:
		glow.queue_free()
	queue_free()
	return "Agarraste: %s." % collected_name


func start_cooking() -> void:
	enabled = false
	collision_layer = 0
	var body: Node3D = get_node_or_null("Model/SM_Cuerpo") as Node3D
	if body != null:
		_body_base = body.position
	_vibrating = true
	set_process(true)


func burst() -> void:
	_vibrating = false
	set_process(false)
	var lid: Node3D = get_node_or_null("Model/SM_Tapa") as Node3D
	if lid != null:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(lid, "position:y", lid.position.y + 0.85, 0.5)
		tween.parallel().tween_property(lid, "rotation:z", deg_to_rad(150.0), 0.5)
	var spawn: Marker3D = get_node_or_null("KeySpawn") as Marker3D
	if spawn == null:
		return
	var key: KeyPickup = KEY_SCENE.instantiate() as KeyPickup
	if key == null:
		return
	key.set_item(KEY_ITEM)
	add_child(key)
	key.global_position = spawn.global_position


func _process(delta: float) -> void:
	if not _vibrating:
		return
	_elapsed += delta
	var body: Node3D = get_node_or_null("Model/SM_Cuerpo") as Node3D
	if body == null:
		return
	body.position = _body_base + Vector3(
		sin(_elapsed * 62.0) * 0.012,
		0.0,
		cos(_elapsed * 77.0) * 0.012,
	)
