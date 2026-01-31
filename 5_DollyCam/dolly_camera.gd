extends Camera3D
class_name DollyCameraNode

var StartFov: float = 45
var EndFov  : float = 1.0
var StartZ  : float = 12
var Speed   : float = 5.0
var Zooming : bool  = false

func _process(delta: float) -> void:
	var target_fov = EndFov if Zooming else StartFov
	fov = lerpf(fov, target_fov, delta * Speed)
	
	var fov_ratio = tan(deg_to_rad(StartFov/2.0)) / tan(deg_to_rad(fov/2.0))
	position.z = StartZ*fov_ratio
	
	near = position.z - (StartZ - 0.05)
