extends Control
class_name LevelSelectNode

@onready var button_node = $buttons/CenterContainer
signal level_selected(level_idx: int)

var LEVEL_BUTTONS : Array[Control] = []

func _ready():
	LEVEL_BUTTONS = [
	$buttons/CenterContainer/level_rows/level_columns/level_01,
	$buttons/CenterContainer/level_rows/level_columns/level_02,
	$buttons/CenterContainer/level_rows/level_columns/level_03,
	$buttons/CenterContainer/level_rows/level_columns/level_04,
	$buttons/CenterContainer/level_rows/level_columns/level_05,
	$buttons/CenterContainer/level_rows/level_columns2/level_06,
	$buttons/CenterContainer/level_rows/level_columns2/level_07,
	$buttons/CenterContainer/level_rows/level_columns2/level_08,
	$buttons/CenterContainer/level_rows/level_columns2/level_09,
	$buttons/CenterContainer/level_rows/level_columns2/level_10
	]
	for i in range(LEVEL_BUTTONS.size()):
		LEVEL_BUTTONS[i].get_child(3).visible = TheLawsOfTheLand.levels_completed[i]
		LEVEL_BUTTONS[i].get_child(2).visible = TheLawsOfTheLand.levels_complete_with_coin[i]

func _on_screen_size_changed() -> void:
	var screensize: Vector2 = get_viewport().size
	var size_ratio = screensize.x / 700
	button_node.scale = Vector2(size_ratio, size_ratio)

func _on_L1_button_pressed() : level_selected.emit(0)
func _on_L2_button_pressed() : level_selected.emit(1)
func _on_L3_button_pressed() : level_selected.emit(2)
func _on_L4_button_pressed() : level_selected.emit(3)
func _on_L5_button_pressed() : level_selected.emit(4)
func _on_L6_button_pressed() : level_selected.emit(5)
func _on_L7_button_pressed() : level_selected.emit(6)
func _on_L8_button_pressed() : level_selected.emit(7)
func _on_L9_button_pressed() : level_selected.emit(8)
func _on_L10_button_pressed(): level_selected.emit(9)
