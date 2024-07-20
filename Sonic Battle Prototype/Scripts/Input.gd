extends Node

# the character that have this node as input
var character


func _physics_process(_delta):
	character = GlobalVariables.current_character
	if character:
		# Get the input direction
		var input_dir = Input.get_vector("left", "right", "up", "down")
		character.direction = (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		# change input accordingly to the camera rotation
		if character.camera != null:
			character.direction *= character.camera.spin
		
		# jump check
		character.jump_pressed = Input.is_action_just_pressed("jump")
		
		# attack check
		character.attack_pressed = Input.is_action_pressed("punch")
		
		# upper check
		character.upper_pressed = Input.is_action_just_pressed("upper")
		
		# special attack check
		character.special_pressed = Input.is_action_just_pressed("special")
		
		# guard/block/defend check
		character.guard_pressed = Input.is_action_pressed("guard")
		
		# check to rotate camera
		# also checked on _input(event) for double tap guard as the original
		if Input.is_action_just_pressed("change_cam_position"):
			character.camera.rotate_camera()


## check if at least one of the directional button was pressed
func directional_just_pressed() -> bool:
	return Input.is_action_just_pressed("left") \
		or Input.is_action_just_pressed("right") \
		or Input.is_action_just_pressed("up") \
		or Input.is_action_just_pressed("down")


# check double tap
func _input(event):
	character = GlobalVariables.current_character
	if character:
		if event is InputEventKey and event.is_pressed() and character.is_on_floor():
			if character.last_keycode == event.keycode and character.doubletap_timer >= 0:
				if directional_just_pressed():
					character.dash_triggered = true
				if Input.is_action_just_pressed("guard"):
					character.camera.rotate_camera()
				character.last_keycode = 0
			else:
				character.last_keycode = event.keycode
			character.doubletap_timer = character.DOUBLETAP_DELAY
