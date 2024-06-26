extends CharacterBody3D


const SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20

var user

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	if velocity.x >= 0:
		$Sprite3D.flip_h = false
	else:
		$Sprite3D.flip_h = true
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	queue_free()


func _on_hitbox_body_entered(body):
	if body.is_in_group("CanHurt") && body != user:
		body.velocity = Vector3(velocity.x, 3, velocity.z)
		body.get_hurt()
