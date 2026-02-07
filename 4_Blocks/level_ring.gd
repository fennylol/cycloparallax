extends Node3D
class_name LevelRingNode

var HoldingBlock: Node3D
var invalid_placement_tile : bool = false
const HOLD_ALPHA: float = 0.5
signal reset_level(lvl : int, height : float)

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
	null, preload("res://2_Objects/win_crystal/win_crystal.tscn"), preload("res://2_Objects/coin/coin.tscn"),
	preload("res://4_Blocks/stone/StonePlatform.tscn"),       preload("res://2_Objects/pickup_stone/pickup_stone.tscn"),
	preload("res://4_Blocks/parallax/ParallaxPlatform.tscn"), preload("res://2_Objects/pickup_parallax/pickup_parallax.tscn"),
	preload("res://4_Blocks/gateway/GatewayPlatform.tscn"),   preload("res://2_Objects/pickup_gateway/pickup_gateway.tscn"),
	preload("res://4_Blocks/fire/FirePlatform.tscn"),         preload("res://2_Objects/pickup_fire/pickup_fire.tscn")
]

var current_level = 0
var current_y_height = 0
const LEVELS: Array[Array] = [
	JUMP_AND_FIRE,
	BLOCK_PLACEMENT,
	SHIFTING,
	GATEWAY,
	VOLCANO,
	test_LEVEL_2,
	LAVA_FALL,
	AIRLOCK
]

func _process(_delta):
	if Input.is_action_just_released("reset"): reload_the_whole_daggum_map()

func _place_held_block() -> void:
	### SET MATERIAL TO OPAQUE
	var mat : StandardMaterial3D = HoldingBlock.get_child(0).get_surface_override_material(0).duplicate(true)
	mat.albedo_color.a = 0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	HoldingBlock.get_child(0).set_surface_override_material(0, mat)
	
	HoldingBlock.get_child(1).disabled = false
	HoldingBlock = null
	invalid_placement_tile = false

func _cancel_held_block() -> void:
	if HoldingBlock != null:
		HoldingBlock.get_parent().remove_child(HoldingBlock)
		HoldingBlock.queue_free()
		HoldingBlock = null
	invalid_placement_tile = false

func _hold_block(pos: Vector2i, type: BlockTypes) -> void:
	## REMOVE VESTIGIAL BLOCK
	if HoldingBlock != null: 
		HoldingBlock.get_parent().remove_child(HoldingBlock)
		HoldingBlock.queue_free()
	
	## CHECK THE WHOLE DAGGUM MAP TO MAKE SURE THE BLOCK DOESN'T EXIST AT THAT SPOT ALREADY
	var the_tile_is_empty = true
	var level_map: Array[Array] = LEVELS[current_level]
	for x in range(level_map.size()):
		var x_slice: Array = level_map[x]
		for y in range(x_slice.size()):
			if x_slice[y] == PLT_AIR or x_slice[y] == OBJ_BGN or x_slice[y] == ITM_STN or x_slice[y] == ITM_PLX or x_slice[y] == ITM_GTW or x_slice[y] == ITM_FIR: continue
			if pos == Vector2i(x,y): 
				the_tile_is_empty = false
				invalid_placement_tile = true
	
	## SHOW TRANSPARENT BLOCK IN WORLD
	if the_tile_is_empty:
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

func _load_level(level_idx: int, clear_blocks: bool = true, ignore_goal: bool = false) -> void:
	if level_idx >= LEVELS.size(): printerr("level idx ", level_idx , " doesn't exist."); return
	var level_map: Array[Array] = LEVELS[level_idx]
	
	for x in range(level_map.size()):
		if clear_blocks:
			var current_x_slice: Node3D = get_child(x)
			while current_x_slice.get_child_count():
				var block: Node3D = current_x_slice.get_child(0)
				block.queue_free()
				current_x_slice.remove_child(block)
		
		var x_slice: Array = level_map[x]
		for y in range(x_slice.size()):
			var type = x_slice[y]
			if type == PLT_AIR: continue
			if type == OBJ_END and ignore_goal: continue
			_place_block(Vector2i(x,y+current_y_height), type)

## ADD HEIGHTS OF PREVIOUS LEVELS
func get_y_height_for_level(level : int) -> int:
	var y_offset : int = 0
	for i in range(level):
		var max_height_of_level_i = 0
		var level_map: Array[Array] = LEVELS[i]
		for x in range(level_map.size()):
			var x_slice: Array = level_map[x]
			if x_slice.size() > max_height_of_level_i: max_height_of_level_i = x_slice.size()
		y_offset += max_height_of_level_i
	return y_offset

