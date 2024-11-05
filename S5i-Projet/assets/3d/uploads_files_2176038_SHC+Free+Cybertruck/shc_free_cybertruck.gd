extends Node3D


var max_distance = 8
var distance_traveled = 0
var start_position = Vector3()

var avoiding = false
var avoid_start_position = Vector3()
var avoid_end_position = Vector3()
var avoid_direction = Vector3()
var avoid_time = 0.0
var avoid_duration = 15.0
var parabola_width = 15.0  # Largeur de la parabole
var parabola_height = 1.5  # Hauteur maximale de la parabole

var original_rotation = Vector3()


var raycast: RayCast3D = null
var centre: RayCast3D = null
var droit1: RayCast3D = null
var droit2: RayCast3D = null
var gauche1: RayCast3D = null
var gauche2: RayCast3D = null

const ACCELERATION_MAX = 0.01#0.001
const VITESSE_MAX = 0.7#0.1
const WHEEL_BASE = 0.3  # Distance entre les roues

var speed = 0  # Vitesse actuelle
var direction = 1  # Direction actuelle du mouvement (1 pour avancer, -1 pour reculer)
var timer = 0  # Chronomètre pour contrôler la temporisation
var phase = 0  # 0: accélération, 1: ralentissement
var current_angle = 0  # Angle de rotation actuel du véhicule

var duration = 18.0
var total_ticks = 60 * duration
var trajectory_points = []


func _ready():
	start_position = position
	

	raycast = $RayCast3D 
	assert(raycast != null, "Le RayCast3D n'a pas été trouvé !")
	
	centre = $centre
	assert(centre != null, "Le centre n'a pas été trouvé !")
	droit1 = $droit1
	assert(droit1 != null, "Le centre n'a pas été trouvé !")
	droit2 = $droit2
	assert(droit2 != null, "Le centre n'a pas été trouvé !")
	gauche1 = $gauche1
	assert(gauche1 != null, "Le centre n'a pas été trouvé !")
	gauche2 = $gauche2
	assert(gauche2 != null, "Le centre n'a pas été trouvé !")
	

	raycast.enabled = true
	original_rotation = rotation
	
	

func _process(delta):
	print("process")
	move_vehicle(direction, delta)
	distance_traveled = position.distance_to(start_position)
	
	
	
	# Si on est en train d'éviter, on suit la trajectoire parabolique
	if avoiding:
		follow_avoidance_path(delta)
		return

	# Détecte les collisions avec RayCast3D
	if raycast and raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_distance = raycast.global_transform.origin.distance_to(collision_point)
		#
		if collision_distance <= 3:
			
			start_avoidance(collision_point)
			
	suiviLigne(delta)
	return



# Initialisation de la manœuvre d’évitement
func start_avoidance(collision_point: Vector3):
	avoiding = true
	avoid_start_position = position
	avoid_end_position = avoid_start_position + Vector3(3, 0, 0)  # 3 unités vers l'avant sur l'axe X local
	avoid_direction = (avoid_end_position - avoid_start_position).normalized()
	avoid_time = 0.0
	#speed = 0.2  # Vitesse réduite pendant l'évitement

# Fonction qui suit la trajectoire d'évitement avec la parabole
func follow_avoidance_path(delta):

	avoid_time += delta
	var t = avoid_time / avoid_duration
	
	if t >= 1.0:
		avoiding = false
		return
	
	# Calcul de la trajectoire parabolique
	var x = t * parabola_width
	var z = -4 * parabola_height * (t * (t - 1))  # Formule de parabole modifiée
	
	# Calcul de l'angle de braquage basé sur la dérivée de la parabole
	var dz_dx = -8 * parabola_height * (t - 0.5) / parabola_width
	var steer_angle = atan(dz_dx) * 0.5  # Facteur 0.5 pour adoucir le braquage
	
	# Utilisation de votre fonction de direction
	steer_vehicle(steer_angle, delta)

func move_and_orient(direction: Vector3):
	# Met à jour la position
	position += direction
	
	# Oriente la voiture vers la direction de déplacement
	if direction.length() > 0:
		look_at(position + direction, Vector3.UP)
		
		
func reset_orientation():
	rotation = original_rotation
	
func suiviLigne(delta: float):
	

	if centre.is_colliding() and centre.get_collider().name != "StaticBody3D":
		print(centre.get_collider().name)

	# Vérifier les collisions et ajuster la direction seulement si l'objet est "parcours"
	if centre.is_colliding() and centre.get_collider().name != "StaticFloor":
		print("Collision détectée au centre avec :", centre.get_collider().name)
		# Continuer à avancer en ligne droite sans ajustement de rotation
		

	elif droit1.is_colliding() and droit1.get_collider().name != "StaticFloor":
		print("Collision détectée à droite 1 avec :", droit1.get_collider().name)
		# Rotation légère vers la gauche pour se recentrer
		steer_vehicle(-0.15, delta)

	elif droit2.is_colliding() and droit2.get_collider().name != "StaticFloor":
		print("Collision détectée à droite 2 avec :", droit2.get_collider().name)
		# Rotation plus forte vers la gauche pour corriger plus rapidement
		steer_vehicle(-0.55, delta)

	elif gauche1.is_colliding() and gauche1.get_collider().name != "StaticFloor":
		print("Collision détectée à gauche 1 avec :", gauche1.get_collider().name)
		# Rotation légère vers la droite pour se recentrer
		steer_vehicle(0.15, delta)

	elif gauche2.is_colliding() and gauche2.get_collider().name != "StaticFloor":
		print("Collision détectée à gauche 2 avec :", gauche2.get_collider().name)
		# Rotation plus forte vers la droite pour corriger plus rapidement
		steer_vehicle(0.55, delta)
		
		
func move_vehicle(input_direction: int, delta: float):
	if input_direction == 0:
		# Ralentir jusqu'à ce que la vitesse atteigne zéro
		if speed > 0:
			speed -= ACCELERATION_MAX * delta
			speed = max(speed, 0)
		elif speed < 0:
			speed += ACCELERATION_MAX * delta
			speed = min(speed, 0)
	elif input_direction == 1:
		# Accélérer vers l'avant jusqu'à la vitesse maximale
		speed += ACCELERATION_MAX * delta
		speed = min(speed, VITESSE_MAX)
	elif input_direction == -1:
		# Accélérer vers l'arrière jusqu'à la vitesse maximale en sens inverse
		speed -= ACCELERATION_MAX * delta
		speed = max(speed, -VITESSE_MAX)
		
	# Appliquer la vitesse à la position
	var movement_direction = -transform.basis.x.normalized()
	position += movement_direction * speed * delta


func steer_vehicle(steer_angle: float, delta: float):
	if speed != 0:
		# Calculer le rayon de braquage en fonction de l'angle des roues avant
		var turn_radius = WHEEL_BASE / tan(steer_angle)
		# Calculer la vitesse angulaire (en radians par seconde)
		var angular_velocity = speed / turn_radius
		
		# Appliquer la rotation
		current_angle += angular_velocity * delta * direction
		
		# Appliquer la rotation au véhicule
		var rotation_matrix = Basis(Vector3(0, 1, 0), angular_velocity * delta * direction)
		transform.basis = rotation_matrix * transform.basis
	
