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
    
    # Vérification que le mesh est bien assigné
    assert(mesh != null, "Il faut un MeshInstance3D dans la scène!")

    # Création et configuration du matériau
    material = StandardMaterial3D.new()
    if material != null:
        mesh.material_override = material
        material.albedo_color = normal_color
    else:
        push_error("Le matériau n'a pas pu être créé!")

func _process(_delta):
    # Vérification que raycast et material sont bien initialisés
    if raycast != null and material != null:
        if raycast.is_colliding() and raycast.get_collider().name != "StaticFloor":
            material.albedo_color = detect_color  # Change en vert
        else:
            material.albedo_color = normal_color  # Retourne à la couleur normale
    else:
        push_error("Le RayCast ou le matériau n'est pas initialisé!")
