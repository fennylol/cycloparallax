extends Node3D
class_name  TheTowerNode
# ========= #
# variables #
# ========= #
@onready var WizardCenter: Node3D         = $WizardsSpinnyBit
@onready var BlocksCenter: Node3D         = $BlocksSpinnyBit
@onready var TinyWizard  : TinyWizardNode = $WizardsSpinnyBit/TinyWizard
# ================ # 
# internal utility #
# ================ #
#func _ready() -> void:
	#var i = 0
	#for block in blocks.get_children():
		#block.rotation.y = deg_to_rad(11.25 * i)
		#i+=1
func _process(delta: float) -> void:
	if Input.is_action_pressed("left")  and not TinyWizard.is_left_side_blocked():
		BlocksCenter.rotate(Vector3.UP,   TinyWizard.WALK_SPEED*delta)
	if Input.is_action_pressed("right") and not TinyWizard.is_right_side_blocked():
		BlocksCenter.rotate(Vector3.UP,  -TinyWizard.WALK_SPEED*delta)
	#if Input.is_action_pressed("jump")     : TinyWizard._jump(delta)
	if Input.is_action_just_pressed("jump"): TinyWizard._start_jump()
