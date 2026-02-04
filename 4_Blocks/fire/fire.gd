extends Area3D

@onready var MainCollider      : CollisionShape3D = $CollisionShape
@onready var OrthogonalCollider: CollisionShape3D = $OrthogonalCollisionShape
@onready var FireMesh          : MeshInstance3D   = $Mesh
const INACTIVE_COLOR: Color = Color("b84455") # oklch(0.55 0.15 15)
const ACTIVE_COLOR  : Color = Color("ec7380") # oklch(0.75 0.15 15)

func _ready() -> void: TheLawsOfTheLand.perspective_changed.connect(_on_perspective_changed)
func _on_perspective_changed(Orthogonal: bool) -> void:
	OrthogonalCollider.disabled = not Orthogonal
	FireMesh.get_surface_override_material(0).albedo_color = ACTIVE_COLOR if Orthogonal else INACTIVE_COLOR

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body._get_hurt()
