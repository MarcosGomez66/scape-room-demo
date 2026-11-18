extends Interactable

class_name NoteItem

## Readable note inside the desk drawer. Opens the modal note window.


func get_prompt() -> String:
	return "Leer nota"


func interact() -> String:
	PuzzleUI.open_note()
	return ""
