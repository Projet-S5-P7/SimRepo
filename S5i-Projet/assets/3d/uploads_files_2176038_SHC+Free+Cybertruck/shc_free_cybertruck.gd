extends Node3D

const ACCELERATION_MAX = 0.05
const VITESSE_MAX = 2
const WHEEL_BASE = 0.3  # Distance entre les roues

var speed = 0  # Vitesse actuelle
var direction = 1  # Direction actuelle du mouvement (1 pour avancer, -1 pour reculer)
var timer = 0  # Chronomètre pour contrôler la temporisation
var phase = 0  # 0: accélération, 1: ralentissement
var current_angle = 0  # Angle de rotation actuel du véhicule

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
		
		# Appliquer la rotation au véhicule
		var rotation_matrix = Basis(Vector3(0, 1, 0), angular_velocity * delta * direction)
		transform.basis = rotation_matrix * transform.basis
