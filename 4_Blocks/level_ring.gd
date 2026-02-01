extends Node3D
class_name LevelRingNode

enum BlockTypes {AIR, STONE, PARALLAX}
var HoldingBlock: Node3D

const Blocks: Array[PackedScene] = [
	null,
	preload("res://4_Blocks/stone/StonePlatform.tscn"),
	preload("res://4_Blocks/parallax/ParallaxPlatform.tscn")
]

const LEVELS: Array[Array] = [
	LEVEL_BASE,
	LEVEL_0
]

func _place_held_block() -> void:
	### SET MATERIAL TO OPAQUE
	var mesh_instance : StandardMaterial3D = HoldingBlock.get_child(0).get_surface_override_material(0).duplicate(true)
	mesh_instance.albedo_color.a = 0
	mesh_instance.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	HoldingBlock.get_child(0).set_surface_override_material(0, mesh_instance)
	
	HoldingBlock.get_child(1).disabled = false
	HoldingBlock = null

func _cancel_held_block() -> void:
	HoldingBlock.get_parent().remove_child(HoldingBlock)
	HoldingBlock.queue_free()
	HoldingBlock = null

func _hold_block(pos: Vector2i, type: BlockTypes) -> void:
	## PLACE BLOCK IN WORLD
	if HoldingBlock != null: 
		HoldingBlock.get_parent().remove_child(HoldingBlock)
		HoldingBlock.queue_free()
	
	HoldingBlock = _place_block(pos, type)
	var mesh_instance : StandardMaterial3D = HoldingBlock.get_child(0).get_surface_override_material(0).duplicate(true)
	mesh_instance.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.albedo_color.a = 0.5
	HoldingBlock.get_child(0).set_surface_override_material(0, mesh_instance)
	HoldingBlock.get_child(1).disabled = true

func _place_block(pos: Vector2i, type: BlockTypes) -> Node3D:
	var new_block = Blocks[type].instantiate()
	new_block.set_name(BlockTypes.find_key(type).to_pascal_case()+"Platform"+str(pos.y))
	var block_node_parent = get_child(pos.x)
	block_node_parent.add_child(new_block)
	new_block.position.y = pos.y * 0.5
	return new_block

func _load_level(level_idx: int) -> void:
	if level_idx >= LEVELS.size(): printerr("level idx ", level_idx , " doesn't exist."); return
	var level_map: Array[Array] = LEVELS[level_idx]
	
	for x in range(level_map.size()):
		var current_x_slice: Node3D = get_child(x)
		while current_x_slice.get_child_count():
			var block: Node3D = current_x_slice.get_child(0)
			block.queue_free()
			current_x_slice.remove_child(block)
		
		var x_slice: Array = level_map[x]
		for y in range(x_slice.size()):
			var type: BlockTypes = x_slice[y]
			if type == BlockTypes.AIR: continue
			_place_block(Vector2i(x,y), type)

const LEVEL_BASE: Array[Array] = [
	[BlockTypes.STONE], #  0 <-> 16 
	[BlockTypes.STONE], #  1 <-> 17 
	[BlockTypes.STONE], #  2 <-> 18 
	[BlockTypes.STONE], #  3 <-> 19 
	[BlockTypes.STONE], #  4 <-> 20 
	[BlockTypes.STONE], #  5 <-> 21 
	[BlockTypes.STONE], #  6 <-> 22 
	[BlockTypes.STONE], #  7 <-> 23 
	[BlockTypes.STONE], #  8 <-> 24 
	[BlockTypes.STONE], #  9 <-> 25 
	[BlockTypes.STONE], # 10 <-> 26 
	[BlockTypes.STONE], # 11 <-> 27 
	[BlockTypes.STONE], # 12 <-> 28 
	[BlockTypes.STONE], # 13 <-> 29 
	[BlockTypes.STONE], # 14 <-> 30 
	[BlockTypes.STONE], # 15 <-> 31 
	[BlockTypes.STONE], # 16 <->  0
	[BlockTypes.STONE], # 17 <->  1
	[BlockTypes.STONE], # 18 <->  2
	[BlockTypes.STONE], # 19 <->  3
	[BlockTypes.STONE], # 20 <->  4
	[BlockTypes.STONE], # 21 <->  5
	[BlockTypes.STONE], # 22 <->  6
	[BlockTypes.STONE], # 23 <->  7
	[BlockTypes.STONE], # 24 <->  8
	[BlockTypes.STONE], # 25 <->  9
	[BlockTypes.STONE], # 26 <-> 10
	[BlockTypes.STONE], # 27 <-> 11
	[BlockTypes.STONE], # 28 <-> 12
	[BlockTypes.STONE], # 29 <-> 13
	[BlockTypes.STONE], # 30 <-> 14
	[BlockTypes.STONE]  # 31 <-> 15
]

const LEVEL_0: Array[Array] = [
	[BlockTypes.STONE], #  0 <-> 16 
	[BlockTypes.STONE, BlockTypes.STONE], #  1 <-> 17 
	[BlockTypes.STONE, BlockTypes.STONE, BlockTypes.STONE], #  2 <-> 18 
	[BlockTypes.STONE], #  3 <-> 19 
	[BlockTypes.STONE], #  4 <-> 20 
	[BlockTypes.STONE, BlockTypes.STONE, BlockTypes.STONE, BlockTypes.AIR, BlockTypes.PARALLAX], #  5 <-> 21 
	[BlockTypes.STONE, BlockTypes.STONE], #  6 <-> 22 
	[BlockTypes.STONE], #  7 <-> 23 
	[BlockTypes.STONE], #  8 <-> 24 
	[BlockTypes.STONE], #  9 <-> 25 
	[BlockTypes.STONE], # 10 <-> 26 
	[BlockTypes.STONE], # 11 <-> 27 
	[BlockTypes.STONE], # 12 <-> 28 
	[BlockTypes.STONE], # 13 <-> 29 
	[BlockTypes.STONE], # 14 <-> 30 
	[BlockTypes.STONE], # 15 <-> 31 
	[BlockTypes.STONE], # 16 <->  0
	[BlockTypes.STONE], # 17 <->  1
	[BlockTypes.STONE], # 18 <->  2
	[BlockTypes.STONE, BlockTypes.AIR, BlockTypes.PARALLAX], # 19 <->  3
	[BlockTypes.STONE, BlockTypes.AIR, BlockTypes.PARALLAX], # 20 <->  4
	[BlockTypes.STONE], # 21 <->  5
	[BlockTypes.STONE], # 22 <->  6
	[BlockTypes.STONE], # 23 <->  7
	[BlockTypes.STONE], # 24 <->  8
	[BlockTypes.STONE], # 25 <->  9
	[BlockTypes.STONE], # 26 <-> 10
	[BlockTypes.STONE], # 27 <-> 11
	[BlockTypes.STONE], # 28 <-> 12
	[BlockTypes.STONE], # 29 <-> 13
	[BlockTypes.STONE], # 30 <-> 14
	[BlockTypes.STONE]  # 31 <-> 15
]
