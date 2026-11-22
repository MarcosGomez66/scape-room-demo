extends Area3D

class_name ExitTrigger

## Fires the win screen when the player walks out through the main door.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is PlayerController:
		GameManager.win_game()
