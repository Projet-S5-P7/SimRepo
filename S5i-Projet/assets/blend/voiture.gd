extends Node3D


var distance_traveled = 0
var start_position = Vector3()

var avoiding = false

var avoid_time = 0.0
var avoid_duration = 26.0
var parabola_width = 12.0  # Largeur de la parabole
var parabola_height = 1.2  # Hauteur maximale de la parabole



var raycast: RayCast3D = null
var centre: RayCast3D = null
var droit1: RayCast3D = null
var droit2: RayCast3D = null
var gauche1: RayCast3D = null
var gauche2: RayCast3D = null

const ACCELERATION_MAX = 0.01#0.001
const VITESSE_MAX = 0.1#0.1
const WHEEL_BASE = 0.3  # Distance entre les roues

var speed = 0  # Vitesse actuelle
var direction = 1  # Direction actuelle du mouvement (1 pour avancer, -1 pour reculer)
var recule_fait = 0


var current_angle = 0  # Angle de rotation actuel du véhicule

# WebSocket variables
var websocket_server: WebSocketMultiplayerPeer = null
var connected_clients = {}



func _ready():
	start_position = position
	# Accélère le jeu (par exemple, 2x plus rapide)
	Engine.time_scale = 2.0
	
	# Initialiser le serveur WebSocket
	websocket_server = WebSocketMultiplayerPeer.new()
	websocket_server.create_server(12345)  # Port 12345
	#get_tree().network_peer = websocket_server # Utiliser le SceneTree pour configurer le peer

	print("Serveur WebSocket démarré sur le port 12345")


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
	

func _process(delta):
	print("ca print")
	
	
	var effective_delta = delta
	# Traiter les événements WebSocket
	while websocket_server.get_available_packet_count() > 0:
		var packet = websocket_server.get_packet()
		var client_id = websocket_server.get_packet_peer()
		handle_received_packet(client_id, packet)

	var line_followers
	var distance

	if connected_clients.size() == 0:
		# Pas de client connecté, utiliser les RayCasts locaux
		line_followers = [
				centre.is_colliding(),
				droit1.is_colliding(),
				droit2.is_colliding(),
				gauche1.is_colliding(),
				gauche2.is_colliding()
			]
		distance = position.distance_to(start_position)
	else:
		# Utiliser les données du premier client connecté
		var client_data = connected_clients.values()[0]
		line_followers = client_data.get("line_follower", [])
		distance = client_data.get("distance", 0.0)
		effective_delta = client_data.get("delta", 0.0)

		# Envoyer le JSON avec la vitesse et l'angle actuel
		var data_to_send = {
			"speed": speed,
			"angle": current_angle
		}
		var json = JSON.new()
		var data_to_send_str = json.print(data_to_send)
		websocket_server.send_packet(data_to_send_str, client_data["id"])

	
	move_vehicle(direction, delta)
	distance_traveled = position.distance_to(start_position)
	
	if centre.get_collider().name != "StaticFloor" and  droit1.get_collider().name != "StaticFloor" and droit2.get_collider().name != "StaticFloor" and gauche1.get_collider().name != "StaticFloor" and gauche2.get_collider().name != "StaticFloor":
		speed = 0 #frein a la fin du parcour
		return
	# Si on est en train d'éviter, on suit la trajectoire parabolique
	if avoiding:
		follow_avoidance_path(delta)
		return
	
	if (speed > 0):	
		suiviLigne(delta)
		print("suiviLigne")

	# Détecte les collisions avec RayCast3D
	if raycast and raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_distance = raycast.global_transform.origin.distance_to(collision_point)
		if collision_distance <= 3:
			if(speed > -0.05 and recule_fait == 0):
				direction = -1
				return
			direction = 1
			recule_fait = 1
			if(speed > 0):
				start_avoidance(collision_point)
	
	
	if(avoiding ==true):
		print("avoiding")
	return



# Initialisation de la manœuvre d’évitement
func start_avoidance(collision_point: Vector3):
	avoiding = true
	avoid_time = 0.0
	#speed = 0.2  # Vitesse réduite pendant l'évitement

# Fonction qui suit la trajectoire d'évitement avec la parabole
func follow_avoidance_path(delta):

	avoid_time += delta
	var t = avoid_time / avoid_duration
	
	if t >= 0.985:#1.0:
		avoiding = false
		recule_fait = 0
		return
	
	# Calcul de la trajectoire parabolique
	var x = t * parabola_width
	var z = -4 * parabola_height * (t * (t - 1))  # Formule de parabole modifiée
	
	# Calcul de l'angle de braquage basé sur la dérivée de la parabole
	var dz_dx = -8 * parabola_height * (t - 0.5) / parabola_width
	var steer_angle = atan(dz_dx) #* 0.5  # Facteur 0.5 pour adoucir le braquage
	
	# Utilisation de votre fonction de direction
	steer_vehicle(steer_angle, delta)

	
func suiviLigne(delta: float):
	
	var steer = 0
	if centre.is_colliding() and centre.get_collider().name != "StaticBody3D":
		print(centre.get_collider().name)

	if droit1.is_colliding() and droit1.get_collider().name != "StaticFloor":
		print("Collision détectée à droite 1 avec :", droit1.get_collider().name)
		# Rotation légère vers la gauche pour se recentrer
		steer += -0.3

	if droit2.is_colliding() and droit2.get_collider().name != "StaticFloor":
		print("Collision détectée à droite 2 avec :", droit2.get_collider().name)
		# Rotation plus forte vers la gauche pour corriger plus rapidement
		steer += -0.55

	if gauche1.is_colliding() and gauche1.get_collider().name != "StaticFloor":
		print("Collision détectée à gauche 1 avec :", gauche1.get_collider().name)
		# Rotation légère vers la droite pour se recentrer
		steer += 0.3

	if gauche2.is_colliding() and gauche2.get_collider().name != "StaticFloor":
		print("Collision détectée à gauche 2 avec :", gauche2.get_collider().name)
		# Rotation plus forte vers la droite pour corriger plus rapidement
		steer += 0.55
	
	# Vérifier les collisions et ajuster la direction seulement si l'objet est "parcours"
	if centre.is_colliding() and centre.get_collider().name != "StaticFloor":
		print("Collision détectée au centre avec :", centre.get_collider().name)
		steer *= 0.3
	steer_vehicle(steer, delta)
		
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
		
func is_avoiding() -> bool:
	return avoiding
	
	
	
func handle_received_packet(client_id, packet):
	var json = JSON.new()
	var message = json.parse(packet)
	if message.error == OK:
		var data = message.result
		connected_clients[client_id] = data
		connected_clients[client_id]["id"] = client_id
		print("Données reçues du client :", data)
	
