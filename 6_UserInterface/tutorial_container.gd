extends Control

@onready var pause_menu_prompts = preload("res://6_UserInterface/all_controls.tscn")
@onready var prompt_movejump = preload("res://6_UserInterface/prompt_movejump.tscn")
@onready var prompt_placeblock = preload("res://6_UserInterface/prompt_placeblock.tscn")
@onready var prompt_shift = preload("res://6_UserInterface/prompt_shift.tscn")
@onready var prompt_reset = preload("res://6_UserInterface/prompt_reset.tscn")

var current_level = 0
var has_shown_prompt_movejump = false
var has_shown_prompt_placeblock = false
var has_shown_prompt_shift = false
var has_shown_prompt_reset = false

const prompt_max_screentime = 5.0
var prompt_onscreen_timer = 0.0

var SCREENSIZE : Vector2
var prompt_offscreen_position : Vector2
var prompt_onscreen_position : Vector2

func _ready():
	## CONNECT PAUSED SIGNAL
	TheLawsOfTheLand.paused_changed.connect(_on_pause_toggle)
	
	reset_prompt_positions()
	if current_level == 0 and has_shown_prompt_movejump == false:
		var new_move_prompt = prompt_movejump.instantiate()
		add_child(new_move_prompt)
		new_move_prompt.position = prompt_offscreen_position
		has_shown_prompt_movejump = true

func _on_pause_toggle(paused: bool):
	reset_prompt_positions()
	if paused:
		var pause_prompts = pause_menu_prompts.instantiate()
		add_child(pause_prompts)
		pause_prompts.name = "pausemenu"
		move_child(pause_prompts,0)
		pause_prompts.position = Vector2.ZERO
	else:
		get_child(0).queue_free()

func _process(delta):
	if TheLawsOfTheLand.Paused: return
	if get_child_count() != 0:
		var current_prompt = get_child(0)
		prompt_onscreen_timer += delta
		if prompt_onscreen_timer < prompt_max_screentime:
			current_prompt.position = current_prompt.position.lerp( prompt_onscreen_position , prompt_onscreen_timer )
		else:
			current_prompt.position = current_prompt.position.lerp(prompt_offscreen_position, ( prompt_onscreen_timer - prompt_max_screentime ) )
			if current_prompt.position == prompt_offscreen_position:
				get_child(0).queue_free()
				prompt_onscreen_timer = 0.0

func reset_prompt_positions():
	## SCREENSIZE SETUP FOR PROMPT PLACEMENT
	SCREENSIZE = get_viewport().size
	prompt_offscreen_position =  Vector2((SCREENSIZE.x/2), -(SCREENSIZE.y/2))
	prompt_onscreen_position = SCREENSIZE/2 + (Vector2i.UP * SCREENSIZE.y/3)

## KEEPS TRACK OF WHICH LEVEL WE ARE ON
func _on_level_ring_reset_level(lvl, height):
	current_level = lvl
	
	if current_level == 2 and has_shown_prompt_shift == false:
		var new_shift_prompt = prompt_shift.instantiate()
		add_child(new_shift_prompt)
		new_shift_prompt.position = prompt_offscreen_position
		has_shown_prompt_shift = true
	
	if current_level == 3 and has_shown_prompt_reset == false:
		var new_reset_prompt = prompt_reset.instantiate()
		add_child(new_reset_prompt)
		new_reset_prompt.position = prompt_offscreen_position
		has_shown_prompt_reset = true

## REVEALS PICKUP PROMPT IF CURRENT LEVEL IS 1
func _on_tiny_wizard_pickup_block(type):
	if current_level == 1 and has_shown_prompt_placeblock == false:
		var new_place_prompt = prompt_placeblock.instantiate()
		add_child(new_place_prompt)
		new_place_prompt.position = prompt_offscreen_position
		has_shown_prompt_placeblock = true
