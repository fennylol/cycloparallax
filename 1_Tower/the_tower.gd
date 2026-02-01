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
@onready var NextBlockUI : VBoxContainer   = $CanvasLayer/Control/VBoxContainer
@onready var BlockInventoryElement = preload("res://5_DollyCam/BlockInventoryElement.tscn")
signal force_cancel
var LastSafeSpace := Vector2.ZERO
var BlockArray : Array = [LevelRingNode.BlockTypes.PLT_STN]
var current_level = 2
# ========================== #
# associated text and colors #
# ========================== #
var item_dict = {
	LevelRingNode.BlockTypes.PLT_STN:[Color("545454"), "Stone"], 
	LevelRingNode.BlockTypes.PLT_PLX:[Color("5edb81"), "Parallax"],
	LevelRingNode.BlockTypes.PLT_GTW:[Color("6eccec"), "Gateway"],
	LevelRingNode.BlockTypes.PLT_FIR:[Color("ec7380"), "Fire"],
}

# ================ # 
# internal utility #
# ================ #
func _ready() -> void:
	LevelBlocks._load_level(2)
	for i in BlockArray:
		var new_element = BlockInventoryElement.instantiate()
		NextBlockUI.add_child(new_element)
		NextBlockUI.move_child(new_element,0)
		new_element.get_child(0).color = item_dict.get(i)[0]
		new_element.get_child(1).text = item_dict.get(i)[1]

func _process(delta: float) -> void:
	if TheLawsOfTheLand.Paused: return
	#NextBlockUI.text = str(BlockArray.size())
	BlocksCenter.rotate(Vector3.UP, TinyWizard.WalkingSpeed*delta)
	DollyCamera.TargetHeight = TinyWizard.position.y
	
	if Input.is_action_just_released("reset"): 
		LevelBlocks._load_level(current_level)
		BlocksCenter.rotation_degrees.y = 0
		TinyWizard.position.y = 0.1
	

func _on_tiny_wizard_pickup_block(type):
	BlockArray.append(type)
	var new_element = BlockInventoryElement.instantiate()
	NextBlockUI.add_child(new_element)
	NextBlockUI.move_child(new_element,0)
	new_element.get_child(0).color = item_dict.get(type)[0]
	new_element.get_child(1).text = item_dict.get(type)[1]

func _on_tiny_wizard_placing_block() -> void:
	if BlockArray.pop_back() != null: 
		LevelBlocks._place_held_block()
		NextBlockUI.get_child(0).queue_free()

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
