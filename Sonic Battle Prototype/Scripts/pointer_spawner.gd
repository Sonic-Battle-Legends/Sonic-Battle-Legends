extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var done: bool = false

@export var raycaster: RayCast3D
@export var target_spot: Node3D


func _physics_process(_delta):
	if not done:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		var ground_height = raycaster.get_collision_point().y
		target_spot.global_position.y = ground_height
		
		
		if Input.is_action_just_pressed("punch"):
			done = true
			# spawn character on target location
			var new_position = position
			new_position.y = ground_height
			Instantiables.add_player(get_parent(), new_position)
			queue_free()

		move_and_slide()
