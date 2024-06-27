extends CharacterBody3D

# The shockwave projectile Sonic sends from his "shot" attacks.
# Original code by The8BitLeaf.

# Movement speed
const SPEED = 5.0

# The speed at which the wave falls, right now everyone and everything should have a gravity of 20.
var gravity = 20

# The active player that spawned this projectile. Hitboxes will not interact with the user.
var user

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	# Chooses direction based on where the player sent it.
	if velocity.x >= 0:
		$Sprite3D.flip_h = false
	else:
		$Sprite3D.flip_h = true
	
	# If the wave hits a wall, it disappears.
	if is_on_wall():
		queue_free()
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	# Disappears when the animation ends.
	queue_free()


func _on_hitbox_body_entered(body):
	# If the hitbox hits something that can be hurt and isn't the user, they will take a hit and
	# be launched in the direction the wave is moving.
	if body.is_in_group("CanHurt") && body != user:
		if body.immunity != "shot":
			# If the collision body is immune to "shot" moves, they will not be affected.
			body.velocity = Vector3(velocity.x, 3, velocity.z)
			body.get_hurt()
