extends CharacterBody3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20
var user

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "idle":
		$AnimationPlayer.play("explode")
	elif anim_name == "explode":
		queue_free()


func _on_area_3d_body_entered(body):
	if body.is_in_group("CanHurt") && body != user:
		if $AnimationPlayer.current_animation == "idle":
			$AnimationPlayer.play("explode")
		if body.immunity != "set":
			body.velocity = Vector3(0, 7, 0)
			body.get_hurt()
