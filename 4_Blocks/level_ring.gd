extends Node3D
class_name LevelRingNode

var HoldingBlock: Node3D
const HOLD_ALPHA: float = 0.5

enum BlockTypes {
	PLT_AIR, 
	OBJ_BGN, OBJ_END, OBJ_MSC, 
	PLT_STN, ITM_STN, 
	PLT_PLX, ITM_PLX,
	PLT_GTW, ITM_GTW,
	PLT_FIR, ITM_FIR
	}
enum {
	PLT_AIR, 
	OBJ_BGN, OBJ_END, OBJ_MSC, 
	PLT_STN, ITM_STN, 
	PLT_PLX, ITM_PLX,
	PLT_GTW, ITM_GTW,
	PLT_FIR, ITM_FIR
	}
const Blocks: Array[PackedScene] = [
	null,
	null, null, null,
	preload("res://4_Blocks/stone/StonePlatform.tscn"),       null,
	preload("res://4_Blocks/parallax/ParallaxPlatform.tscn"), null,
	preload("res://4_Blocks/gateway/GatewayPlatform.tscn"),   null,
	preload("res://4_Blocks/fire/FirePlatform.tscn"), null
]

const LEVELS: Array[Array] = [
	LEVEL_0,
	LEVEL_1,
	LEVEL_2,
	LEVEL_BASE
]

func _place_held_block() -> void:
	### SET MATERIAL TO OPAQUE
	var mat : StandardMaterial3D = HoldingBlock.get_child(0).get_surface_override_material(0).duplicate(true)
	mat.albedo_color.a = 0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	HoldingBlock.get_child(0).set_surface_override_material(0, mat)
	
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
	var mat : StandardMaterial3D = HoldingBlock.get_child(0).get_surface_override_material(0).duplicate(true)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = HOLD_ALPHA
	HoldingBlock.get_child(0).set_surface_override_material(0, mat)
	HoldingBlock.get_child(1).disabled = true

func _place_block(pos: Vector2i, type: BlockTypes) -> Node3D:
	var new_block = Blocks[type].instantiate()
	new_block.set_name(BlockTypes.find_key(type).to_pascal_case()+"_"+str(pos.y))
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
			var type = x_slice[y]
			if type == PLT_AIR: continue
			_place_block(Vector2i(x,y), type)

const LEVEL_BASE: Array[Array] = [
	[PLT_STN], #  0 <-> 16 
	[PLT_STN], #  1 <-> 17 
	[PLT_STN], #  2 <-> 18 
	[PLT_STN], #  3 <-> 19 
	[PLT_STN], #  4 <-> 20 
	[PLT_STN], #  5 <-> 21 
	[PLT_STN], #  6 <-> 22 
	[PLT_STN], #  7 <-> 23 
	[PLT_STN], #  8 <-> 24 
	[PLT_STN], #  9 <-> 25 
	[PLT_STN], # 10 <-> 26 
	[PLT_STN], # 11 <-> 27 
	[PLT_STN], # 12 <-> 28 
	[PLT_STN], # 13 <-> 29 
	[PLT_STN], # 14 <-> 30 
	[PLT_STN], # 15 <-> 31 
	[PLT_STN], # 16 <->  0
	[PLT_STN], # 17 <->  1
	[PLT_STN], # 18 <->  2
	[PLT_STN], # 19 <->  3
	[PLT_STN], # 20 <->  4
	[PLT_STN], # 21 <->  5
	[PLT_STN], # 22 <->  6
	[PLT_STN], # 23 <->  7
	[PLT_STN], # 24 <->  8
	[PLT_STN], # 25 <->  9
	[PLT_STN], # 26 <-> 10
	[PLT_STN], # 27 <-> 11
	[PLT_STN], # 28 <-> 12
	[PLT_STN], # 29 <-> 13
	[PLT_STN], # 30 <-> 14
	[PLT_STN]  # 31 <-> 15
]

const LEVEL_0: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  0 <-> 16 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  1 <-> 17 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], #  2 <-> 18 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  4 <-> 20 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_STN, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_AIR, PLT_STN], #  8 <-> 24 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  9 <-> 25 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN], # 11 <-> 27 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_FIR], # 13 <-> 29 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 14 <-> 30 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 17 <->  1
	[PLT_STN], # 18 <->  2
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_FIR], # 19 <->  3
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 20 <->  4
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 21 <->  5
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 22 <->  6
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_FIR, PLT_STN], # 23 <->  7
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 25 <->  9
	[PLT_STN], # 26 <-> 10
	[PLT_STN, PLT_STN], # 27 <-> 11
	[PLT_STN, PLT_STN, PLT_STN], # 28 <-> 12
	[PLT_STN, PLT_STN, PLT_STN, PLT_FIR], # 29 <-> 13
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN]  # 31 <-> 15
]

const LEVEL_1: Array[Array] = [
	[PLT_STN], #  0 <-> 16 
	[PLT_STN], #  1 <-> 17 
	[PLT_STN], #  2 <-> 18 
	[PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_STN], #  4 <-> 20 
	[PLT_STN, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_STN, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_STN, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_FIR], #  8 <-> 24 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  9 <-> 25 
	[PLT_STN, PLT_FIR], # 11 <-> 27 
	[PLT_STN, PLT_FIR], # 12 <-> 28 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 13 <-> 29 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 14 <-> 30 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_FIR], # 16 <->  0
	[PLT_STN, PLT_FIR], # 17 <->  1
	[PLT_STN, PLT_FIR], # 18 <->  2
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 19 <->  3
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 20 <->  4
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 21 <->  5
	[PLT_STN, PLT_FIR], # 22 <->  6
	[PLT_STN, PLT_FIR], # 23 <->  7
	[PLT_STN, PLT_FIR], # 24 <->  8
	[PLT_STN, PLT_FIR], # 25 <->  9
	[PLT_STN, PLT_FIR], # 26 <-> 10
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 27 <-> 11
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 28 <-> 12
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_PLX], # 29 <-> 13
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN]  # 31 <-> 15
]

const LEVEL_2: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], #  0 <-> 16 
	[PLT_STN], #  1 <-> 17 
	[PLT_STN], #  2 <-> 18 
	[PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  4 <-> 20 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  8 <-> 24 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  9 <-> 25 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 11 <-> 27 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 13 <-> 29 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 14 <-> 30 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 17 <->  1
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 18 <->  2
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 19 <->  3
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 20 <->  4
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN], # 21 <->  5
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN], # 22 <->  6
	[PLT_STN, PLT_STN, PLT_PLX, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 23 <->  7
	[PLT_STN, PLT_STN, PLT_PLX, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_GTW, PLT_GTW, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 25 <->  9
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_GTW, PLT_GTW, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 26 <-> 10
	[PLT_STN, PLT_STN, PLT_PLX, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 27 <-> 11
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 28 <-> 12
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 29 <-> 13
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN]  # 31 <-> 15
]
