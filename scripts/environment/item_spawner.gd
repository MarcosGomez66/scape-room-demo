extends Node3D

class_name ItemSpawner

## Generic prop placer. Spawns a scene at this node and injects its ItemData
## with set_item(), following the no-resource-cycle pattern used by the key.

@export var spawn_scene: PackedScene = null
@export var item: ItemData = null
@export var spawn_on_ready: bool = true


func _ready() -> void:
	if spawn_on_ready:
		spawn()


func spawn() -> Node:
	if spawn_scene == null:
		return null
	var instance: Node = spawn_scene.instantiate()
	add_child(instance)
	if instance is Node3D:
		(instance as Node3D).position = Vector3.ZERO
	if item != null and instance.has_method("set_item"):
		instance.call("set_item", item)
	return instance
