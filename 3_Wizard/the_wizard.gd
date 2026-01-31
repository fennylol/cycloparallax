extends CharacterBody3D
class_name TinyWizardNode
# ========= #
# constants #
# ========= #
var COYOTE_TIME: float = 1.0
var WALK_SPEED : float = 0.75
var JUMP_SPEED : float = 8.0 
var JUMP_TIME  : float = .25
var GRAVITY    : float = 20
# ========= #
# variables #
# ========= #
var CoyoteTimeLeft   : float     = COYOTE_TIME
var TimeJumpingLeft  : float     = 0.0
@onready var LArmRay : RayCast3D = $LeftArm
@onready var LLegRay : RayCast3D = $LeftLeg
@onready var LFootRay: RayCast3D = $LeftFoot
@onready var RArmRay : RayCast3D = $RightArm
@onready var RLegRay : RayCast3D = $RightLeg
@onready var RFootRay: RayCast3D = $RightFoot

func _start_jump()           -> void:
	if CoyoteTimeLeft > 0.0: 
		TimeJumpingLeft = JUMP_TIME
#func _jump(delta: float)     -> void:
	#if TimeJumpingLeft > 0.0: 
		#TimeJumpingLeft   -= delta
		#velocity.y += delta * JUMP_ACCEL
	#else:
		#velocity.y = 0.0
func _process(delta: float)  -> void:
	if is_underside_blocked():
		CoyoteTimeLeft  = COYOTE_TIME
	else:
		CoyoteTimeLeft -= delta
	
	if TimeJumpingLeft > 0.0 and Input.is_action_pressed("jump"):
		TimeJumpingLeft -= delta
		velocity.y = JUMP_SPEED
	else:
		#velocity.y -= delta * GRAVITY
		velocity.y = 0
	
	

	move_and_slide()
func is_underside_blocked()           -> bool: return (LFootRay.is_colliding() and LFootRay.get_collider().is_in_group("Ground")) or \
											 (RFootRay.is_colliding() and RFootRay.get_collider().is_in_group("Ground"))
func is_left_side_blocked()  -> bool: return (LArmRay.is_colliding()  and LArmRay.get_collider().is_in_group("Ground")) or \
											 (LLegRay.is_colliding()  and LLegRay.get_collider().is_in_group("Ground"))
func is_right_side_blocked() -> bool: return (RArmRay.is_colliding()  and RArmRay.get_collider().is_in_group("Ground")) or \
											 (RLegRay.is_colliding()  and RLegRay.get_collider().is_in_group("Ground"))
