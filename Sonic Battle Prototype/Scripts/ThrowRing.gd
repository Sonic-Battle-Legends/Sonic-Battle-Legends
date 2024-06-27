extends CharacterBody3D

# The ring projectile sonic throws for his grounded "pow" move.
# All of the important code is handled from Sonic's script, but this handles physics.
# Original code by The8BitLeaf.

# The speed at which the ring falls, right now everyone and everything should have a gravity of 20.
var gravity = 20


func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	else:
		# If the ring hits the ground, it bounces.
		velocity.y = 2
	
	# The ring slows down after moving for a while, becoming stationary.
	velocity.x = lerp(velocity.x, 0.0, 0.02)
	velocity.z = lerp(velocity.z, 0.0, 0.02)
	

	move_and_slide()

@rpc("any_peer", "call_local")
func delete():
	queue_free()