func reload_the_whole_daggum_map():
	current_y_height = 0
	var clear_blocks = true
	for i in range(current_level + 1):
		var ignore_goal = false if i == current_level else true
		var y_offset : int = 0
		for j in range(i):
			var max_height_of_level_j = 0
			var level_map: Array[Array] = LEVELS[j]
			for x in range(level_map.size()):
				var x_slice: Array = level_map[x]
				if x_slice.size() > max_height_of_level_j: max_height_of_level_j = x_slice.size()
			y_offset += max_height_of_level_j
		current_y_height = y_offset
		_load_level(i, clear_blocks, ignore_goal)
		clear_blocks = false ## clears blocks on the first loop and then never again
	self.get_parent().rotation_degrees.y = 0
	reset_level.emit(current_level, current_y_height)

func _on_tiny_wizard_level_complete():
	current_level += 1
	reload_the_whole_daggum_map()

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

const JUMP_AND_FIRE: Array[Array] = [
	[PLT_STN], #  1 <-> 17 
	[PLT_STN], #  2 <-> 18 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  4 <-> 20 
	[PLT_STN, PLT_FIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_FIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  8 <-> 24 
	[PLT_STN, PLT_FIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  9 <-> 25 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 11 <-> 27 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_FIR], # 13 <-> 29 
	[PLT_STN, PLT_FIR], # 14 <-> 30 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 17 <->  1
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 18 <->  2
	[PLT_STN, PLT_FIR], # 19 <->  3
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 20 <->  4
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 21 <->  5
	[PLT_STN, PLT_FIR], # 22 <->  6
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 23 <->  7
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_FIR], # 25 <->  9
	[PLT_STN, PLT_FIR], # 26 <-> 10
	[PLT_STN, PLT_FIR], # 27 <-> 11
	[PLT_STN, PLT_FIR], # 28 <-> 12
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_GTW, PLT_GTW, PLT_STN], # 29 <-> 13
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, OBJ_MSC, PLT_AIR, PLT_STN, PLT_AIR, OBJ_END], # 30 <-> 14
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_GTW, PLT_GTW, PLT_STN],  # 31 <-> 15
	[PLT_STN] #  0 <-> 16 
]

const BLOCK_PLACEMENT: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN],  #  0 <-> 16 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], #  1 <-> 17 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  2 <-> 18 
	[PLT_STN, PLT_AIR, ITM_PLX], #  3 <-> 19 
	[PLT_STN], #  4 <-> 20 
	[PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, ITM_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], #  8 <-> 24 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  9 <-> 25 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, OBJ_END, PLT_AIR, PLT_AIR, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 11 <-> 27 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 13 <-> 29 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 14 <-> 30 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR], # 17 <->  1
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 18 <->  2
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 19 <->  3
	[PLT_STN], # 20 <->  4
	[PLT_STN], # 21 <->  5
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 22 <->  6
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, OBJ_MSC], # 23 <->  7
	[PLT_STN, PLT_FIR], # 25 <->  9
	[PLT_STN, PLT_FIR], # 26 <-> 10
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN], # 27 <-> 11
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN], # 28 <-> 12
	[PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 29 <-> 13
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN], # 31 <-> 15
]

const SHIFTING: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_PLX, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  0 <-> 16 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  1 <-> 17 
	[PLT_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  2 <-> 18 
	[PLT_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  3 <-> 19 
	[PLT_FIR, PLT_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  4 <-> 20 
	[PLT_FIR, PLT_AIR, PLT_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  5 <-> 21 
	[PLT_FIR, PLT_AIR, PLT_AIR, PLT_PLX], #  6 <-> 22 
	[PLT_FIR, PLT_FIR], #  7 <-> 23 
	[PLT_FIR, PLT_FIR], #  8 <-> 24 
	[PLT_FIR], #  9 <-> 25 
	[PLT_FIR, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 10 <-> 26 
	[PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 11 <-> 27 
	[PLT_FIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 13 <-> 29 
	[PLT_STN, PLT_STN, PLT_STN], # 14 <-> 30 
	[PLT_STN], # 15 <-> 31 
	[PLT_STN], # 16 <->  0
	[PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 17 <->  1
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 18 <->  2
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 19 <->  3
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 20 <->  4
	[PLT_STN, ITM_PLX, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 21 <->  5
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, OBJ_END], # 22 <->  6
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX, PLT_AIR, PLT_STN, PLT_STN], # 23 <->  7
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX], # 24 <->  8
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX], # 25 <->  9
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX], # 26 <-> 10
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX], # 27 <-> 11
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX], # 28 <-> 12
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX], # 29 <-> 13
	[PLT_PLX, PLT_PLX, PLT_PLX, PLT_PLX, PLT_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_PLX, PLT_AIR, PLT_STN, PLT_STN, PLT_STN]  # 31 <-> 15
]

