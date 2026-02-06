extends HBoxContainer

@onready var img: TextureRect = $TextureRect
@onready var txt: Label = $Label

#func _init(clr: Color, lbl: String, sze: int) -> void:
	#_set_img_scale(sze)
	#_set_color(clr)
	#_set_label(lbl)
func _set_img_scale(sze: int) -> void: img.custom_minimum_size = Vector2i(sze, sze)
func _set_color(clr: Color)    -> void: img.modulate = clr
func _set_label(lbl: String)   -> void: txt.text     = lbl
