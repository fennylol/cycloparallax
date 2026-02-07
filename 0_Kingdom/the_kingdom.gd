extends Node3D

@onready var level_select = preload("res://0_Kingdom/level_select.tscn")
@onready var TheTower: TheTowerNode = $TheTower#preload("res://1_Tower/TheTower.tscn")
@onready var UI: Control = $CanvasLayer/Control
@onready var Cam: Camera3D = $Camera3D

const CAM_START_POS := Vector3(-0.5, 2.5, 15.0)
const CAM_START_ROT := Vector3(0.0, 15.0, 0.0)
var level_select_node

enum PlayingStates {MENU, TRANSTION, PLAYING}
var PlayingState := PlayingStates.MENU

func _ready() -> void:
	TheTower.Playing = false
	#activate_level_select()
	pass

func _process(delta) -> void:
	if PlayingState == PlayingStates.TRANSTION: 
		UI.visible = false
		Cam.position         = lerp(Cam.position,         TheTower.DollyCamera.position,         2.5*delta)
		Cam.rotation_degrees = lerp(Cam.rotation_degrees, TheTower.DollyCamera.rotation_degrees, 2.5*delta)
		
		if abs((Cam.position-TheTower.DollyCamera.position).length()) < 0.05:
			activate_the_tower(0)
	#else:
		#Cam.position         = lerp(Cam.position,         CAM_START_POS, delta)
		#Cam.rotation_degrees = lerp(Cam.rotation_degrees, CAM_START_ROT, delta)

func activate_level_select():
	level_select_node = level_select.instantiate()
	add_child(level_select_node)
	level_select_node.name = "LevelSelect"

func activate_the_tower(level: int = 0):
	Cam.current = false
	TheTower.Playing = true
	PlayingState = PlayingStates.PLAYING
	
	## LOAD THE REQUESTED LEVEL
	var levelring : LevelRingNode = TheTower.get_child(2).get_child(2)
	levelring.current_level = level
	levelring.reload_the_whole_daggum_map()
	
	## KILL LEVEL SELECT IF IT EXISTS
	if level_select_node: level_select_node.queue_free()


func _on_play_button_pressed()         -> void: PlayingState = PlayingStates.TRANSTION
func _on_level_select_button_pressed() -> void: activate_level_select()