const GATEWAY: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  0 <-> 16 
	[PLT_STN], #  1 <-> 17 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN], #  2 <-> 18 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN], #  4 <-> 20 
	[PLT_STN, PLT_FIR], #  5 <-> 21 
	[PLT_STN, PLT_FIR], #  6 <-> 22 
	[PLT_STN, PLT_FIR], #  7 <-> 23 
	[PLT_STN, PLT_FIR], #  8 <-> 24 
	[PLT_STN, PLT_FIR], #  9 <-> 25 
	[PLT_STN, PLT_FIR], # 10 <-> 26 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN], # 11 <-> 27 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN], # 13 <-> 29 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_GTW, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 14 <-> 30 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_GTW, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_GTW, PLT_STN], # 17 <->  1
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_GTW], # 18 <->  2
	[PLT_STN, PLT_GTW, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_GTW, PLT_GTW], # 19 <->  3
	[PLT_STN, PLT_GTW, PLT_GTW, PLT_GTW, PLT_AIR, PLT_AIR, PLT_GTW, PLT_GTW], # 20 <->  4
	[PLT_STN, PLT_GTW, PLT_GTW, PLT_PLX, PLT_GTW, PLT_GTW, PLT_GTW, PLT_GTW], # 21 <->  5
	[PLT_STN, PLT_GTW, PLT_GTW, PLT_PLX, PLT_GTW, PLT_GTW, PLT_GTW], # 22 <->  6
	[PLT_STN, PLT_AIR, PLT_GTW, PLT_PLX, PLT_GTW, PLT_GTW, PLT_GTW], # 23 <->  7
	[PLT_STN, PLT_AIR, PLT_GTW, PLT_GTW, PLT_GTW, PLT_GTW, PLT_GTW], # 24 <->  8
	[PLT_STN, PLT_GTW, PLT_GTW, PLT_PLX, PLT_GTW, PLT_GTW, PLT_GTW, PLT_GTW], # 25 <->  9
	[PLT_STN, PLT_GTW, PLT_GTW, PLT_PLX, PLT_GTW, PLT_GTW, PLT_GTW, PLT_GTW], # 26 <-> 10
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_GTW, PLT_GTW, PLT_AIR, PLT_GTW, PLT_GTW], # 27 <-> 11
	[PLT_STN, PLT_GTW, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 28 <-> 12
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 29 <-> 13
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, OBJ_END], # 30 <-> 14
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN]  # 31 <-> 15
]

const VOLCANO: Array[Array] = [
	[PLT_STN], #  0 <-> 16 
	[PLT_STN], #  1 <-> 17 
	[PLT_STN], #  2 <-> 18 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_PLX, PLT_AIR, PLT_AIR, PLT_STN], #  4 <-> 20 
	[PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_PLX, PLT_AIR, PLT_AIR, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_FIR], #  8 <-> 24 
	[PLT_STN, PLT_FIR], #  9 <-> 25 
	[PLT_STN, PLT_FIR], # 10 <-> 26 
	[PLT_STN, PLT_FIR], # 11 <-> 27 
	[PLT_STN, PLT_FIR], # 12 <-> 28 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_FIR], # 13 <-> 29 
	[PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_FIR], # 14 <-> 30 
	[PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 15 <-> 31 
	[PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_STN, PLT_STN], # 17 <->  1
	[PLT_FIR, PLT_FIR], # 18 <->  2
	[PLT_FIR, PLT_FIR, PLT_FIR], # 19 <->  3
	[PLT_AIR, PLT_AIR, PLT_FIR, PLT_FIR, PLT_FIR], # 20 <->  4
	[PLT_AIR, PLT_AIR, PLT_FIR, PLT_FIR, PLT_FIR], # 21 <->  5
	[PLT_STN, PLT_FIR, PLT_FIR], # 22 <->  6
	[PLT_STN, PLT_FIR], # 23 <->  7
	[PLT_STN, PLT_STN, PLT_STN, PLT_PLX, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_AIR, PLT_STN, PLT_PLX, PLT_AIR, PLT_STN], # 25 <->  9
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_PLX, PLT_AIR, PLT_STN, PLT_STN], # 26 <-> 10
	[PLT_STN, ITM_PLX, PLT_STN, PLT_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 27 <-> 11
	[PLT_STN, PLT_AIR, PLT_STN, PLT_PLX, PLT_STN, PLT_STN, PLT_GTW, PLT_STN, PLT_STN], # 28 <-> 12
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 29 <-> 13
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, OBJ_END], # 30 <-> 14
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_PLX, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN]  # 31 <-> 15
]

