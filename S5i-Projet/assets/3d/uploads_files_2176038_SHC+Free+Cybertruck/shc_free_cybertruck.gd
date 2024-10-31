extends Node3D

var speed = 0.01
var max_distance = 8
var distance_traveled = 0
var start_position = Vector3()

var avoiding = false
var avoid_start_position = Vector3()
var avoid_end_position = Vector3()
var avoid_direction = Vector3()
var avoid_time = 0.0
var avoid_duration = 100.0  # Durée de la manœuvre d’évitement

var original_rotation = Vector3()


var raycast: RayCast3D = null

func _ready():
	start_position = position
	

	raycast = $RayCast3D 
	assert(raycast != null, "Le RayCast3D n'a pas été trouvé !")
	

	raycast.enabled = true
	original_rotation = rotation
	

func _process(delta):
	distance_traveled = position.distance_to(start_position)
	
	# Si on est en train d'éviter, on suit la trajectoire parabolique
	if avoiding:
		follow_avoidance_path(delta)
		return

	# Détecte les collisions avec RayCast3D
	if raycast and raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_distance = raycast.global_transform.origin.distance_to(collision_point)
		
		if collision_distance <= 1.5:
			print("Obstacle détecté !")
			start_avoidance(collision_point)
			return

	# Mouvement normal si aucun obstacle n'est détecté
	if distance_traveled < max_distance:
		var direction = -transform.basis.x.normalized()
		position += direction * speed * delta
	else:
		speed = 0

# Initialisation de la manœuvre d’évitement
func start_avoidance(collision_point: Vector3):
	avoiding = true
	avoid_start_position = position
	avoid_end_position = avoid_start_position + Vector3(3, 0, 0)  # 3 unités vers l'avant sur l'axe X local
	avoid_direction = (avoid_end_position - avoid_start_position).normalized()
	avoid_time = 0.0
	speed = 0.02  # Vitesse réduite pendant l'évitement

# Fonction qui suit la trajectoire d'évitement avec la parabole
func follow_avoidance_path(delta):
	avoid_time += delta
	var t = avoid_time / avoid_duration  # Temps normalisé (0 à 1)

	# Interpolation linéaire pour la position en X le long de la trajectoire
	var x = lerp(0, 4, t)  # x passe de 0 à 4 pendant la durée de l'évitement
	var z = -0.375 * x * (x - 4)  # Calcul de y en fonction de x selon la trajectoire parabolique

	# Calcul de la position sur la parabole
	var next_position = avoid_start_position - avoid_direction * x  # Avancement sur la trajectoire en X
	next_position.z += z  # Applique la hauteur de la parabole
	
	move_and_orient(next_position - position)

	position = next_position

	# Fin de la manœuvre d'évitement
	if t >= 1.0:
		avoiding = false
		speed = 0.01  # Rétablit la vitesse normale
		reset_orientation()
		
func move_and_orient(direction: Vector3):
	# Met à jour la position
	position += direction
	
	# Oriente la voiture vers la direction de déplacement
	if direction.length() > 0:
		#look_at(position + direction, Vector3.UP)
		1+1
		
func reset_orientation():
	rotation = original_rotation
