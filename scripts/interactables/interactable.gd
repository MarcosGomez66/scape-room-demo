extends StaticBody3D

class_name Interactable

## Base class for anything the player can look at and use with E.
## Interactables that should not block the player only need the interactable
## physics layer (layer 4 / bit value 8); solid ones also stay on layer 1.

@export var prompt_text: String = "Interactuar"
@export var enabled: bool = true


## Text shown under the crosshair while this object is aimed at.
func get_prompt() -> String:
	return prompt_text


## Runs the interaction. Returns a message for the HUD, or "" for none.
func interact() -> String:
	return ""
