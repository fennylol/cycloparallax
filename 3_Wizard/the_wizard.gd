extends CharacterBody3D
class_name TinyWizardNode
# ========= #
# constants #
# ========= #
const WALK_TIME  : float = 0.25
const WALK_ACCEL : float = 10.0
const WALK_SPEED : float = 0.60
const COYOTE_TIME: float = 0.15
const JUMP_SPEED : float = 3.0
const JUMP_TIME  : float = 0.225
const GRAVITY    : float = 20.0
const SPRITES    : Array[Texture] = [
	preload("res://3_Wizard/sprites/Perilacks.png"),
	preload("res://3_Wizard/sprites/Perilacks_cw.png"),
	preload("res://3_Wizard/sprites/Perilacks_ccw.png")
]
const STEP_SOUNDS: Array[Resource] = [
	preload("res://3_Wizard/sounds/step_0.mp3"),
	preload("res://3_Wizard/sounds/step_1.mp3"),
	preload("res://3_Wizard/sounds/step_2.mp3"),
	preload("res://3_Wizard/sounds/step_3.mp3"),
	preload("res://3_Wizard/sounds/step_4.mp3"),
	preload("res://3_Wizard/sounds/step_5.mp3"),
	preload("res://3_Wizard/sounds/step_6.mp3"),
	preload("res://3_Wizard/sounds/step_7.mp3"),
	preload("res://3_Wizard/sounds/step_8.mp3"),
	preload("res://3_Wizard/sounds/step_9.mp3")
]
# ========= #
# variables #
# ========= #
enum PlacementDirections {UP, RIGHT, DOWN, LEFT}
signal placing_block(dir: PlacementDirections)
var WalkingTimer     : float     = 0.0
var WalkingSpeed     : float     = 0.0
var CoyoteTimeLeft   : float     = COYOTE_TIME
var JumpTimeLeft     : float     = 0.0
var LastSpriteCW     : bool      = true
@onready var LArmRay : RayCast3D = $LeftArm
@onready var LLegRay : RayCast3D = $LeftLeg
@onready var LFootRay: RayCast3D = $LeftFoot
@onready var RArmRay : RayCast3D = $RightArm
@onready var RLegRay : RayCast3D = $RightLeg
@onready var RFootRay: RayCast3D = $RightFoot
@onready var Sprite  : Sprite3D  = $Sprite
@onready var Mouth   : AudioStreamPlayer = $Mouth

func _process(delta: float)  -> void:
	if TheLawsOfTheLand.Paused: return
	## ------------
	##   MOVEMENT
	## ------------
	if Input.is_action_just_pressed("jump"):
		if CoyoteTimeLeft > 0.0:
			JumpTimeLeft = JUMP_TIME
	if Input.is_action_just_released("jump"):
		CoyoteTimeLeft = 0.0
		JumpTimeLeft = 0.0
	
	if Input.is_action_pressed("jump"):
		CoyoteTimeLeft  = 0.0
		if JumpTimeLeft > 0.0:
			JumpTimeLeft -= delta
			velocity.y = JUMP_SPEED
		elif velocity.y > 0.0:
			velocity.y -= delta * GRAVITY * 0.5
		else:
			velocity.y -= delta * GRAVITY
	else:
		velocity.y -= delta * GRAVITY
		if is_underside_blocked():
			CoyoteTimeLeft  = COYOTE_TIME
		else:
			CoyoteTimeLeft -= delta
	
	var direction: int = int(Input.is_action_pressed("move_left"))-int(Input.is_action_pressed("move_right"))
	if direction : WalkingSpeed = lerpf(WalkingSpeed, direction*WALK_SPEED, delta*WALK_ACCEL)
	else         : WalkingSpeed = move_toward(WalkingSpeed, 0.0, delta*WALK_ACCEL)
	if is_left_side_blocked() : WalkingSpeed = min(0.0, WalkingSpeed)
	if is_right_side_blocked(): WalkingSpeed = max(0.0, WalkingSpeed)
	
	if WalkingSpeed != 0.0 and is_underside_blocked():
		WalkingTimer += delta
	if WalkingTimer > WALK_TIME:
		WalkingTimer = fmod(WalkingTimer, WALK_TIME)
		walk_cycle()
	
	move_and_slide()
	## -------------
	##   SET BLOCK
	## -------------
	if Input.is_action_just_released("place_up"): placing_block.emit(PlacementDirections.UP)
	if Input.is_action_just_released("place_left"): placing_block.emit(PlacementDirections.LEFT)
	if Input.is_action_just_released("place_down"): placing_block.emit(PlacementDirections.DOWN)
	if Input.is_action_just_released("place_right"): placing_block.emit(PlacementDirections.RIGHT)
	

func is_underside_blocked()  -> bool: return (LFootRay.is_colliding() and LFootRay.get_collider().is_in_group("Ground")) or \
											 (RFootRay.is_colliding() and RFootRay.get_collider().is_in_group("Ground"))
func is_left_side_blocked()  -> bool: return (LArmRay.is_colliding()  and LArmRay.get_collider().is_in_group("Ground"))  or \
											 (LLegRay.is_colliding()  and LLegRay.get_collider().is_in_group("Ground"))
func is_right_side_blocked() -> bool: return (RArmRay.is_colliding()  and RArmRay.get_collider().is_in_group("Ground"))  or \
											 (RLegRay.is_colliding()  and RLegRay.get_collider().is_in_group("Ground"))

func walk_cycle()            -> void:
	if Sprite.texture != SPRITES[0]:
		Sprite.texture = SPRITES[0]
		LastSpriteCW = not LastSpriteCW
		Mouth.stream = STEP_SOUNDS[floor(randf()*STEP_SOUNDS.size())]
		Mouth.play(0.0)
	elif LastSpriteCW: Sprite.texture = SPRITES[1]
	else: Sprite.texture = SPRITES[2]
