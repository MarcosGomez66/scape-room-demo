extends Interactable

class_name Pillow

## Removable sofa cushion. It goes to the inventory with E and can be dropped
## again with F; the sofa watches the group to hide or reveal the card.

@export var item: ItemData = null


func _ready() -> void:
	add_to_group("sofa_pillow")


func set_item(value: ItemData) -> void:
	item = value


func get_prompt() -> String:
	if item == null:
		return "Agarrar almohada"
	return "Agarrar %s" % item.display_name.to_lower()


func interact() -> String:
	if item == null:
		return ""
	if not Inventory.add_item(item):
		return "No tenés espacio en el inventario."
	remove_from_group("sofa_pillow")
	for node: Node in get_tree().get_nodes_in_group("sofa_controller"):
		if node.has_method("refresh_cover"):
			node.call("refresh_cover")
	queue_free()
	return "Agarraste: %s." % item.display_name
