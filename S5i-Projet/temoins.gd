extends Node3D

@export var raycast: RayCast3D  # Pour assigner le RayCast dans l'inspecteur
@onready var mesh = $MeshInstance3D  # Référence au MeshInstance3D

# Couleurs
var normal_color = Color(1, 1, 1)  # Blanc
var detect_color = Color(0, 1, 0)  # Vert

# Matériau standard
var material: StandardMaterial3D

func _ready():
	# Vérification que le RayCast est assigné
	assert(raycast != null, "Il faut assigner un RayCast dans l'inspecteur!")
	
	# Création et configuration du matériau
	material = StandardMaterial3D.new()
	mesh.material_override = material
	material.albedo_color = normal_color

func _process(_delta):
	if raycast.is_colliding() and raycast.get_collider().name != "StaticFloor":
		material.albedo_color = detect_color  # Change en vert
	else:
		material.albedo_color = normal_color  # Retourne à la couleur normale
