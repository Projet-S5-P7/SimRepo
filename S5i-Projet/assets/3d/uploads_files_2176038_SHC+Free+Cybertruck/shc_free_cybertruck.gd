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


	if raycast and raycast.is_colliding():
		var collision_distance = raycast.get_collision_point().distance_to(position)
		if collision_distance <= 0.5:
			speed = 0  
			return  

	
	if distance_traveled < max_distance:
		var direction = -transform.basis.x.normalized()
		position += direction * speed * delta
	else:
		speed = 0  
