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

var holding_block : Node = null

const StoneBlock : PackedScene = preload("res://4_Blocks/stone/StonePlatform.tscn")
# ================ # 
# internal utility #
# ================ #
#func _ready() -> void:
	#var i = 0
	#for block in blocks.get_children():
		#block.rotation.y = deg_to_rad(11.25 * i)
		#i+=1
func _ready() -> void:
	LevelBlocks._load_level(0)

func _process(delta: float) -> void:
	if TheLawsOfTheLand.Paused: return
	BlocksCenter.rotate(Vector3.UP, TinyWizard.WalkingSpeed*delta)

func _on_tiny_wizard_placing_block() -> void:
	## MAKE A COPY OF HOLDING BLOCK
	var placed_block = StoneBlock.instantiate()
	holding_block.get_parent().add_child(placed_block)
	placed_block.position = holding_block.position
	
	## SET MATERIAL TO OPAQUE
	var mesh_instance : StandardMaterial3D = placed_block.get_child(0).get_surface_override_material(0)
	mesh_instance.albedo_color.a = 0
	mesh_instance.transparency = 0
	
	## DELETE HOLDING BLOCK
	holding_block.get_parent().remove_child(holding_block)
	holding_block.queue_free()
	holding_block = null

func _on_tiny_wizard_holding_block(dir):
	## GET WIZARD LOCATION
	var wiz_loc_id : Vector2i
	var tower_rotation = int(round(rad_to_deg(BlocksCenter.basis.get_euler().y)/11.25))
	wiz_loc_id.x = abs(tower_rotation) if tower_rotation <= 0 else 32-tower_rotation
	wiz_loc_id.y = int((TinyWizard.position.y*20)/10)+1

	## GET BLOCK LOCATION BASED ON INPUT
	var block_placement_loc =  (Vector2i(0,1)  if dir == TinyWizardNode.PlacementDirections.UP    else \
								Vector2i(1,0)  if dir == TinyWizardNode.PlacementDirections.RIGHT else \
								Vector2i(0,-1) if dir == TinyWizardNode.PlacementDirections.DOWN  else \
								Vector2i(-1,0)) + wiz_loc_id
	block_placement_loc.x = block_placement_loc.x%32
	
	## PLACE BLOCK IN WORLD
	if holding_block == null: 
		holding_block = StoneBlock.instantiate()
		var mesh_instance : StandardMaterial3D = holding_block.get_child(0).get_surface_override_material(0)
		mesh_instance.transparency = 1
		mesh_instance.albedo_color.a = 0.5
		holding_block.get_child(1).disabled = true
	else:
		holding_block.get_parent().remove_child(holding_block)
	var block_node_parent = BlocksCenter.find_child(str(block_placement_loc.x), false)
	block_node_parent.add_child(holding_block)
	holding_block.position = Vector3( 0 , (block_placement_loc.y+1) * 0.5 , 4.75 )

func _on_tiny_wizard_cancel_placement():
	## SET MATERIAL TO OPAQUE
	var mesh_instance : StandardMaterial3D = holding_block.get_child(0).get_surface_override_material(0)
	mesh_instance.albedo_color.a = 0
	mesh_instance.transparency = 0
	
	## DELETE HOLDING BLOCK
	holding_block.get_parent().remove_child(holding_block)
	holding_block.queue_free()
	holding_block = null
