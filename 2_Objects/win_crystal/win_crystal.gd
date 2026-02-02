extends StaticBody3D

@onready var mesh_itself : MeshInstance3D = $Mesh
var time = 0.0
var bobbing_speed = 1.5
var bobbing_depth = 0.05
var pulsing_speed = 0.6
var pulsing_depth = 0.15

func _process(delta):
	time += delta
	mesh_itself.position.y = -0.25 + (sin(time * bobbing_speed) * bobbing_depth)
	var scale = 0.5 + (sin(time * pulsing_speed) * pulsing_depth)
	mesh_itself.scale = Vector3(scale,scale,scale)

func identify_yourself() -> LevelRingNode.BlockTypes:
	return LevelRingNode.BlockTypes.OBJ_END
