extends Node3D
class_name  TheTowerNode
# ========= #
# variables #
# ========= #
@onready var WizardCenter: Node3D          = $WizardsSpinnyBit
@onready var BlocksCenter: Node3D          = $BlocksSpinnyBit
@onready var LevelBlocks : LevelRingNode   = $BlocksSpinnyBit/LevelRing
@onready var TinyWizard  : TinyWizardNode  = $WizardsSpinnyBit/TinyWizard
@onready var DollyCamera : DollyCameraNode = $WizardsSpinnyBit/DollyCamera
@onready var NextBlockUI : VBoxContainer   = $CanvasLayer/Control/HBoxContainer/VBoxContainer
@onready var Enviro      : WorldEnvironment= $WorldEnvironment
@onready var Tutorial    : ScrollDisplayNode = $CanvasLayer/ScrollDisplay
@onready var CoinUI      : Control         = $CanvasLayer/Coin
@onready var BottomTower : Node3D = $BlocksSpinnyBit/DecorativeRing/DecorativeRing/DecorativeRing/DecorativeRing/DecorativeRingCutoff
@onready var BlockInventoryElement = preload("res://6_UserInterface/BlockInventoryElement.tscn")
signal force_cancel
var LastSafeSpace := Vector2.ZERO
var BlockArray : Array[LevelRingNode.BlockTypes] = []
var Playing: bool = true:
	set(play):
		Playing = play
		if play:
			BlocksCenter.rotation.y = 0.0
			DollyCamera.current = true
			BottomTower.visible = false
			TinyWizard.Mouth.volume_db = TinyWizard.TALKING_VOLUME
			TinyWizard.Mouth2.volume_db = TinyWizard.TALKING_VOLUME
			TinyWizard.Yeller.volume_db = TinyWizard.TALKING_VOLUME
		else:
			DollyCamera.current = false
			BottomTower.visible = true
			TinyWizard.Mouth.volume_db = TinyWizard.WHISPER_VOLUME
			TinyWizard.Mouth2.volume_db = TinyWizard.WHISPER_VOLUME
			TinyWizard.Yeller.volume_db = TinyWizard.WHISPER_VOLUME

# ========================== #
# associated text and colors #
# ========================== #
var item_dict = {
	LevelRingNode.BlockTypes.PLT_STN:[Color("545454"), "Stone Brick"], 
	LevelRingNode.BlockTypes.PLT_PLX:[Color("5edb81"), "Green Brick"],
	LevelRingNode.BlockTypes.PLT_GTW:[Color("6eccec"), "Blue Brick"],
	LevelRingNode.BlockTypes.PLT_FIR:[Color("ec7380"), "Red Brick"],
}

# ================ # 
# internal utility #
# ================ #
func _ready() -> void:
	get_viewport().size_changed.connect(
		func() -> void: 
			for child in NextBlockUI.get_children():
				child._set_img_scale(int(min(get_viewport().size.x, get_viewport().size.y)/10.0))
	)
	TheLawsOfTheLand.perspective_changed.connect(
		func(ortho: bool) -> void:
			if Enviro.environment and Enviro.environment.sky:
				var sky_material = Enviro.environment.sky.sky_material
				if sky_material:
					sky_material.set_shader_parameter("stars_density", 750.0 if ortho else 50.0)
	)
	
	#LevelBlocks._load_level(LevelBlocks.current_level)
	for i in BlockArray:
		var new_element = BlockInventoryElement.instantiate()
		NextBlockUI.add_child(new_element)
		NextBlockUI.move_child(new_element,0)
		new_element._set_color(item_dict.get(i)[0])
		new_element._set_label(item_dict.get(i)[1])
		new_element._set_img_scale(int(min(get_viewport().size.x, get_viewport().size.y)/10.0))

func _process(delta: float) -> void:
	if TheLawsOfTheLand.Paused: return
	#NextBlockUI.text = str(BlockArray.size())
	BlocksCenter.rotate(Vector3.UP, TinyWizard.WalkingSpeed*delta)
	if Playing:
		if Enviro.environment and Enviro.environment.sky:
			var sky_material = Enviro.environment.sky.sky_material
			if sky_material:
				sky_material.set_shader_parameter("sky_rotation_degrees", BlocksCenter.rotation_degrees.y/30 if TheLawsOfTheLand.Perspective else BlocksCenter.rotation_degrees.y)
		DollyCamera.TargetHeight = TinyWizard.position.y
	elif get_parent().PlayingState == 0:
		if (fmod(Time.get_unix_time_from_system(), 5)) < TinyWizard.JUMP_TIME*randf():
			TinyWizard.velocity.y = TinyWizard.JUMP_SPEED
		TinyWizard.WalkingSpeed = -0.25

func _on_tiny_wizard_pickup_block(type):
	BlockArray.append(type)
	var new_element = BlockInventoryElement.instantiate()
	NextBlockUI.add_child(new_element)
	NextBlockUI.move_child(new_element,0)
	new_element._set_color(item_dict.get(type)[0])
	new_element._set_label(item_dict.get(type)[1])
	new_element._set_img_scale(int(min(get_viewport().size.x, get_viewport().size.y)/10.0))

func _on_tiny_wizard_placing_block() -> void:
	if LevelBlocks.invalid_placement_tile == false:
		if BlockArray.pop_back() != null: 
			LevelBlocks._place_held_block()
			NextBlockUI.get_child(0).queue_free()
	else:
		LevelBlocks._cancel_held_block()
		force_cancel.emit()

func _on_tiny_wizard_cancel_placement() -> void:
	LevelBlocks._cancel_held_block()

func _on_tiny_wizard_save_safe_spot() -> void:
	LastSafeSpace = Vector2(BlocksCenter.rotation.y, TinyWizard.position.y)

func _on_tiny_wizard_request_safe_spot() -> void:
	TinyWizard.position.y   = LastSafeSpace.y
	BlocksCenter.rotation.y = LastSafeSpace.x

func _on_tiny_wizard_holding_block(dir: TinyWizardNode.PlacementDirections) -> void:
	## PASS TYPE FROM ARRAY
	## if array is empty, force a cancellation
	var type : LevelRingNode.BlockTypes
	if BlockArray.is_empty(): force_cancel.emit()
	else:
		type = BlockArray.back()
	
		## GET WIZARD LOCATION
		var wiz_loc_id : Vector2i
		var tower_rotation = int(round(BlocksCenter.rotation_degrees.y/11.25))
		wiz_loc_id.x = abs(tower_rotation) if tower_rotation <= 0 else 32-tower_rotation
		wiz_loc_id.y = int((TinyWizard.position.y*20)/10)+1
		
		## GET BLOCK LOCATION BASED ON INPUT
		var block_placement_loc =  (Vector2i(0,1)  if dir == TinyWizardNode.PlacementDirections.UP    else \
									Vector2i(1,0)  if dir == TinyWizardNode.PlacementDirections.RIGHT else \
									Vector2i(0,-1) if dir == TinyWizardNode.PlacementDirections.DOWN  else \
									Vector2i(-1,0)) + wiz_loc_id
		block_placement_loc.x = block_placement_loc.x%32
		
		LevelBlocks._hold_block(block_placement_loc, type)

func _on_tiny_wizard_coin_pickup():
	CoinUI.visible = true

## CALLED ON LEVEL RESET
func _on_level_ring_reset_level(_lvl: int, _height : float):
	BlockArray.clear()
	for i in NextBlockUI.get_children():
		i.queue_free()
	CoinUI.visible = false
