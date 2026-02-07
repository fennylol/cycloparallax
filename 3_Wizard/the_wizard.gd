extends CharacterBody3D
class_name TinyWizardNode
# ========= #
# constants #
# ========= #
const WALK_TIME  : float = 0.25
const WALK_ACCEL : float = 10.0
const WALK_SPEED : float = 0.60
const COYOTE_TIME: float = 0.15
const JUMP_SPEED : float = 3.5
const JUMP_TIME  : float = 0.25
const GRAVITY    : float = 20.0
var TERMINAL_VELOCITY: float = -7.5
const PLACEMENT_FORGIVENESS : float = 0.1
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
const JUMP_SOUNDS : Array[Resource] = [
	preload("res://3_Wizard/sounds/jump_01.mp3"),
	preload("res://3_Wizard/sounds/jump_02.mp3"),
	preload("res://3_Wizard/sounds/jump_03.mp3"),
	preload("res://3_Wizard/sounds/jump_04.mp3"),
	preload("res://3_Wizard/sounds/jump_05.mp3"),
	preload("res://3_Wizard/sounds/jump_06.mp3"),
	preload("res://3_Wizard/sounds/jump_07.mp3"),
	preload("res://3_Wizard/sounds/jump_08.mp3")
]
const PICKUP_SOUNDS : Array[Resource] = [
	preload("res://3_Wizard/sounds/pickup_01.mp3"),
	preload("res://3_Wizard/sounds/pickup_02.mp3"),
	preload("res://3_Wizard/sounds/pickup_03.mp3"),
	preload("res://3_Wizard/sounds/pickup_04.mp3"),
	preload("res://3_Wizard/sounds/pickup_05.mp3"),
	preload("res://3_Wizard/sounds/pickup_06.mp3")
]
const PLACE_SOUNDS : Array[Resource] = [
	preload("res://3_Wizard/sounds/place_01.mp3"),
	preload("res://3_Wizard/sounds/place_02.mp3"),
	preload("res://3_Wizard/sounds/place_03.mp3"),
	preload("res://3_Wizard/sounds/place_04.mp3"),
	preload("res://3_Wizard/sounds/place_05.mp3"),
	preload("res://3_Wizard/sounds/place_06.mp3")
]
const HURT_SOUNDS : Array[Resource] = [
	preload("res://3_Wizard/sounds/hurt_0.mp3"),
	preload("res://3_Wizard/sounds/hurt_1.mp3"),
	preload("res://3_Wizard/sounds/hurt_2.mp3"),
	preload("res://3_Wizard/sounds/hurt_3.mp3"),
	preload("res://3_Wizard/sounds/hurt_4.mp3")
]
# ========= #
# variables #
# ========= #
enum PlacementDirections {UP, RIGHT, DOWN, LEFT}
signal pickup_block(type: LevelRingNode.BlockTypes)
signal holding_block(dir: PlacementDirections, type: LevelRingNode.BlockTypes)
signal placing_block
signal cancel_placement
signal level_complete
signal save_safe_spot
signal request_safe_spot
var WalkingTimer     : float     = 0.0
var WalkingSpeed     : float     = 0.0
var CoyoteTimeLeft   : float     = COYOTE_TIME
var JumpTimeLeft     : float     = 0.0
var placement_timer  : float     = 0.0
var clear_for_takeoff: bool      = true
var yet_to_place     : bool      = false
var LastSpriteCW     : bool      = true
var win_lockout      : bool      = false
@onready var TheBody : Area3D = $Area3D
@onready var LArmRay : RayCast3D = $LeftArm
@onready var LLegRay : RayCast3D = $LeftLeg
@onready var LFootRay: RayCast3D = $LeftFoot
@onready var RArmRay : RayCast3D = $RightArm
@onready var RLegRay : RayCast3D = $RightLeg
@onready var RFootRay: RayCast3D = $RightFoot
@onready var Sprite  : Sprite3D  = $Sprite
@onready var Mouth   : AudioStreamPlayer = $Mouth
@onready var Mouth2  : AudioStreamPlayer = $SecondMouth
@onready var Yeller  : AudioStreamPlayer = $MouthForYelling

