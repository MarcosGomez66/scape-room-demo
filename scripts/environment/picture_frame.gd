extends Node3D

class_name PictureFrame

## Wall picture used by the color puzzle. By default each instance takes one
## of the three generated colors; picture_color and texture_override allow
## assigning a specific image when placing the frame.
##
## The imported GLB image plate samples only one quadrant of its atlas and
## swaps the UV axes, so it is replaced at runtime with a clean quad.

const PICTURE_SIZE: Vector2 = Vector2(0.40, 0.30)
const PICTURE_LOCAL_POSITION: Vector3 = Vector3(0.0, 0.17, 0.002)

@export var picture_slot: int = 0
@export var picture_color: StringName = &""
@export var texture_override: Texture2D = null

@onready var image: MeshInstance3D = $Model/SM_Img


func _ready() -> void:
	var color_id: StringName = picture_color
	if color_id == &"" and picture_slot >= 0 and picture_slot < PuzzleManager.picture_colors.size():
		color_id = PuzzleManager.picture_colors[picture_slot]
	var texture: Texture2D = texture_override
	if texture == null and color_id != &"":
		texture = PuzzleManager.texture_for(color_id)
	if texture == null:
		return
	_replace_plate()
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	image.material_override = material


## Swaps the imported atlas-mapped plate for a quad with plain 0-1 UVs.
func _replace_plate() -> void:
	var quad := QuadMesh.new()
	quad.size = PICTURE_SIZE
	image.mesh = quad
	image.position = PICTURE_LOCAL_POSITION
