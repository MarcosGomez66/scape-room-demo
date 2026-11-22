extends Interactable

class_name NoteItem

## Readable note. Without custom text it shows the safe clues; with text it
## reuses the same paper window for simple messages such as the fridge warning.

@export var note_title: String = ""
@export var note_text: String = ""


func get_prompt() -> String:
	return "Leer nota"


func interact() -> String:
	if note_text.is_empty():
		PuzzleUI.open_note()
	else:
		PuzzleUI.open_message(note_title, note_text)
	return ""
