extends Node3D

var speed = 1
var max_distance = 3
var distance_traveled = 0
var start_position = Vector3()

# Référence au RayCast3D (supprime @export si non nécessaire dans ton projet)
var raycast: RayCast3D = null

func _ready():
	start_position = position
	
	# Assigner le RayCast3D si ce n'est pas fait manuellement
	raycast = $RayCast3D  # Remplace par le bon chemin si ton RayCast3D n'est pas un enfant direct
	assert(raycast != null, "Le RayCast3D n'a pas été trouvé !")
	
	# Activer le raycast pour qu'il commence à détecter
	raycast.enabled = true

func _process(delta):
	distance_traveled = position.distance_to(start_position)

	# Vérifier si le RayCast3D détecte une collision
	if raycast and raycast.is_colliding():
		var collision_distance = raycast.get_collision_point().distance_to(position)
		if collision_distance <= 0.5:
			speed = 0  # Arrêter l'objet
			return  # Ne pas déplacer l'objet si l'obstacle est proche

	# Si la distance parcourue est inférieure à max_distance, continuer de bouger
	if distance_traveled < max_distance:
		var direction = -transform.basis.x.normalized()
		position += direction * speed * delta
	else:
		speed = 0  # Arrêter l'objet une fois qu'il a parcouru la distance maximale
