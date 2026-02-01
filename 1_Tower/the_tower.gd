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
var LastSafeSpace := Vector2.ZERO
# ================ # 
# internal utility #
# ================ #
func _ready() -> void:
	LevelBlocks._load_level(0)

func _process(delta: float) -> void:
	if TheLawsOfTheLand.Paused: return
	BlocksCenter.rotate(Vector3.UP, TinyWizard.WalkingSpeed*delta)

func _on_tiny_wizard_placing_block() -> void:
	LevelBlocks._place_held_block()

func _on_tiny_wizard_cancel_placement() -> void:
	LevelBlocks._cancel_held_block()

func _on_tiny_wizard_save_safe_spot() -> void:
	LastSafeSpace = Vector2(BlocksCenter.rotation.y, TinyWizard.position.y)

func _on_tiny_wizard_request_safe_spot() -> void:
	TinyWizard.position.y   = LastSafeSpace.y
	BlocksCenter.rotation.y = LastSafeSpace.x

func _on_tiny_wizard_holding_block(dir: TinyWizardNode.PlacementDirections, type: LevelRingNode.BlockTypes) -> void:
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
