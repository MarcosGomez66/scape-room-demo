extends Node

## Random 3-of-5 color puzzle data. Generated once at startup and on restart.
## The pictures use three chosen colors, while the safe expects them in a
## second, independent random order.

signal safe_solved_changed

const COLORS: Array[Dictionary] = [
	{
		"id": &"magenta",
		"display_name": "Orquídea",
		"clue": "Elegancia simétrica de pétalos delicados sobre tallos firmes.",
		"texture": "res://assets/test/img/orquidea_magenta.jpg",
	},
	{
		"id": &"amarillo",
		"display_name": "Taxi",
		"clue": "Un bólido urbano cruzando el asfalto caótico.",
		"texture": "res://assets/test/img/taxi_amarillo.jpg",
	},
	{
		"id": &"azul",
		"display_name": "Globo",
		"clue": "El mundo entero girando suavemente en una esfera de escritorio.",
		"texture": "res://assets/test/img/globo_azul.jpg",
	},
	{
		"id": &"rojo",
		"display_name": "Teléfono",
		"clue": "Una centinela de hierro en la acera que guarda voces perdidas.",
		"texture": "res://assets/test/img/telefono_rojo.jpg",
	},
	{
		"id": &"verde",
		"display_name": "Cactus",
		"clue": "Una fortaleza viviente de espinas y pliegues que desafía la sequedad.",
		"texture": "res://assets/test/img/cactus_verde.jpg",
	},
]

## Colors hung on the three picture frames, in any order.
var picture_colors: Array[StringName] = []
## Colors the player has to press, in the exact solution order.
var sequence: Array[StringName] = []
var safe_solved: bool = false


func _ready() -> void:
	randomize()
	generate()


## Picks three distinct colors for the pictures and a separate random order
## for the safe. Also clears the solved state so a restart starts fresh.
func generate() -> void:
	var pool: Array[StringName] = []
	for color: Dictionary in COLORS:
		pool.append(color["id"] as StringName)
	pool.shuffle()
	picture_colors.assign([pool[0], pool[1], pool[2]])
	sequence.assign(picture_colors)
	sequence.shuffle()
	safe_solved = false


func color_data(color_id: StringName) -> Dictionary:
	for color: Dictionary in COLORS:
		if color["id"] == color_id:
			return color
	return {}


func texture_for(color_id: StringName) -> Texture2D:
	var data: Dictionary = color_data(color_id)
	if data.is_empty():
		return null
	return load(data["texture"]) as Texture2D


func clue_for(color_id: StringName) -> String:
	return str(color_data(color_id).get("clue", ""))


func check_answer(attempt: Array[StringName]) -> bool:
	return attempt == sequence


func mark_solved() -> void:
	if safe_solved:
		return
	safe_solved = true
	safe_solved_changed.emit()
