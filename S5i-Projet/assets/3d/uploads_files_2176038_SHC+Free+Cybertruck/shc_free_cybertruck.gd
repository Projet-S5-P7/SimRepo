extends Node3D

var speed = 1
var max_distance = 3
var distance_traveled = 0
var start_position = Vector3()


var raycast: RayCast3D = null

func _ready():
	start_position = position
	

	raycast = $RayCast3D 
	assert(raycast != null, "Le RayCast3D n'a pas été trouvé !")
	

	raycast.enabled = true
	

func _process(delta):
	distance_traveled = position.distance_to(start_position)
	#print("on proces")
	
	#raycast.cast_to = Vector3(0, 0, -3)
	
	
	

	if raycast and raycast.is_colliding():
		print("vois quelque chose")
		var collision_point = raycast.get_collision_point()
		var collision_distance = raycast.global_transform.origin.distance_to(collision_point) #raycast.get_collision_point().distance_to(position)
		print(collision_distance)
		
		var collider = raycast.get_collider()
		if collider:
			print("Nom de l'objet touché :", collider.name)
		
		if collision_distance <= 1.5:
			print("moins de 0.5")
			speed = 0  
			return  

	
	if distance_traveled < max_distance:
		var direction = -transform.basis.x.normalized()
		position += direction * speed * delta
	else:
		speed = 0  