func _process(delta: float)  -> void:
	if TheLawsOfTheLand.Paused: return
	## ------------
	##   MOVEMENT
	## ------------
	if Input.is_action_just_pressed("jump"):
		if CoyoteTimeLeft > 0.0:
			JumpTimeLeft = JUMP_TIME
			Mouth2.stream = JUMP_SOUNDS[floor(randf()*JUMP_SOUNDS.size())]
			Mouth2.play(0.0)
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
	velocity.y = max(velocity.y, TERMINAL_VELOCITY)
	
	var direction: int = int(Input.is_action_pressed("move_left"))-int(Input.is_action_pressed("move_right"))
	if direction : WalkingSpeed = lerpf(WalkingSpeed, direction*WALK_SPEED, delta*WALK_ACCEL)
	else         : WalkingSpeed = move_toward(WalkingSpeed, 0.0, delta*WALK_ACCEL)
	if is_left_side_blocked() : WalkingSpeed = min(0.0, WalkingSpeed)
	if is_right_side_blocked(): WalkingSpeed = max(0.0, WalkingSpeed)
	
	if WalkingSpeed != 0.0 and is_underside_blocked():
		WalkingTimer += delta
		if not is_location_unsafe():
			save_safe_spot.emit()
	if WalkingTimer > WALK_TIME:
		WalkingTimer = fmod(WalkingTimer, WALK_TIME)
		walk_cycle()
	
	move_and_slide()
	
	## -----------------
	##   PICKUP BLOCKS
	## -----------------
	
	var pickup_list = TheBody.get_overlapping_areas()
	if pickup_list != []:
		var type = pickup_list[0].get_parent().identify_yourself()
		
		## LEVEL COMPLETE
		if type == LevelRingNode.BlockTypes.OBJ_END:
			if not win_lockout:
				win_lockout = true
				level_complete.emit()
			else:
				return
		
		## COLLECT COIN
		elif type == LevelRingNode.BlockTypes.OBJ_MSC: 
			print("coin collected!")
			pickup_list[0].get_parent().queue_free()
		
		## COLLECT BLOCK
		else:
			pickup_block.emit(type)
			pickup_list[0].get_parent().queue_free()
			Mouth2.stream = PICKUP_SOUNDS[floor(randf()*PICKUP_SOUNDS.size())]
			Mouth2.play(0.0)
	
	## -------------
	##   SET BLOCK
	## -------------
	
	if Input.is_action_pressed("place_up")   : holding_block.emit(PlacementDirections.UP)
	if Input.is_action_pressed("place_right"): holding_block.emit(PlacementDirections.RIGHT)
	if Input.is_action_pressed("place_left") : holding_block.emit(PlacementDirections.LEFT)
	if Input.is_action_pressed("place_down") : holding_block.emit(PlacementDirections.DOWN)
	
	## ALLOW A SLIGHT DELAY TO SWITCH PLACEMENT DIRECTIONS
	if (Input.is_action_pressed("place_up") or Input.is_action_pressed("place_left") or Input.is_action_pressed("place_down") or Input.is_action_pressed("place_right")) and clear_for_takeoff:
		placement_timer = 0.0
		yet_to_place = true
	else:
		placement_timer += delta
	
	if Input.is_action_just_pressed("cancel_placement") and yet_to_place:
		cancel_placement.emit()
		clear_for_takeoff = false
		yet_to_place = false
	
	if placement_timer >= PLACEMENT_FORGIVENESS and yet_to_place and clear_for_takeoff:
		placing_block.emit()
		yet_to_place = false
		Mouth2.stream = PLACE_SOUNDS[floor(randf()*PLACE_SOUNDS.size())]
		Mouth2.play(0.0)
	
	## RESET CANCELLATIONS (AND BECOME "CLEAR FOR TAKEOFF") IF NO PLACEBLOCK BUTTONS ARE PRESSED
	if not (Input.is_action_pressed("place_up") or Input.is_action_pressed("place_left") or Input.is_action_pressed("place_down") or Input.is_action_pressed("place_right")):
		clear_for_takeoff = true

## CALLED IF A BLOCK IS ATTEMPTING TO BE HELD/PLACED WHILE NO BLOCKS IN INVENTORY
func _on_the_tower_force_cancel():
	yet_to_place = false
	clear_for_takeoff = false

## CALLED IF THE LEVEL IS RESET
func _on_level_ring_reset_level(_lvl : int, height : float):
	position.y = (height / 2) + 0.1
	await get_tree().create_timer(1.0).timeout
	win_lockout = false

func _get_hurt() -> void:
	Yeller.stream = HURT_SOUNDS[floor(randf()*HURT_SOUNDS.size())]
	Yeller.play(0.0)
	request_safe_spot.emit()

func is_location_unsafe()   -> bool:  return ((LFootRay.is_colliding() and LFootRay.get_collider().is_in_group("Unsafe")) or  \
											  (RFootRay.is_colliding() and RFootRay.get_collider().is_in_group("Unsafe")) or  \
											  (LFootRay.is_colliding() and LFootRay.get_collider().is_in_group("Unsafe")) or  \
											  (RFootRay.is_colliding() and RFootRay.get_collider().is_in_group("Unsafe")) or  \
											  (LArmRay.is_colliding()  and LArmRay.get_collider().is_in_group("Unsafe"))  or  \
											  (LLegRay.is_colliding()  and LLegRay.get_collider().is_in_group("Unsafe"))  or  \
											  (RArmRay.is_colliding()  and RArmRay.get_collider().is_in_group("Unsafe"))  or  \
											  (RLegRay.is_colliding()  and RLegRay.get_collider().is_in_group("Unsafe"))) or not \
											  (LFootRay.is_colliding() and LFootRay.get_collider().is_in_group("Ground")) or not \
											  (RFootRay.is_colliding() and RFootRay.get_collider().is_in_group("Ground"))
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
