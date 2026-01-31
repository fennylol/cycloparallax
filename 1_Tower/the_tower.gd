extends Node3D
class_name  TheTowerNode
# ========= #
# variables #
# ========= #
@onready var WizardCenter: Node3D          = $WizardsSpinnyBit
@onready var BlocksCenter: Node3D          = $BlocksSpinnyBit
@onready var TinyWizard  : TinyWizardNode  = $WizardsSpinnyBit/TinyWizard
@onready var DollyCamera : DollyCameraNode = $WizardsSpinnyBit/DollyCamera
# ================ # 
# internal utility #
# ================ #
#func _ready() -> void:
	#var i = 0
	#for block in blocks.get_children():
		#block.rotation.y = deg_to_rad(11.25 * i)
		#i+=1
func _process(delta: float) -> void:
	BlocksCenter.rotate(Vector3.UP, TinyWizard.WalkingSpeed*delta)
	
	if Input.is_action_just_pressed("perspective_spell"):
		DollyCamera.Zooming = not DollyCamera.Zooming
