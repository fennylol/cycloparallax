extends Node3D

@onready var level_select = preload("res://0_Kingdom/level_select.tscn")
@onready var TheTower = preload("res://1_Tower/TheTower.tscn")

var level_select_node

func _ready() -> void:
	activate_level_select()

func _process(_delta) -> void:
	pass

func activate_level_select():
	level_select_node = level_select.instantiate()
	add_child(level_select_node)
	level_select_node.name = "LevelSelect"

func activate_the_tower(level: int = 0):
	## ADD THE TOWER NODE
	var new_tower : TheTowerNode = TheTower.instantiate()
	add_child(new_tower)
	move_child(new_tower,0)
	new_tower.name = "TheTower"
	
	## LOAD THE REQUESTED LEVEL
	var levelring : LevelRingNode = new_tower.get_child(2).get_child(2)
	levelring.current_level = level
	levelring.reload_the_whole_daggum_map()
	
	## KILL LEVEL SELECT IF IT EXISTS
	level_select_node.queue_free()
