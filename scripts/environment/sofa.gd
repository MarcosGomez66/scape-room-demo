extends StaticBody3D

class_name Sofa

## Living-room sofa for the second puzzle. The GLB's baked cushions stay
## visible; each one gets a removable pillow on top. The readable card rests
## between a baked cushion and its pillow, so picking the pillow up reveals it.

const PILLOW_SCENE: PackedScene = preload("res://scenes/collectibles/Pillow.tscn")
const PILLOW_ITEM: ItemData = preload("res://resources/items/pillow.tres")
const CARD_SCENE: PackedScene = preload("res://scenes/collectibles/Card.tscn")
const SPOT_PATHS: Array[NodePath] = [^"PillowSpot0", ^"PillowSpot1", ^"PillowSpot2"]
const COVER_RADIUS: float = 0.24

var card_slot: int = 0
var _card: Card = null


func _ready() -> void:
	add_to_group("sofa_controller")
	card_slot = randi_range(0, SPOT_PATHS.size() - 1)
	_card = CARD_SCENE.instantiate() as Card
	add_child(_card)
	var card_spot: Node3D = get_node(SPOT_PATHS[card_slot]) as Node3D
	# Sandwiched between the baked cushion below and the pillow above.
	_card.global_position = card_spot.global_position + Vector3(0.0, 0.0, 0.0)
	for path: NodePath in SPOT_PATHS:
		var spot: Node3D = get_node(path) as Node3D
		var pillow: Pillow = PILLOW_SCENE.instantiate() as Pillow
		pillow.set_item(PILLOW_ITEM)
		add_child(pillow)
		pillow.global_position = spot.global_position
	refresh_cover()


## Hides the card whenever a pillow is sitting on top of it.
func refresh_cover() -> void:
	if _card == null or not is_instance_valid(_card):
		return
	var covered: bool = false
	for node: Node in get_tree().get_nodes_in_group("sofa_pillow"):
		var pillow: Pillow = node as Pillow
		if pillow == null or not pillow.is_inside_tree():
			continue
		var delta: Vector2 = Vector2(
			pillow.global_position.x - _card.global_position.x,
			pillow.global_position.z - _card.global_position.z
		)
		if delta.length() < COVER_RADIUS:
			covered = true
			break
	_card.set_covered(covered)
