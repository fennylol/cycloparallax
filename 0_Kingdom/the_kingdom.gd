extends Node3D

@onready var TheTower: TheTowerNode = $TheTower#preload("res://1_Tower/TheTower.tscn")
@onready var UI: Control = $CanvasLayer/Control
@onready var LevelSelect: LevelSelectNode = $CanvasLayer/Control/HBoxContainer/VBoxContainer/HBoxContainer/LevelSelect
@onready var Buttons: VBoxContainer = $CanvasLayer/Control/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer
@onready var Cam: Camera3D = $Camera3D

const CAM_START_POS := Vector3(-0.5, 2.5, 15.0)
const CAM_START_ROT := Vector3(0.0, 15.0, 0.0)

enum PlayingStates {MENU, TRANSTION, PLAYING}
var PlayingState := PlayingStates.MENU
var LevelToPlay: int = 0

#func _ready() -> void:
	#TheTower.Playing = false
	##activate_level_select()
	#pass

func _process(delta) -> void:
	match PlayingState:
		PlayingStates.MENU:
			if TheTower.Playing: TheTower.Playing = false
			UI.visible = true
			Cam.position         = CAM_START_POS
			Cam.rotation_degrees = CAM_START_ROT
			
			if TheLawsOfTheLand.levels_completed[9]:
				TheTower.Thanks.visible = true
				TheTower.TowerTop.visible = true
				if TheLawsOfTheLand.all_levels_completed():
					if TheLawsOfTheLand.all_levels_complete_with_coin():
						TheTower.Thanks.texture = load("res://3_Wizard/sprites/ThanksBubbleFULL.png")
					else:
						TheTower.Thanks.texture = load("res://3_Wizard/sprites/ThanksBubbleLevel.png")
				else:
					TheTower.Thanks.texture = load("res://3_Wizard/sprites/ThanksBubble.png")
			else:
				TheTower.Thanks.visible = false
				TheTower.TowerTop.visible = false
		PlayingStates.TRANSTION: 
			UI.visible = false
			Cam.position         = lerp(Cam.position,         TheTower.DollyCamera.position,         2.5*delta)
			Cam.rotation_degrees = lerp(Cam.rotation_degrees, TheTower.DollyCamera.rotation_degrees, 2.5*delta)
			
			if abs((Cam.position-TheTower.DollyCamera.position).length()) < 0.05:
				activate_the_tower(LevelToPlay)
	

func activate_level_select():
	LevelSelect.visible = true
	Buttons.visible = false

func select_level(lvl: int) -> void:
	LevelToPlay = lvl
	TheLawsOfTheLand.Paused = true
	TheLawsOfTheLand.Paused = false
	PlayingState = PlayingStates.TRANSTION

func activate_the_tower(level: int = 0):
	Cam.current = false
	TheTower.Playing = true
	PlayingState = PlayingStates.PLAYING
	
	## LOAD THE REQUESTED LEVEL
	var levelring : LevelRingNode = TheTower.get_child(2).get_child(2)
	levelring.current_level = level
	levelring.reload_the_whole_daggum_map()
	


func _on_play_button_pressed()         -> void: select_level(0)
func _on_level_select_button_pressed() -> void: activate_level_select()

func return_to_main_menu():
	PlayingState = PlayingStates.MENU
	LevelSelect.visible = false
	Buttons.visible = true
	TheLawsOfTheLand.Paused = true
	TheLawsOfTheLand.Paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	LevelSelect.check_levels_complete()
