extends Node2D
class_name ScrollDisplayNode

@onready var Scroll: Sprite2D = $Scroll

var current_level = 0
var has_shown_prompt_movejump = false
var has_shown_prompt_placeblock = false
var has_shown_prompt_shift = false
var has_shown_prompt_reset = false


enum ScrollStates {START, SHOW, END}
var ScrollState: ScrollStates = ScrollStates.START

var scroll_start_pos: Vector2
var scroll_show_pos : Vector2
var scroll_end_pos  : Vector2
var scroll_show_rot : float
const MAX_SCROLL_ROT: float =  20.0
const MIN_SCROLL_ROT: float = -20.0
const SCROLL_LERP_SPEED: float = 3.0

const MOVE_SCROLL   : Texture = preload("res://6_UserInterface/scrolls/freedom_of_movement_scroll.png")
const PLACE_SCROLL  : Texture = preload("res://6_UserInterface/scrolls/support_conjouring_scroll.png")
const SHIFT_SCROLL  : Texture = preload("res://6_UserInterface/scrolls/planar_manipulation_scroll.png")
const RESTORE_SCROLL: Texture = preload("res://6_UserInterface/scrolls/restoration_scroll.png")
const PAUSE_SCROLL_MOVE : Texture = preload("res://6_UserInterface/scrolls/pause_scroll_move.png")
const PAUSE_SCROLL_PLACE: Texture = preload("res://6_UserInterface/scrolls/pause_scroll_place.png")
const PAUSE_SCROLL_RESET: Texture = preload("res://6_UserInterface/scrolls/pause_scroll_reset.png")
const PAUSE_SCROLL_SHIFT: Texture = preload("res://6_UserInterface/scrolls/pause_scroll_shift.png")

func _ready():
	## CONNECT PAUSE SIGNAL
	TheLawsOfTheLand.paused_changed.connect(_on_pause_toggle)
	
	## SCREENSIZE SETUP FOR PROMPT PLACEMENT
	get_viewport().size_changed.connect(_on_screen_size_changed)

func _on_screen_size_changed() -> void:
	if not Scroll.texture: return
	var screensize: Vector2 = get_viewport().size
	
	scroll_start_pos = Vector2(screensize.x/2,  5*(screensize.y/2))
	scroll_show_pos  = Vector2(screensize.x/2,    (screensize.y/2))
	scroll_end_pos   = Vector2(screensize.x/2, -5*(screensize.y/2))
	scroll_show_rot  = randf_range(MIN_SCROLL_ROT, MAX_SCROLL_ROT)
	
	Scroll.position = scroll_start_pos
	ScrollState = ScrollStates.START
	
	var scroll_size := Scroll.texture.get_size()
	var padding: float = 1.05
	var size_ratio  := screensize / (scroll_size*padding)
	var ratio = min(size_ratio.x, size_ratio.y)
	
	Scroll.scale = Vector2(ratio, ratio)

func _on_pause_toggle(paused: bool):
	if paused and Input.is_action_just_pressed("pause"):
		change_scroll_texture(
			PAUSE_SCROLL_RESET if has_shown_prompt_reset else 
			PAUSE_SCROLL_SHIFT if has_shown_prompt_shift else
			PAUSE_SCROLL_PLACE if has_shown_prompt_placeblock else 
			PAUSE_SCROLL_MOVE)
	elif not paused:
		ScrollState = ScrollStates.END

func _process(delta: float) -> void:
	if not Scroll.texture: return
	
	match ScrollState:
		ScrollStates.START:
			TheLawsOfTheLand.Paused = true
			Scroll.position.y = lerp(Scroll.position.y, scroll_show_pos.y, delta*SCROLL_LERP_SPEED)
			Scroll.rotation_degrees = lerp(Scroll.rotation_degrees, scroll_show_rot, delta*SCROLL_LERP_SPEED)
			if abs(Scroll.position.y-scroll_show_pos.y) < 30:
				ScrollState = ScrollStates.SHOW
		ScrollStates.SHOW:
			if Input.is_action_just_pressed("pause") and \
				(Scroll.texture == PAUSE_SCROLL_MOVE or  \
				Scroll.texture == PAUSE_SCROLL_PLACE or  \
				Scroll.texture == PAUSE_SCROLL_RESET or  \
				Scroll.texture == PAUSE_SCROLL_SHIFT):
				ScrollState = ScrollStates.END
				TheLawsOfTheLand.Paused = false
			elif (Input.is_action_just_pressed("move_left") \
				or Input.is_action_just_pressed("move_right")\
				or Input.is_action_just_pressed("jump")) and \
				not (Scroll.texture == PAUSE_SCROLL_MOVE or  \
					Scroll.texture == PAUSE_SCROLL_PLACE or  \
					Scroll.texture == PAUSE_SCROLL_RESET or  \
					Scroll.texture == PAUSE_SCROLL_SHIFT):
				ScrollState = ScrollStates.END
				TheLawsOfTheLand.Paused = false
		ScrollStates.END:
			Scroll.position.y = lerp(Scroll.position.y, scroll_end_pos.y, delta*SCROLL_LERP_SPEED)

func change_scroll_texture(new_tex: Texture) -> void:
	Scroll.texture = new_tex
	_on_screen_size_changed()


## KEEPS TRACK OF WHICH LEVEL WE ARE ON
func _on_level_ring_reset_level(lvl, height):
	current_level = lvl
	
	if current_level == 0 and has_shown_prompt_movejump == false:
		change_scroll_texture(MOVE_SCROLL)
		has_shown_prompt_movejump = true
	
	if current_level == 2 and has_shown_prompt_shift == false:
		await get_tree().create_timer(0.5).timeout
		change_scroll_texture(SHIFT_SCROLL)
		has_shown_prompt_shift = true
	
	if current_level == 3 and has_shown_prompt_reset == false:
		await get_tree().create_timer(0.5).timeout
		change_scroll_texture(RESTORE_SCROLL)
		has_shown_prompt_reset = true

## REVEALS PICKUP PROMPT IF CURRENT LEVEL IS 1
func _on_tiny_wizard_pickup_block(type):
	if current_level == 1 and has_shown_prompt_placeblock == false:
		change_scroll_texture(PLACE_SCROLL)
		has_shown_prompt_placeblock = true
