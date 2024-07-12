extends Label3D

# the character that have this node as input
var cpu_character
var target

enum states {idle, pursue, attack, hit}
var current_state: states = states.idle

var target_direction: Vector3
var distance_to_target: float
var min_attack_distance: float = 0.5

var rings_around: Array
var possible_targets: Array

func _physics_process(_delta):
	# select target
	target = GlobalVariables.current_character
	rings_around = get_tree().get_nodes_in_group("Ring").duplicate()
	
	possible_targets.clear()
	possible_targets = rings_around.duplicate()
	possible_targets.append(target)
	
	if possible_targets.size() > 0:
		var new_target_distance
		for new_target in possible_targets:
			if is_instance_valid(new_target):
				new_target_distance = (new_target.position - position).length()
				if new_target_distance < distance_to_target:
					
					target = new_target
	
	# make the lifetotal label face the camera
	if get_viewport().get_camera_3d() != null:
		look_at(-get_viewport().get_camera_3d().position)
	
	if cpu_character:
		text = str(cpu_character.life_total)
		if target:
			# go closer to target
			target_direction = (target.position - cpu_character.position).normalized()
			distance_to_target = (target.position - cpu_character.position).length()
			#push_warning(distance_to_target)
			if distance_to_target > min_attack_distance:
				reset_properties()
				move_towards_target()
				# dash
				# cpu_character.dash_triggered = true
			# if close enough to attack, attack target
			else:
				attack_target()
		
			# if there is an obstacle jump
			#if jump_raycast:
				# jump check
				#cpu_character.jump_pressed = Input.is_action_just_pressed("jump")
		
			# guard/block/defend check
			#if target.is_in_group("Player") and target.attacking and distance_to_target <= min_attack_distance:
			#	cpu_character.guard_pressed = true
			#else:
			#	cpu_character.guard_pressed = false
	else:
		if cpu_character == null and get_parent() != null:
			cpu_character = get_parent()


func move_towards_target():
	# Set the input direction
	cpu_character.direction = (cpu_character.transform.basis * Vector3(target_direction.x, 0, target_direction.z)).normalized()


func attack_target():
	if target.is_in_group("Player") and target.hurt:
		# special attack check
		cpu_character.special_pressed = true
	else:
		# attack check
		cpu_character.attack_pressed = true


func reset_properties():
	cpu_character.direction = Vector3.ZERO
	cpu_character.special_pressed = false
	cpu_character.attack_pressed = false
	cpu_character.guard_pressed = false
	cpu_character.jump_pressed = false
	
