extends Node3D

<<<<<<< Updated upstream
const ACCELERATION_MAX = 0.05
const VITESSE_MAX = 2
const WHEEL_BASE = 0.3  # Distance entre les roues

=======
var max_distance = 8
var distance_traveled = 0
var start_position = Vector3()

var avoiding = false
var avoid_start_position = Vector3()
var avoid_end_position = Vector3()
var avoid_direction = Vector3()
var avoid_time = 0.0
var avoid_duration = 1.0  # Durée de la manœuvre d’évitement

var original_rotation = Vector3()


var raycast: RayCast3D = null
var centre: RayCast3D = null
var droit1: RayCast3D = null
var droit2: RayCast3D = null
var gauche1: RayCast3D = null
var gauche2: RayCast3D = null

const ACCELERATION_MAX = 0.05
const VITESSE_MAX = 2
const WHEEL_BASE = 0.3  # Distance entre les roues

>>>>>>> Stashed changes
var speed = 0  # Vitesse actuelle
var direction = 1  # Direction actuelle du mouvement (1 pour avancer, -1 pour reculer)
var timer = 0  # Chronomètre pour contrôler la temporisation
var phase = 0  # 0: accélération, 1: ralentissement
var current_angle = 0  # Angle de rotation actuel du véhicule
<<<<<<< Updated upstream

func _process(delta):
	timer += delta

	if phase == 0 and timer <= 2:
		# Avance pendant 2 secondes
		move_vehicle(1, delta)
	elif phase == 0 and timer > 2:
		# Passe à la phase de ralentissement après 2 secondes
		phase = 1
		timer = 0  # Réinitialise le chronomètre pour la phase de ralentissement
	elif phase == 1 and timer <= 3:
		# Ralentit pendant 3 secondes
		move_vehicle(0, delta)
	elif phase == 1 and timer > 3:
		# Réinitialise pour refaire le cycle
		phase = 0
		timer = 0

	# Appliquer la vitesse à la position
	var movement_direction = -transform.basis.x.normalized()
	position += movement_direction * speed * delta

	# Appliquer la rotation en fonction de l'angle de braquage
	steer_vehicle(0.05, delta)  # Vous pouvez ajuster l'angle de braquage (0.1 radians ici)
=======

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
	move_vehicle(1, delta)
	
	suiviLigne(delta)
	
	
	return

func start_avoidance(collision_point: Vector3):
	avoiding = true
	avoid_start_position = position
	avoid_end_position = avoid_start_position + Vector3(3, 0, 0)  # 3 unités vers l'avant sur l'axe X local
	avoid_direction = (avoid_end_position - avoid_start_position).normalized()
	avoid_time = 0.0
	speed = 0.2  # Vitesse réduite pendant l'évitement
>>>>>>> Stashed changes

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

func steer_vehicle(steer_angle: float, delta: float):
	if speed != 0:
		# Calculer le rayon de braquage en fonction de l'angle des roues avant
		var turn_radius = WHEEL_BASE / tan(steer_angle)
		# Calculer la vitesse angulaire (en radians par seconde)
		var angular_velocity = speed / turn_radius
		
		# Appliquer la rotation
		current_angle += angular_velocity * delta * direction
		
<<<<<<< Updated upstream
		# Appliquer la rotation au véhicule
		var rotation_matrix = Basis(Vector3(0, 1, 0), angular_velocity * delta * direction)
		transform.basis = rotation_matrix * transform.basis
=======
		
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
		steer_vehicle(-0.1, delta)

	elif droit2.is_colliding() and droit2.get_collider().name != "StaticFloor":
		print("Collision détectée à droite 2 avec :", droit2.get_collider().name)
		# Rotation plus forte vers la gauche pour corriger plus rapidement
		steer_vehicle(-0.8, delta)

	elif gauche1.is_colliding() and gauche1.get_collider().name != "StaticFloor":
		print("Collision détectée à gauche 1 avec :", gauche1.get_collider().name)
		# Rotation légère vers la droite pour se recentrer
		steer_vehicle(0.1, delta)

	elif gauche2.is_colliding() and gauche2.get_collider().name != "StaticFloor":
		print("Collision détectée à gauche 2 avec :", gauche2.get_collider().name)
		# Rotation plus forte vers la droite pour corriger plus rapidement
		steer_vehicle(0.8, delta)
		
		
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
	
>>>>>>> Stashed changes
