extends StaticBody3D

@onready var mesh_itself = $Mesh
var time = 0.0
var rotate_speed = 0.5
var bobbing_speed = 0.25
var bobbing_depth = 0.1

func _process(delta):
	time += delta
	mesh_itself.rotate(Vector3.UP, delta * rotate_speed)
	mesh_itself.position.y = -0.25 + (sin(time * bobbing_speed) * bobbing_depth)

func identify_yourself() -> LevelRingNode.BlockTypes:
	return LevelRingNode.BlockTypes.OBJ_MSC
