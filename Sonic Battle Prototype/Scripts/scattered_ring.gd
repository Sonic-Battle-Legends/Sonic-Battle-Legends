extends CharacterBody3D

# The ring projectile sonic throws for his grounded "pow" move.
# All of the important code is handled from Sonic's script, but this handles physics.
# Original code by The8BitLeaf.

const DEFAULT_BOUNCE_VALUE: float = 4.0
var bounce_amount: float = DEFAULT_BOUNCE_VALUE
var blinking_period: float = 0.0

@export var sprite: Sprite3D

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		# The speed at which the ring falls
		velocity.y -= GlobalVariables.gravity * delta
	else:
		bounce_amount = move_toward(bounce_amount, 0, 0.4)
		# If the ring hits the ground, it bounces.
		velocity.y = bounce_amount
	
	# The ring slows down after moving for a while, becoming stationary.
	velocity.x = lerp(velocity.x, 0.0, 0.02)
	velocity.z = lerp(velocity.z, 0.0, 0.02)
	

	move_and_slide()
	
	if GlobalVariables.scattered_ring_timer != null:
		
		# blink faster as the time out approaches
		if blinking_period <= 0:
			blinking_period = GlobalVariables.scattered_ring_timer.time_left / 5.0
		blinking_period -= delta * 5
		if blinking_period <= 0.0:
			if sprite.is_visible_in_tree():
				sprite.hide()
			else:
				sprite.show()
		
		# delete when scaterred rings timer runs out
		if GlobalVariables.scattered_ring_timer.time_left <= 0:
			delete()



func blink():
	sprite.hide()


## add a method unique to the ring
## to prevent deleting another object
func delete_ring():
	if GlobalVariables.scattered_ring_timer != null\
	 and GlobalVariables.scattered_ring_timer.time_left <= 3.0:
		delete()


@rpc("any_peer", "call_local")
func delete():
	queue_free()
