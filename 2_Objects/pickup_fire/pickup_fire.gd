extends StaticBody3D

@onready var mesh_container = $Node3D
@onready var mesh_itself = $Node3D/Mesh
var time = 0.0
var rotate_speed = 1.0
var bobbing_speed = 1.5
var bobbing_depth = 0.1

func _process(delta):
	time += delta
	mesh_itself.rotate(Vector3.UP, delta * rotate_speed)
	mesh_container.position.y = -0.25 + (sin(time * bobbing_speed) * bobbing_depth)

func identify_yourself() -> LevelRingNode.BlockTypes:
	return LevelRingNode.BlockTypes.PLT_FIR
