extends Node3D

class_name Wardrobe

## Wardrobe controller: drops the bedroom key into the open safe once the
## puzzle is solved.

const KEY_SCENE: PackedScene = preload("res://scenes/collectibles/Key.tscn")
const KEY_ITEM: ItemData = preload("res://resources/items/key_bedroom.tres")

@onready var key_spawn: Marker3D = $KeySpawn

var _key_spawned: bool = false


func _ready() -> void:
	PuzzleManager.safe_solved_changed.connect(_on_safe_solved)
	if PuzzleManager.safe_solved:
		_spawn_key()


func _on_safe_solved() -> void:
	_spawn_key()


func _spawn_key() -> void:
	if _key_spawned:
		return
	_key_spawned = true
	var key: KeyPickup = KEY_SCENE.instantiate() as KeyPickup
	key.set_item(KEY_ITEM)
	key_spawn.add_child(key)
