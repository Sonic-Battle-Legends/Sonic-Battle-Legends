extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20
var immunity = "none"

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	velocity.x = lerp(velocity.x, 0.0, 0.1)
	velocity.z = lerp(velocity.z, 0.0, 0.1)
	
	move_and_slide()

func get_hurt():
	pass
