extends Interactable

class_name KeyPickup

## Collectible key: adds its ItemData to the inventory and disappears.

@export var item: ItemData = null


func get_prompt() -> String:
	if item == null:
		return "Agarrar"
	return "Agarrar %s" % item.display_name.to_lower()


func interact() -> String:
	if item == null:
		return ""
	if not Inventory.add_item(item):
		return "No tenés espacio en el inventario."
	var collected_name: String = item.display_name
	queue_free()
	return "Agarraste: %s." % collected_name
