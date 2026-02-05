extends Camera3D
class_name DollyCameraNode

var StartFov: float = 45
var EndFov  : float = 1.0
var StartZ  : float = 12
var Speed   : float = 5.0

var TargetHeight: float = 0.0
const LERP_SPEED     : float = 5.0
const MAX_VERT_DELTA : float = 1.5
const MIN_VERT_DELTA : float = -0.5
const STARTING_HEIGHT: float = 1.5

func _process(delta: float) -> void:
	var vert_diff: float = TargetHeight-(position.y-STARTING_HEIGHT)
	position.y = lerpf(position.y, TargetHeight+STARTING_HEIGHT, abs(vert_diff)*LERP_SPEED*delta)
	if TheLawsOfTheLand.Paused: return
	var target_fov = EndFov if TheLawsOfTheLand.Perspective else StartFov
	fov = lerpf(fov, target_fov, delta * Speed)
	var fov_ratio = tan(deg_to_rad(StartFov/2.0)) / tan(deg_to_rad(fov/2.0))
	position.z = StartZ*fov_ratio
	near = position.z - (StartZ - 0.05)