const LAVA_FALL: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  0 <-> 16 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  1 <-> 17 
	[PLT_STN, ITM_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  2 <-> 18 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, ITM_PLX, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  4 <-> 20 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_GTW, PLT_STN, ITM_PLX, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_FIR, PLT_GTW, PLT_AIR, PLT_AIR, PLT_STN, ITM_PLX, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN], #  8 <-> 24 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, ITM_STN, ITM_FIR, PLT_AIR, PLT_AIR, PLT_STN], #  9 <-> 25 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 11 <-> 27 
	[PLT_STN], # 12 <-> 28 
	[PLT_STN], # 13 <-> 29 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN], # 14 <-> 30 
	[PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_FIR], # 15 <-> 31 
	[PLT_STN, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_FIR], # 16 <->  0
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_FIR], # 17 <->  1
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_FIR, PLT_AIR, PLT_STN], # 18 <->  2
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 19 <->  3
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 20 <->  4
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 21 <->  5
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 22 <->  6
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 23 <->  7
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 25 <->  9
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, ITM_PLX, PLT_AIR, PLT_STN], # 26 <-> 10
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 27 <-> 11
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, OBJ_END, PLT_STN], # 28 <-> 12
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 29 <-> 13
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_GTW, PLT_AIR, PLT_GTW, PLT_AIR, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN]  # 31 <-> 15
]

const AIRLOCK: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  0 <-> 16 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, ITM_GTW, PLT_STN], #  1 <-> 17 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_GTW, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  2 <-> 18 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_GTW, PLT_AIR, PLT_AIR, PLT_FIR, PLT_AIR, OBJ_END, PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  4 <-> 20 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], #  8 <-> 24 
	[PLT_STN, PLT_FIR], #  9 <-> 25 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, ITM_GTW, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_FIR, PLT_AIR, ITM_STN, ITM_STN, PLT_STN], # 11 <-> 27 
	[PLT_STN, PLT_FIR, PLT_AIR, ITM_FIR, ITM_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 13 <-> 29 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 14 <-> 30 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_PLX, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 17 <->  1
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 18 <->  2
	[PLT_STN, PLT_STN, PLT_STN, PLT_PLX, PLT_AIR, PLT_GTW], # 19 <->  3
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 20 <->  4
	[PLT_STN, PLT_STN, PLT_PLX, PLT_STN, PLT_AIR, PLT_STN], # 21 <->  5
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 22 <->  6
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_FIR, PLT_STN], # 23 <->  7
	[PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_STN, ITM_PLX, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 25 <->  9
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_GTW], # 26 <-> 10
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_GTW], # 27 <-> 11
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN], # 28 <-> 12
	[PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_GTW, ITM_STN, PLT_STN], # 29 <-> 13
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, ITM_STN, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN]  # 31 <-> 15
]












const test_LEVEL_2: Array[Array] = [
	[PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], #  0 <-> 16 
	[PLT_STN], #  1 <-> 17 
	[PLT_STN, ITM_PLX], #  2 <-> 18 
	[PLT_STN], #  3 <-> 19 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, OBJ_END], #  4 <-> 20 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  5 <-> 21 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], #  6 <-> 22 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  7 <-> 23 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  8 <-> 24 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], #  9 <-> 25 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 10 <-> 26 
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 11 <-> 27 
	[PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN], # 12 <-> 28 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 13 <-> 29 
	[PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 14 <-> 30 
	[PLT_AIR, PLT_STN, ITM_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN], # 15 <-> 31 
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 16 <->  0
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 17 <->  1
	[PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 18 <->  2
	[PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 19 <->  3
	[PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 20 <->  4
	[PLT_AIR, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN], # 21 <->  5
	[PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN], # 22 <->  6
	[PLT_AIR, PLT_STN, PLT_PLX, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_STN, PLT_STN], # 23 <->  7
	[PLT_STN, PLT_STN, PLT_PLX, PLT_STN, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN], # 24 <->  8
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_GTW, PLT_GTW, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 25 <->  9
	[PLT_STN, PLT_FIR, PLT_AIR, PLT_GTW, PLT_GTW, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 26 <-> 10
	[PLT_STN, PLT_STN, PLT_PLX, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 27 <-> 11
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 28 <-> 12
	[PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 29 <-> 13
	[PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_AIR, PLT_AIR, PLT_STN, PLT_AIR, PLT_STN], # 30 <-> 14
	[PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_STN, PLT_AIR, PLT_STN]  # 31 <-> 15
]
