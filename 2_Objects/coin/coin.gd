extends StaticBody3D

@onready var mesh_itself = $Mesh
var time = 0.0
var rotate_speed = 0.5

func _process(delta):
	time += delta
	mesh_itself.rotate(Vector3.UP, delta * rotate_speed)

func identify_yourself() -> LevelRingNode.BlockTypes:
	return LevelRingNode.BlockTypes.OBJ_MSC
