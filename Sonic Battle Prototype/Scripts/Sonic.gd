extends CharacterBody3D


const SPEED = 4.0
const JUMP_VELOCITY = 6.0

const DASH_SPEED = 15.0
const AIRDASH_SPEED = 10.0

var gravity = 20

var facing_left = false

var jumping = false
var falling = false

var walking = false
var starting = false

var dashing = false

var can_airdash = true

var attacking = false

var can_air_attack = true

var current_punch = 0

var launch_power : Vector3

var hurt = false
var launched = false

func _process(delta):
	if $DropShadowRange.is_colliding():
		$DropShadow.visible = true
		$DropShadow.global_position.y = $DropShadowRange.get_collision_point().y
	else:
		$DropShadow.visible = false

func _physics_process(delta):
	
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
		starting = false
		walking = false
	else:
		jumping = false
		falling = false
		dashing = false
		can_airdash = true
		can_air_attack = true
		if Input.is_action_just_pressed("ui_left") && $AnimationPlayer.current_animation == "startWalk" && velocity.x < 0:
			velocity = Vector3(-DASH_SPEED, 4, velocity.z)
			$AnimationPlayer.play("dash")
			dashing = true
		elif Input.is_action_just_pressed("ui_right") && $AnimationPlayer.current_animation == "startWalk" && velocity.x > 0:
			velocity = Vector3(DASH_SPEED, 4, velocity.z)
			$AnimationPlayer.play("dash")
			dashing = true
		elif Input.is_action_just_pressed("ui_up") && $AnimationPlayer.current_animation == "startWalk" && velocity.z < 0:
			velocity = Vector3(velocity.x, 4, -DASH_SPEED)
			$AnimationPlayer.play("dash")
			dashing = true
		elif Input.is_action_just_pressed("ui_down") && $AnimationPlayer.current_animation == "startWalk" && velocity.z > 0:
			velocity = Vector3(velocity.x, 4, DASH_SPEED)
			$AnimationPlayer.play("dash")
			dashing = true
		
	
	if !attacking && !hurt:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		# Handle Jump.
		if Input.is_action_just_pressed("ui_select") && is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumping = true
		elif Input.is_action_just_pressed("ui_select") && !is_on_floor() && can_airdash:
			dashing = true
			can_airdash = false
			$AnimationPlayer.play("airdash")
			if direction:
				velocity = Vector3(direction.x * AIRDASH_SPEED, 4, direction.z * AIRDASH_SPEED)
			else:
				if facing_left:
					velocity = Vector3(-AIRDASH_SPEED, 4, 0)
				else:
					velocity = Vector3(AIRDASH_SPEED, 4, 0)
		
		
		if direction:
			if !starting && !walking && is_on_floor():
				starting = true
				$AnimationPlayer.play("startWalk")
			velocity.x = lerp(velocity.x, direction.x * SPEED, 0.1)
			velocity.z = lerp(velocity.z, direction.z * SPEED, 0.1)
		else:
			walking = false
			velocity.x = lerp(velocity.x, 0.0, 0.1)
			velocity.z = lerp(velocity.z, 0.0, 0.1)
		
		if velocity.x > 2:
			facing_left = false
			$Sprite3D.flip_h = false
			$Hitbox.rotation.y = deg_to_rad(0)
		elif velocity.x < -2:
			facing_left = true
			$Sprite3D.flip_h = true
			$Hitbox.rotation.y = deg_to_rad(180)
		
		if Input.is_action_just_pressed("ui_accept") && starting:
			if (facing_left && direction.x > 0) || (!facing_left && direction.x < 0):
				$AnimationPlayer.play("upStrong")
				launch_power = Vector3(0, 7, 0)
				if facing_left:
					velocity.x = 1
				else:
					velocity.x = -1
			else:
				$AnimationPlayer.play("strong")
				launch_power = Vector3(direction.x * 20, 5, direction.z * 20)
			attacking = true
		elif Input.is_action_just_pressed("ui_accept") && dashing && can_airdash:
			can_airdash = false
			attacking = true
			$AnimationPlayer.play("dashAttack")
			launch_power = Vector3(velocity.x, 2, velocity.z)
			velocity.y = 3
		elif Input.is_action_just_pressed("ui_accept") && !dashing && !is_on_floor() && can_air_attack:
			attacking = true
			can_air_attack = false
			$AnimationPlayer.play("airAttack")
			if facing_left:
				launch_power = Vector3(-5, -2, 0)
			else:
				launch_power = Vector3(5, -2, 0)
			velocity.y = 4
		elif Input.is_action_just_pressed("ui_accept") && is_on_floor() && !starting:
			attacking = true
			$AnimationPlayer.play("punch1")
			launch_power = Vector3(0, 2, 0)
			current_punch = 1
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
	
	handle_animation()
	move_and_slide()
	
func handle_animation():
	if !attacking && !hurt:
		if is_on_floor():
			if !starting:
				if round(velocity.x) != 0 || round(velocity.z) != 0:
					$AnimationPlayer.play("walk")
				else:
					$AnimationPlayer.play("idle")
		else:
			if !dashing:
				if velocity.y > 0:
					$AnimationPlayer.play("jump")
					falling = false
				elif velocity.y <= 0 && !falling:
					$AnimationPlayer.play("fall")
					falling = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "startWalk":
		starting = false
		walking = true
	elif anim_name == "airdash":
		dashing = false
		$AnimationPlayer.play("fall")
		falling = true
	elif anim_name == "strong":
		$AnimationPlayer.play("strongRecoil")
		if facing_left:
			velocity.x = 3
		else:
			velocity.x = -3
		velocity.y = 3
	elif anim_name == "strongRecoil" || anim_name == "upStrong":
		attacking = false
		starting = false
	elif anim_name == "dashAttack":
		attacking = false
		dashing = false
	elif anim_name == "airAttack":
		attacking = false
		jumping = false
		falling = true
		$AnimationPlayer.play("fall")
	elif anim_name == "punch1" || anim_name == "punch2" || anim_name == "punch3":
		if Input.is_action_pressed("ui_accept"):
			if current_punch == 1:
				$AnimationPlayer.play("punch2")
				launch_power = Vector3(0, 2, 0)
				current_punch = 2
			elif current_punch == 2:
				$AnimationPlayer.play("punch3")
				launch_power = Vector3(0, 2, 0)
				current_punch = 3
			elif current_punch == 3:
				$AnimationPlayer.play("strong")
				if facing_left:
					launch_power = Vector3(-20, 5, 0)
				else:
					launch_power = Vector3(20, 5, 0)
				current_punch = 0
		else:
			attacking = false
			current_punch = 0
	elif anim_name == "hurt" || anim_name == "hurtAir":
		hurt = false
		starting = false
	elif anim_name == "hurtStrong":
		if is_on_floor():
			hurt = false
			starting = false
		else:
			$AnimationPlayer.play("hurtStrong")

func get_hurt():
	hurt = true
	falling = false
	jumping = false
	if abs(velocity.x) > 8 || abs(velocity.z) > 8:
		$AnimationPlayer.play("hurtStrong")
	else:
		if jumping || falling || dashing:
			$AnimationPlayer.play("hurtAir")
		else:
			$AnimationPlayer.play("hurt")
	
	current_punch = 0
	dashing = false
	attacking = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("CanHurt") && body != self:
		body.velocity = launch_power
		body.get_hurt()
