extends CharacterBody3D

# The mines that Sonic sets in his "set" moves.
# These stay in place for about a second before exploding on their own, but can
# be prematurely detonated if a player or enemy touches them.
# Original code by The8BitLeaf.

# The active player that spawned this projectile. Hitboxes will not interact with the user.
var user

var damage = 10

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		# The speed at which the mine falls
		velocity.y -= GlobalVariables.gravity * delta
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	# If the idle animation ends, the mine automatically explodes.
	# If the explosion animation ends, the mine is destroyed.
	if anim_name == "idle":
		$AnimationPlayer.play("explode")
		Audio.play(Audio.setExplosion, self)
	elif anim_name == "explode":
		queue_free()

@rpc("any_peer", "reliable")
func _on_area_3d_body_entered(body):
	# If the hitbox hits something that can be hurt and isn't the user, they will take a hit and
	# be launched upwards.
	if body.is_in_group("CanHurt") && body != user:
		# The mine automatically explodes on contact if it hasn't exploded already.
		if $AnimationPlayer.current_animation == "idle":
			$AnimationPlayer.play("explode")
			Audio.play(Audio.setExplosion, self)
			Audio.play(Audio.hitStrong, self)
		if body.immunity != "set":
			# If the collision body is immune to "set" moves, they will not be affected.
			# body.get_hurt.rpc_id(body.get_multiplayer_authority(), Vector3(0, 7, 0))
			body.get_hurt(Vector3(0, 7, 0), user, damage)
