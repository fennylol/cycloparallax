extends Node

var levels_completed          : Array[bool] = [false,false,false,false,false,false,false,false,false,false]
var levels_complete_with_coin : Array[bool] = [false,false,false,false,false,false,false,false,false,false]

signal paused_changed(paused: bool)
var Paused: bool = false:
	set(new_val):
		Paused = new_val
		if Paused: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		paused_changed.emit(new_val)
signal perspective_changed(orthogonal: bool) 
var Perspective: bool = false:
	set(new_val):
		Perspective = new_val
		perspective_changed.emit(new_val)

func _process(_delta: float) -> void:
	# ======= #
	# toggles #
	# ======= #
	if Input.is_action_just_pressed("pause")            : Paused      = not Paused
	if Paused: return
	if Input.is_action_just_pressed("perspective_spell"): Perspective = not Perspective
