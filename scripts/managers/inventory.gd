extends Node

## Very small inventory for the demo: three fixed slots, one selected at a time.
## Registered as the "Inventory" autoload, so any node can query it.

signal slots_changed
signal selection_changed(slot_index: int)

const MAX_SLOTS: int = 3

var slots: Array[ItemData] = [null, null, null]
var selected_slot: int = 0


## Stores the item in the first empty slot and selects it.
## Returns false when the inventory is full or the item is null.
func add_item(item: ItemData) -> bool:
	if item == null:
		return false
	var index: int = slots.find(null)
	if index == -1:
		return false
	slots[index] = item
	selected_slot = index
	slots_changed.emit()
	selection_changed.emit(selected_slot)
	return true


func has_item(item_id: StringName) -> bool:
	return find_item(item_id) != null


func find_item(item_id: StringName) -> ItemData:
	for item: ItemData in slots:
		if item != null and item.id == item_id:
			return item
	return null


func get_selected_item() -> ItemData:
	if selected_slot < 0 or selected_slot >= slots.size():
		return null
	return slots[selected_slot]


## Removes the first item with that id. Used when a key unlocks a door.
func remove_item(item_id: StringName) -> bool:
	var index: int = -1
	for i: int in slots.size():
		if slots[i] != null and slots[i].id == item_id:
			index = i
			break
	if index == -1:
		return false
	slots[index] = null
	if selected_slot == index:
		selected_slot = _first_filled_slot()
	slots_changed.emit()
	selection_changed.emit(selected_slot)
	return true


func select_slot(index: int) -> void:
	if index < 0 or index >= slots.size() or index == selected_slot:
		return
	selected_slot = index
	selection_changed.emit(selected_slot)


func _first_filled_slot() -> int:
	for i: int in slots.size():
		if slots[i] != null:
			return i
	return 0
