extends Interactable

class_name Matchbox

## Matchbox from the bathroom table. Injected with its ItemData by ItemSpawner.

@export var item: ItemData = null


func set_item(value: ItemData) -> void:
	item = value


func get_prompt() -> String:
	if item == null:
		return "Agarrar fósforos"
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
