extends Resource

class_name ItemData

## Minimal inventory item definition.
## Only the data the demo needs: an id, a display name and an optional icon.

@export var id: StringName = &""
@export var display_name: String = ""
@export var icon: Texture2D = null

## Scene shown attached to the camera when this item is selected.
@export var held_scene: PackedScene = null
## Scene spawned in the world when the player drops this item.
@export var dropped_scene: PackedScene = null
