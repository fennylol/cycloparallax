extends Control

func select_level(level:int):
	get_parent().activate_the_tower(level)

func _on_L1_button_pressed(): select_level(0)
func _on_L2_button_pressed(): select_level(1)
func _on_L3_button_pressed(): select_level(2)
func _on_L4_button_pressed(): select_level(3)
func _on_L5_button_pressed(): select_level(4)
func _on_L6_button_pressed(): select_level(5)
func _on_L7_button_pressed(): select_level(6)
func _on_L8_button_pressed(): select_level(7)
func _on_L9_button_pressed(): select_level(8)
func _on_L10_button_pressed(): select_level(9)
