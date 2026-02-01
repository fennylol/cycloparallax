extends Node3D
class_name  TheTowerNode
# ========= #
# variables #
# ========= #
@onready var WizardCenter: Node3D          = $WizardsSpinnyBit
@onready var BlocksCenter: Node3D          = $BlocksSpinnyBit
@onready var TinyWizard  : TinyWizardNode  = $WizardsSpinnyBit/TinyWizard
@onready var DollyCamera : DollyCameraNode = $WizardsSpinnyBit/DollyCamera

const StoneBlock : PackedScene = preload("res://4_Blocks/stone/StonePlatform.tscn")
# ================ # 
# internal utility #
# ================ #
#func _ready() -> void:
	#var i = 0
	#for block in blocks.get_children():
		#block.rotation.y = deg_to_rad(11.25 * i)
		#i+=1
func _process(delta: float) -> void:
	if TheLawsOfTheLand.Paused: return
	BlocksCenter.rotate(Vector3.UP, TinyWizard.WalkingSpeed*delta)


func _on_tiny_wizard_placing_block(dir: TinyWizardNode.PlacementDirections) -> void:
	var wiz_loc_id : Vector2i
	var tower_rotation = int(round(rad_to_deg(BlocksCenter.basis.get_euler().y)/11.25))
	wiz_loc_id.x = abs(tower_rotation) if tower_rotation <= 0 else 32-tower_rotation
	wiz_loc_id.y = int((TinyWizard.position.y*20)/10)

	### GET BLOCK LOCATION BASED ON INPUT
	var block_placement_loc =  (Vector2i(0,1)  if dir == TinyWizardNode.PlacementDirections.UP    else \
								Vector2i(1,0)  if dir == TinyWizardNode.PlacementDirections.RIGHT else \
								Vector2i(0,-1) if dir == TinyWizardNode.PlacementDirections.DOWN  else \
								Vector2i(-1,0)) + wiz_loc_id
	block_placement_loc.x = block_placement_loc.x%32
	
	### PLACE BLOCK
	var new_block = StoneBlock.instantiate()
	var block_node_parent = BlocksCenter.find_child(str(block_placement_loc.x), false)
	block_node_parent.add_child(new_block)
	new_block.position = Vector3( 0 , (block_placement_loc.y+1) * 0.5 , 4.75 )
