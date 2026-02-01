extends Node

signal paused_changed(paused: bool)
var Paused: bool = false:
	set(new_val):
		Paused = new_val
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
	if Input.is_action_just_pressed("perspective_spell"): Perspective = not Perspective
	if Input.is_action_just_pressed("pause")            : Paused      = not Paused
