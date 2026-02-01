extends StaticBody3D

@onready var OrthogonalPlatform: CollisionShape3D = $OrthogonalCollisionShape
@onready var ParallaxMesh      : MeshInstance3D   = $Mesh
const INACTIVE_COLOR: Color = Color("628c6a") # oklch(0.6 0.07 150)
const ACTIVE_COLOR  : Color = Color("5edb81") # oklch(0.8 0.17 150)

func _ready() -> void: TheLawsOfTheLand.perspective_changed.connect(_on_perspective_changed)
func _on_perspective_changed(Orthogonal: bool) -> void:
	OrthogonalPlatform.disabled = not Orthogonal
	ParallaxMesh.get_surface_override_material(0).albedo_color = ACTIVE_COLOR if Orthogonal else INACTIVE_COLOR
