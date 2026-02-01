extends StaticBody3D

@onready var MainCollider      : CollisionShape3D = $CollisionShape
@onready var OrthogonalCollider: CollisionShape3D = $OrthogonalArea/OrthogonalCollisionShape
@onready var GatewayMesh       : MeshInstance3D   = $Mesh
const INACTIVE_COLOR: Color = Color("268dab") # oklch(0.6 0.07 150)
const ACTIVE_COLOR  : Color = Color("6eccec") # oklch(0.8 0.17 150)
const OPEN_ALPHA    : float = 0.25

func _ready() -> void: TheLawsOfTheLand.perspective_changed.connect(_on_perspective_changed)
func _on_perspective_changed(Orthogonal: bool) -> void:
	if not MainCollider.disabled:
		OrthogonalCollider.disabled = not Orthogonal
		GatewayMesh.get_surface_override_material(0).albedo_color = ACTIVE_COLOR if Orthogonal else INACTIVE_COLOR
func _on_orthogonal_area_body_entered(body: Node3D) -> void:
	if not MainCollider.disabled and body.is_in_group("Player") and TheLawsOfTheLand.Perspective:
		var mat : StandardMaterial3D = GatewayMesh.get_surface_override_material(0).duplicate(true)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = OPEN_ALPHA
		GatewayMesh.set_surface_override_material(0, mat)
		MainCollider.disabled = true
