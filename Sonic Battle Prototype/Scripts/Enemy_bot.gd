extends CharacterBody3D

# This is the script for the bots.
# the bots "inputs" comes from the "cpu_controller" node
# Original code by The8BitLeaf. code modified later on

# Basic movement speed values for Sonic.
const SPEED = 4.0
const JUMP_VELOCITY = 6.0

# Dash speed is the speed value for the dash move executed by double tapping a direction on the ground
# Sonic's midair jump ability is an air dash, and the speed is determined by airdash speed.
const DASH_SPEED = 15.0
const AIRDASH_SPEED = 10.0

# amount of time allowed between presses to consider it as a double tap
const DOUBLETAP_DELAY: float = 0.2

# max distance from ground to allow jump through coyote time
const MAX_COYOTE_GROUND_DISTANCE: float = 0.1

# default life total value
const MAX_LIFE_TOTAL = 100

# default max special amount
const MAX_SPECIAL_AMOUNT = 100

# max number of rings to be created when scattering rings
const MAX_SCATTERED_RINGS_ALLOWED: int = 8

# heal points per ring collected
const HEAL_POINTS_PER_RING: int = 2

# Boolean to check if Sonic is facing left or right
var facing_left = false

# input direction
var direction = Vector3.ZERO

# Booleans for checking when Sonic is jumping or falling, used to make sure
# that Sonic plays the correct animations.
var jumping = false
var falling = false
var jump_clicked: bool = false

# Starting determines the state where Sonic is accelerating, usually only impacts ground moves.
# When starting, Sonic can execute a dash or strong attack on the ground.
# Walking is just to differentiate his moving state.
var walking = false
var starting = false

# Boolean for when Sonic is in the middle of a dash animation.
var dashing = false

# Boolean that makes sure Sonic can only airdash once in the air. Resets when on the ground.
var can_airdash = true

# Boolean to determine when to lock Sonic's moveset during an attack.
var attacking = false

# Like can_airdash, but instead determines if a midair attack can be executed.
var can_air_attack = true

# The current punching state for the 3-hit combo.
var current_punch = 0

# This vector determines the strength and direction the hitbox object sends opponents.
# Each move changes the launch power when necessary and the animation handles the hitbox position.
var launch_power : Vector3

# States for when Sonic is hurt, locking his actions.
var hurt = false
var launched = false

# Skills! These strings determine what Sonic's grounded and midair special type are.
# Immunity determines which category of special move Sonic is immune to.
var ground_skill
var air_skill
var immunity

# Sonic's midair "pow" special move bounces off the ground, so this state makes sure he does that.
var bouncing = false

# active_ring is the object recently created by Sonic's grounded "pow" move, for checking constant positioning.
# thrown_ring indicates when a ring is on the field, to avoid calling a null active_ring
var active_ring: CharacterBody3D
var thrown_ring = false

# The state in which Sonic is moving in the direction of active_ring.
var chasing_ring = false

# The mine object currently on the field, to ensure only one mine can be used at a time.
var active_mine

# Since Sonic's "pow" move is a melee attack and uses his regular hitboxes,
# this boolean ensures that immunities still apply.
var pow_move = false

# coyote time variables
# timer for coyote time
var coyote_timer: SceneTreeTimer
# distance from ground when on air
var coyote_ground_distance: float = 0.0

# store the keycode of the last button pressed for double tap check
var last_keycode: int = 0

# store the time left for double tap check
var doubletap_timer = DOUBLETAP_DELAY
# to allow dash only after a double tap
var dash_triggered = false

# values presented on hud
var life_total: int = MAX_LIFE_TOTAL
var special_amount: int = 0
var points: int = 0

# value that will increase when pressing healing to trigger the heal method
var healing_time: float = 0.0
# the rate the healing_time will increase
var healing_pace: float = 0.1
# the amount of heling_time to trigger a heal call
var healing_threshold: float = 3.0

var punch_timer: SceneTreeTimer

# store the input state transmited by a input node or CPU node
# this allows to separate the inputs from the character script
# which helps creating CPU characters
var punch_pressed: bool = false
var special_pressed: bool = false
var jump_pressed: bool = false
var attack_pressed: bool = false
var guard_pressed: bool = false

# rings collected in a stage
# start with an amount to test
var rings: int = MAX_SCATTERED_RINGS_ALLOWED

# Head Up Display
#@export_category("HUD")
#@export var hud: Control

@export var mesh_node: Node3D

var camera = null


func _enter_tree():
	set_multiplayer_authority(0) #str(name).to_int())
	#set_multiplayer_authority(GlobalVariables.character_id)
	
	var bots_list = get_tree().get_nodes_in_group("Bot")
	name = "BOT" + str(bots_list.size())


func _ready():
	#if not is_multiplayer_authority(): return
	
	if GlobalVariables.play_online == false:
		points = GlobalVariables.bot_points
	
	# update the hud with the default values when starting the game
	#hud.update_hud(life_total, special_amount, points)
	
	if GlobalVariables.current_stage == null:
		ground_skill = "POW"
		air_skill = "POW"


# Setting a drop shadow is weird in _physics_process(), so the drop shadow code is in _process().
func _process(delta):
	# If the drop shadow ray detects ground, it sets the visual shadow at the collision point.
	if $DropShadowRange.is_colliding():
		$DropShadow.visible = true
		var ground_height = $DropShadowRange.get_collision_point().y
		$DropShadow.global_position.y = ground_height
		
		# coyote time to help responsiveness jump
		if !is_on_floor():
			coyote_ground_distance = position.y - ground_height
			if coyote_timer == null:
				create_coyote_timer()
			
			# call coyote light feet here so it can work with coyote edge by creating it's timer
			coyote_light_feet()
	else:
		$DropShadow.visible = false
	
	# to check the time between key presses
	# could create an actual timer instead
	if doubletap_timer > 0:
		doubletap_timer -= delta


func _physics_process(delta):
	#if !is_multiplayer_authority(): return
	
	
	if !is_on_floor():
		# add the gravity.
		# The speed at which Sonic falls
		velocity.y -= GlobalVariables.gravity * delta
		# Since starting and walking only do things on the ground, they are set to inactive here.
		starting = false
		walking = false
	else:
		# remove current coyote timer form the variable
		coyote_timer = null
		# Being on the ground means you aren't jumping or falling
		jumping = false
		falling = false
		jump_clicked = false
		# Because Sonic's dash is a sort of jump, this is how the move resets itself.
		# For characters that slide along the ground (i.e. Shadow), this may change.
		dashing = false
		# Midair moves can only be used after a jump once, and they can be used again after touching the ground.
		can_airdash = true
		can_air_attack = true
		# If Sonic is in his midair "pow" bouncing state, his velocity sends him upwards off the ground.
		if bouncing:
			velocity.y = 5
			can_air_attack = false	# As funny as it would be to have the SA2 bounce spam, it would be too OP here.
		
		handle_dash()
		
	if !attacking && !hurt:
		handle_jump()
		
		handle_movement_input()
		
		handle_sprite_orientation()
		
		handle_attack()
		
		handle_healing()
		
		rotate_model()
		
	else:
		# if Sonic is in his attacking or hurt state, he slows to a halt.
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
	
	# defeated if going lower than the lower limit of the map or
	# life total is less than or equal to zero
	# or the character is not in a battle and don't have rings
	if position.y < -5.0:
		defeated()
	
	# If Sonic is currently chasing a ring he threw from his ground "pow" move, he accelerates to its position.
	if chasing_ring and active_ring != null:
		velocity = lerp(velocity, (active_ring.transform.origin - transform.origin) * 20, 0.5)
	
	# Automatically handle the animation and character controller physics.
	handle_animation()
	move_and_slide()


## handle the movement of the character given an input
func handle_movement_input():	
	# Code for handling basic movement
	if direction:
		# If Sonic is at a standstill before moving, he enters his starting state for dashes and strong attacks.
		if !starting && !walking && is_on_floor():
			starting = true
			$AnimationPlayer.play("startWalk")
			$sonicrigged2/AnimationPlayer.play("WALK START")
		velocity.x = lerp(velocity.x, direction.x * SPEED, 0.1)
		velocity.z = lerp(velocity.z, direction.z * SPEED, 0.1)
	else:
		walking = false
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)


## Code for determining the direction the character is facing.
func handle_sprite_orientation():
	$Hitbox.rotation = $sonicrigged2.rotation
	# Since some moves hold backwards without turning.
	#var flip_threshold = 2
	# if the character is on idle or walk animation, flip the sprite with the input
	#if walking or starting:
	#	flip_threshold = 2


## method to check and perform the dash movement
func handle_dash():
	# This set of "if" statements handles the dash. Pressing your current velocity direction
	# while in the starting state causes Sonic to dash in that direction, recreating the "double-tap" input
	# This is probably a very workaround solution and there's probably a way to make it work better
	# But this is the best solution I could come up with.
	# added a dash_triggered to prevent dashing when simply pressing diagonals
	# (was suposed to substitute the double tap completely but the character was making a
	# jump animation instead of dash animation so added the dash_triggered variable instead)
	if dash_triggered:
		velocity = Vector3(velocity.normalized().x * DASH_SPEED, 4, velocity.normalized().z * DASH_SPEED)
		dashing = true
		$AnimationPlayer.play("dash")
		$sonicrigged2/AnimationPlayer.play("DASH")
		'''
		if $AnimationPlayer.current_animation == "startWalk":
			#velocity = direction * DASH_SPEED
			#velocity.y = 4
			$AnimationPlayer.play("dash")
			dashing = true
		if velocity.x < 0 and Input.is_action_just_pressed("left"):
			velocity = Vector3(-DASH_SPEED, 4, velocity.z)
			$AnimationPlayer.play("dash")
			$sonicrigged2/AnimationPlayer.play("DASH")
			dashing = true
		elif velocity.x > 0 and Input.is_action_just_pressed("right"):
			velocity = Vector3(DASH_SPEED, 4, velocity.z)
			$AnimationPlayer.play("dash")
			$sonicrigged2/AnimationPlayer.play("DASH")
			dashing = true
		elif velocity.z < 0 and Input.is_action_just_pressed("up"):
			velocity = Vector3(velocity.x, 4, -DASH_SPEED)
			$AnimationPlayer.play("dash")
			$sonicrigged2/AnimationPlayer.play("DASH")
			dashing = true
		elif velocity.z > 0 and Input.is_action_just_pressed("down"):
			velocity = Vector3(velocity.x, 4, DASH_SPEED)
			$AnimationPlayer.play("dash")
			$sonicrigged2/AnimationPlayer.play("DASH")
			dashing = true
		'''
	dash_triggered = false


## method to control the jump
func handle_jump():
	# If you're in the air, Sonic performs his midair action (as long as he hasn't used it yet.)
	if jump_pressed && (is_on_floor() || coyote_time()):
		Audio.play(Audio.jump, self)
		velocity.y = JUMP_VELOCITY
		jumping = true
		jump_clicked = true
		# remove current coyote timer form the variable
		coyote_timer = null
	elif jump_pressed && !is_on_floor() && can_airdash:
		Audio.play(Audio.jump, self) #spin)
		dashing = true
		can_airdash = false
		# remove current coyote timer form the variable
		coyote_timer = null
		$AnimationPlayer.play("airdash")
		$sonicrigged2/AnimationPlayer.play("DJMP 1")
		# If Sonic is inputting a direction, he airdashes in that direction.
		# If no direction is held, he moves horizontally in the direction he's facing.
		if direction:
			velocity = Vector3(direction.x * AIRDASH_SPEED, 4, direction.z * AIRDASH_SPEED)
		else:
			var new_velocity = $sonicrigged2.transform.basis.z.normalized() * AIRDASH_SPEED
			new_velocity.y = 4
			velocity = new_velocity
			
			'''
			if facing_left:
				velocity = Vector3(-AIRDASH_SPEED, 4, 0)
			else:
				velocity = Vector3(AIRDASH_SPEED, 4, 0)
			'''


## help responsiveness feeling by forgiving the difference between the human response and the machine accuracy
func coyote_time() -> bool:
	if coyote_edge() and coyote_light_feet():
		push_warning("coyote light feet edge case")
	return coyote_edge() or coyote_light_feet()


## help responsiveness feeling by allowing to jump right after passing an edge
func coyote_edge() -> bool:
	var can_jump = false
	if coyote_timer != null and coyote_timer.time_left > 0 and jump_clicked == false:
		can_jump = true
	return can_jump


## help responsiveness feeling by allowing to jump right before touching the ground
func coyote_light_feet() -> bool:
	var can_jump = false
	if !is_on_floor() and coyote_ground_distance <= MAX_COYOTE_GROUND_DISTANCE and jump_clicked == false:
		can_jump = true
		# creating the timer here will allow the coyote light feet to work with coyote edge
		# so that the player to jump when passing very close to the edge of a platform
		create_coyote_timer()
	return can_jump


## create a timer for the coyote time
func create_coyote_timer():
	coyote_timer = get_tree().create_timer(0.2, false, true)


## create a timer for the punch combo
func create_punch_timer():
	punch_timer = get_tree().create_timer(0.5, false, true)


## method to determine what happens when punch attack is pressed, grounded or not
## ALL the basic attacks are handled in this chain of if statements.
func handle_attack():
	if attack_pressed && starting:
		# The code for Sonic's strong attacks. If he's holding the opposite direction,
		# he executes an up strong attack which slightly bumps him backwards.
		'''
		if (facing_left && direction.x > 0) || (!facing_left && direction.x < 0):
			$AnimationPlayer.play("upStrong")
			launch_power = Vector3(0, 7, 0)
			if facing_left:
				velocity.x = 1
			else:
				velocity.x = -1
			attacking = true
		else:
			# If sonic holds any other direction, he executes a normal strong attack
			# that sends the opponent in the direction he specifies.
			$AnimationPlayer.play("strong")
			$sonicrigged2/AnimationPlayer.play("PGC 4")
			launch_power = Vector3(direction.x * 20, 5, direction.z * 20)
			attacking = true
		'''
		# If sonic holds any other direction, he executes a normal strong attack
		# that sends the opponent in the direction he specifies.
		$AnimationPlayer.play("strong")
		$sonicrigged2/AnimationPlayer.play("PGC 4")
		launch_power = Vector3(direction.x * 20, 5, direction.z * 20)
		attacking = true
	elif attack_pressed && dashing && can_airdash:
		# The code for Sonic's dash attack. His dash attack stalls him in the air for a short time.
		can_airdash = false
		attacking = true
		$AnimationPlayer.play("dashAttack")
		$sonicrigged2/AnimationPlayer.play("DASH ATK")
		launch_power = Vector3(velocity.x, 2, velocity.z)
		velocity.y = 3
	elif attack_pressed && !dashing && !is_on_floor() && can_air_attack:
		# The code for Sonic's midair attack. He can only use this once before landing, and it
		# sends the opponent downwards.
		attacking = true
		can_air_attack = false
		$AnimationPlayer.play("airAttack")
		$sonicrigged2/AnimationPlayer.play("AIR")
		
		var new_launch = $sonicrigged2.transform.basis.z.normalized() * 5
		new_launch.y = -2
		launch_power = new_launch
		
		'''
		if facing_left:
			launch_power = Vector3(-5, -2, 0)
		else:
			launch_power = Vector3(5, -2, 0)
		'''
		velocity.y = 4
	elif attack_pressed && is_on_floor() && !starting:
		# The code to initiate Sonic's 3-hit combo. The rest of the punches are in _on_animation_player_animation_finished().
		create_punch_timer()
		attacking = true
		$AnimationPlayer.play("punch1")
		$sonicrigged2/AnimationPlayer.play("PGC 1")
		launch_power = Vector3(0, 2, 0)
		current_punch = 1
	
	# The code for initiating Sonic's grounded and midair specials, which go to functions that check the selected skills.
	# no abilities on the hub areas
	if ground_skill != null and air_skill != null: #GlobalVariables.current_hub == null and GlobalVariables.current_area == null:
		if special_pressed && is_on_floor():
			attacking = true
			rpc("ground_special", randi(), direction)
		elif special_pressed && !is_on_floor() && can_air_attack:
			attacking = true
			can_air_attack = false
			rpc("air_special", randi(), direction)


## method to pace the healing of the character given an input
func handle_healing():
	if guard_pressed:
		healing_time += healing_pace
		if healing_time >= healing_threshold:
			heal()
			healing_time = 0
	else:
		healing_time = 0


## method to heal the character's life total
func heal(amount = 4):
	if life_total < MAX_LIFE_TOTAL:
		life_total += amount
	if life_total > MAX_LIFE_TOTAL:
		life_total = MAX_LIFE_TOTAL
	#hud.change_life(life_total)
	increase_special(1)


## method to fill the character's special amount
func increase_special(amount = 1):
	if special_amount < MAX_SPECIAL_AMOUNT:
		special_amount += amount
	if special_amount > MAX_SPECIAL_AMOUNT:
		special_amount = MAX_SPECIAL_AMOUNT
	#hud.change_special(special_amount)


## increase the total points gained in-game by one
func increase_points():
	points += 1
	#hud.change_points(points)
	GlobalVariables.bot_points = points
	if points >= GlobalVariables.points_to_win:
			GlobalVariables.win(self)


## gain one extra life
func one_up():
	GlobalVariables.extra_lives += 1
	#hud.update_extra_lives(GlobalVariables.extra_lives)


func collect_ring():
	# increase the amount of rings
	# rings collected in a stage should count towards
	# the rings total only after the battle is over
	Audio.play(Audio.ring, self)
	if GlobalVariables.current_stage != null:
		rings += 1
		heal(HEAL_POINTS_PER_RING)
	#else:
		#GlobalVariables.total_rings += 1
		#hud.update_rings(GlobalVariables.total_rings)
	
	# increase a permanent counter of how many rings were collected
	# to count towards extra lives gained
	# this prevents extra lives gained if the character didn't
	# lost all rings and is collecting scattered ones
	# ( 100 rings, scattered 1 ring, collect it = extra live )
	#GlobalVariables.ring_count_towards_extra_life += 1
	#if GlobalVariables.ring_count_towards_extra_life >= 100:
	#	one_up()
	#	GlobalVariables.ring_count_towards_extra_life = 0


## scatter rings in a circular pattern
func scatter_rings(amount = 1):
	#create_scattered_ring_timer()
	
	var number_of_rings_to_scatter
	
	# inside a stage scatter one ring per hit
	# and more rings if the hit was strong
	# if on a hub or area scatter all rings
	if GlobalVariables.current_stage == null:
		amount = rings
	
	number_of_rings_to_scatter = amount
	rings -= amount
	# clamp values
	number_of_rings_to_scatter = clamp(number_of_rings_to_scatter, 0, MAX_SCATTERED_RINGS_ALLOWED)
	rings = clamp(rings, 0, rings)
	# update hud
	#hud.update_rings(rings)
	
	# relative ring position
	var proxy_position = position + transform.basis.z
	var angle = 360.0
	if number_of_rings_to_scatter > 0:
		angle = 360.0 / number_of_rings_to_scatter
	# circular pattern
	for i in number_of_rings_to_scatter:
		proxy_position = proxy_position.rotated(Vector3.UP, deg_to_rad(angle * i))
		var new_ring_position = position + proxy_position.normalized()
		Instantiables.create_scattered_ring(new_ring_position, position)


## create a timer to count how long the scaterred rings will remain on the scene
#func create_scattered_ring_timer():
#	GlobalVariables.scattered_ring_timer = get_tree().create_timer(GlobalVariables.SCATTERED_RINGS_TIME, false, true)


## This function mostly handles what animations play with what booleans.
func handle_animation():
	# None of these animations play when Sonic is in his hurt or attacking state.
	if !attacking && !hurt:
		if is_on_floor():
			# Animations that play when Sonic is on the ground. If he's not starting movement, at least.
			if !starting && !dashing:
				if round(velocity.x) != 0 || round(velocity.z) != 0:
					$AnimationPlayer.play("walk")
					$sonicrigged2/AnimationPlayer.play("WALK")
				else:
					$AnimationPlayer.play("idle")
					$sonicrigged2/AnimationPlayer.play("IDLE")
		else:
			# Midair animations. These don't play when Sonic is dashing.
			if !dashing:
				if velocity.y > 0:
					$AnimationPlayer.play("jump")
					$sonicrigged2/AnimationPlayer.play("JUMP")
					falling = false
				elif velocity.y <= 0 && !falling:
					# Because falling should only play once, this is tied to the falling state.
					$AnimationPlayer.play("fall")
					$sonicrigged2/AnimationPlayer.play("FALL")
					falling = true
	'''
	elif $AnimationPlayer.current_animation == "punch1" || $AnimationPlayer.current_animation == "punch2" || $AnimationPlayer.current_animation == "punch3":
		# The 3-hit combo. If the player is holding the attack button by the time a punch finishes,
		# it moves on to the next punch.
		if Input.is_action_just_pressed("punch") and punch_timer != null and punch_timer.time_left > 0:
			# create a new timer to give time for a possible combo sequence
			create_punch_timer()
			
			match current_punch:
			1:
				$AnimationPlayer.play("punch2")
				launch_power = Vector3(0, 2, 0)
				current_punch = 2
			2:
				$AnimationPlayer.play("punch3")
				launch_power = Vector3(0, 2, 0)
				current_punch = 3
			3:
				# The final part of the combo does an immediate strong attack.
				$AnimationPlayer.play("strong")
				if facing_left:
					launch_power = Vector3(-20, 5, 0)
				else:
					launch_power = Vector3(20, 5, 0)
				current_punch = 0
	'''


## method to set the abilities and immunity of the character
## "SHOT", "POW" and SET" 
func set_abilities(new_abilities: Array):
	if new_abilities.size() == 3:
		ground_skill = new_abilities[0]
		air_skill = new_abilities[1]
		immunity = new_abilities[2]


func anim_end(anim_name):
	if anim_name == "WALK START":
		# End the "starting" state when the starting animation ends.
		starting = false
		walking = true
	elif anim_name == "DJMP 1":
		$sonicrigged2/AnimationPlayer.play("DJMP 3")
	elif anim_name == "DJMP 3":
		# Go back to falling state when airdash ends.
		dashing = false
		$AnimationPlayer.play("fall")
		$sonicrigged2/AnimationPlayer.play("FALL")
		falling = true
	elif anim_name == "PGC 4":
		# Sonic's normal strong attack has an extra effect where he has to recoil backwards,
		# so this code plays that recoil and adjusts his velocity accordingly.
		$AnimationPlayer.play("strongRecoil")
		$sonicrigged2/AnimationPlayer.play("PGC 5")
		velocity = -$sonicrigged2.basis.z.normalized() * 3
		velocity.y = 3
		can_air_attack = false
		can_airdash = false
	elif anim_name == "PGC 5" || anim_name == "upStrong":
		# Resets Sonic's attacking state when the up strong or the regular strong recoil ends.
		attacking = false
		starting = false
		can_air_attack = false
		can_airdash = false
	elif anim_name == "DASH ATK":
		# Resets Sonic's attacking state when his dash attack ends.
		attacking = false
		dashing = false
	elif anim_name == "AIR":
		# Resets Sonic's attacking state when his air attack ends. Also sets him to falling state.
		attacking = false
		jumping = false
		falling = true
		$AnimationPlayer.play("fall")
		$sonicrigged2/AnimationPlayer.play("FALL")
	elif anim_name == "PGC 1" || anim_name == "PGC 2" || anim_name == "PGC 3":
		# The 3-hit combo. If the player is holding the attack button by the time a punch finishes,
		# it moves on to the next punch.
		# NOTE: I tried making it so that the punches execute with pressing the button instead of holding,
		# but I couldn't get it working right so this will have to do for now.
		if attack_pressed:# and punch_timer != null and punch_timer.time_left > 0:
			# create a new timer to give time for a possible combo sequence
			create_punch_timer()
			if current_punch == 1:
				$AnimationPlayer.play("punch2")
				$sonicrigged2/AnimationPlayer.play("PGC 2")
				launch_power = Vector3(0, 2, 0)
				current_punch = 2
			elif current_punch == 2:
				$AnimationPlayer.play("punch3")
				$sonicrigged2/AnimationPlayer.play("PGC 3")
				launch_power = Vector3(0, 2, 0)
				current_punch = 3
			elif current_punch == 3:
				# The final part of the combo does an immediate strong attack.
				$AnimationPlayer.play("strong")
				$sonicrigged2/AnimationPlayer.play("PGC 4")
				
				var new_launch = $sonicrigged2.transform.basis.z.normalized() * 20
				new_launch.y = 5
				launch_power = new_launch
				
				'''
				if facing_left:
					launch_power = Vector3(-20, 5, 0)
				else:
					launch_power = Vector3(20, 5, 0)
				'''
				
				current_punch = 0
		else:
			# If the player doesn't continue the combo, Sonic's states reset as usual.
			attacking = false
			current_punch = 0
	elif anim_name == "HURT 1" || anim_name == "HURT 2":
		# Reset's Sonic's "hurt" state when the animation ends.
		hurt = false
		starting = false
		can_air_attack = false
	elif anim_name == "LAUNCHED":
		# For as long as Sonic is in the air, the animation loops. When he hits the ground, his state resets.
		if is_on_floor():
			hurt = false
			starting = false
		else:
			$AnimationPlayer.play("hurtStrong")
			$sonicrigged2/AnimationPlayer.play("LAUNCHED")
	elif anim_name in ["DJMP 2", "RING", "BOMB G (LAZY)", "BOMB A"]:
		# Handles Sonic's reset states for all of his special moves.
		attacking = false
		starting = false
		bouncing = false
		pow_move = false
		# If the animation is used for chasing the ring, the ring disappears and more states reset.
		if chasing_ring:
			chasing_ring = false
			thrown_ring = false
			if active_ring != null:
				active_ring.queue_free()
		if !is_on_floor():
			# Sets Sonic's falling state if he's in the air.
			jumping = false
			falling = true
			$AnimationPlayer.play("fall")
			$sonicrigged2/AnimationPlayer.play("FALL")


## Very simple signal state determining when the attack hitbox actually hits something.
func _on_hitbox_body_entered(body):
	#if !is_multiplayer_authority(): return
	if body.is_in_group("CanHurt") && body != self and attacking:
		# If the current attack is Sonic's "pow" move, the hitbox pays attention to immunities.
		if !pow_move || body.immunity != "pow":
			body.get_hurt.rpc_id(body.get_multiplayer_authority(), launch_power, self)


func defeated(who_owns_last_attack = null):
	if who_owns_last_attack != null:
		if who_owns_last_attack.has_method("increase_points"):
			who_owns_last_attack.increase_points()
	if GlobalVariables.game_ended == false:
		Instantiables.spawn_bot()
	queue_free()


## A function that handles Sonic getting hurt. Knockback is determined by the thing that initiates this
# function, which is why you don't see it here.
@rpc("any_peer","reliable","call_local")
func get_hurt(launch_speed, owner_of_the_attack):
	var damage = launch_speed.length()
	
	var sparks = Instantiables.SPARKS.instantiate()
	sparks.position = position + Vector3(0, 0.1, 0)
	get_parent().add_child(sparks)
	sparks.get_child(0).emitting = true
	
	# give a invunerability time
	if !hurt:
		# if had rings, scatter them
		#if rings > 0:
		# you can add the amount of rings to be scattered as a parameter
		
		# rings should provided all life points back
		
		if damage > MAX_SCATTERED_RINGS_ALLOWED * HEAL_POINTS_PER_RING:
			scatter_rings(MAX_SCATTERED_RINGS_ALLOWED)
			Audio.play(Audio.ring_spread, self)
		else:
			scatter_rings()
		#else:
			# if it was not in a stage where the character have life points,
			# defeat the character for having no rings when hurt
			#if GlobalVariables.current_stage != null:
			#	defeated()
		
	life_total -= damage
	#hud.change_life(life_total)
	
	if GlobalVariables.current_stage != null:
		if (life_total <= 0 and GlobalVariables.game_ended == false):
			defeated(owner_of_the_attack)
	
	# A bunch of states reset to make sure getting hurt cancels them out.
	hurt = true
	falling = false
	jumping = false
	bouncing = false
	
	velocity = launch_speed
	# If Sonic was chasing a ring, the ring is deleted.
	if chasing_ring:
		chasing_ring = false
		thrown_ring = false
		if active_ring != null:
			active_ring.queue_free()
	
	# Depending on where Sonic is and what his velocity is, the animation is different.
	if abs(velocity.x) > 8 || abs(velocity.z) > 8:
		$AnimationPlayer.play("hurtStrong")
		$sonicrigged2/AnimationPlayer.play("LAUNCHED")
	else:
		if launch_speed.y < 5:
			$AnimationPlayer.play("hurt")
			$sonicrigged2/AnimationPlayer.play("HURT 1")
		else:
			$AnimationPlayer.play("hurtAir")
			$sonicrigged2/AnimationPlayer.play("HURT 2")
	
	# More state resets. Idk why these are placed at the end.
	current_punch = 0
	dashing = false
	attacking = false


## The function for determining what happens with each selected grounded special move.
@rpc("any_peer", "reliable", "call_local")
func ground_special(id, _dir):
	if ground_skill == "SHOT":
		# Sonic's ground "shot" move sends a shockwave in the direction specified by the player.
		# Sonic is also launched back away from the direction of the projectile.
		# If no direction is held, the direction is determined by facing_left.
		can_air_attack = false
		$AnimationPlayer.play("shotGround")
		$sonicrigged2/AnimationPlayer.play("DJMP 2")
		#Instantiates a new shot projectile.
		var new_shot = Instantiables.create(Instantiables.objects.SHOT_PROJECTILE) #shot_projectile.instantiate()
		new_shot.user = self	# This makes sure Sonic can't hit himself with a projectile.
		new_shot.set_meta("author", name)
		new_shot.name = "wave" + str(id)
		var new_forward = $sonicrigged2.transform.basis.z.normalized()
		new_forward.y = 0
		new_shot.transform.basis.z = new_forward		
		new_shot.velocity = Vector3($sonicrigged2.basis.z.normalized().x * 3, 0, $sonicrigged2.basis.z.normalized().z * 3)
		velocity = -$sonicrigged2.basis.z.normalized() * 5
		velocity.y = 5
		
		new_shot.position = position
		# Creates the projectile.
		new_shot.set_multiplayer_authority(get_multiplayer_authority())
		# get_tree().current_scene.add_child(new_shot, true)
		get_tree().current_scene.add_child(new_shot, true)
	elif ground_skill == "POW":
		# Sonic's ground "pow" move first throws a ring. If the player inputs the move again,
		# Sonic will accelerate in the direction of the ring.
		# The ring is sent in a specified direciton, if there is no direction it is sent based on facing_left.
		if !thrown_ring:	# When no ring is on the field.
			$AnimationPlayer.play("powGround")
			$sonicrigged2/AnimationPlayer.play("RING")
			#Instantiates a new ring projectile
			var new_ring = Instantiables.create(Instantiables.objects.TOSS_RING) #ring.instantiate()
			new_ring.ring_owner = self
			active_ring = new_ring
			new_ring.name = "ring" + str(id)
			thrown_ring = true
			new_ring.position = position
			new_ring.velocity = Vector3($sonicrigged2.basis.z.normalized().x * 3, 5, $sonicrigged2.basis.z.normalized().z * 3)
			# Creates the ring projectile.
			get_tree().current_scene.add_child(new_ring, true)
		else:	# When a ring is on the field.
			launch_power = Vector3(0, 2, 0)
			pow_move = true
			$AnimationPlayer.play("powAir")
			$sonicrigged2/AnimationPlayer.play("DJMP 2")
			chasing_ring = true
	elif ground_skill == "SET":
		# Sonic's grounded "set" move sets down a mine where he's standing, which explodes over time
		# or on contact.
		$AnimationPlayer.play("setGround")
		$sonicrigged2/AnimationPlayer.play("BOMB G (LAZY)")
		if active_mine == null: # Only works if there's no mine already active.
			# Instantiates a new mine object.
			var new_mine = Instantiables.create(Instantiables.objects.SET_MINE) #set_mine.instantiate()
			new_mine.position = position
			new_mine.name = "mine" + str(id)
			new_mine.set_multiplayer_authority(get_multiplayer_authority())
			new_mine.user = self	# This makes sure Sonic can't hit himself with his own mine.
			active_mine = new_mine
			# Creates the mine
			get_tree().current_scene.add_child(new_mine, true)


## The function for determining what happens with each selected air special move.
@rpc("authority","call_local")
func air_special(id, _dir):
	if air_skill == "SHOT":
		# This works almost exactly the same as the grounded version,
		# Sonic sends a wave projectile that falls to the ground, which moves based on a specified
		# direction. He is also sent backwards away from the projectile.
		$AnimationPlayer.play("shotAir")
		$sonicrigged2/AnimationPlayer.play("DJMP 2")
		#Instantiates a new shot projectile.
		var new_shot = Instantiables.create(Instantiables.objects.SHOT_PROJECTILE) #shot_projectile.instantiate()
		new_shot.user = self	# This makes sure Sonic can't hit himself with a projectile.
		new_shot.name = "wave" + str(id)
		new_shot.set_multiplayer_authority(get_multiplayer_authority())
		new_shot.position = position
		var new_forward = $sonicrigged2.transform.basis.z.normalized()
		new_forward.y = 0
		new_shot.transform.basis.z = new_forward
		new_shot.velocity = Vector3($sonicrigged2.basis.z.normalized().x * 3, 0, $sonicrigged2.basis.z.normalized().z * 3)
		velocity = -$sonicrigged2.basis.z.normalized() * 5
		velocity.y = 2
		
		# Creates the projectile
		get_tree().current_scene.add_child(new_shot, true)
	elif air_skill == "POW":
		# Sonic's midair "pow" move causes him to curl into a ball and launch himself towards the ground
		# and foward slightly depending on held direction/facing_left.
		# If Sonic hits the ground, he bounces once.
		$AnimationPlayer.play("powAir")
		$sonicrigged2/AnimationPlayer.play("DJMP 2")
		pow_move = true
		bouncing = true	# Initiates the "bouncing" state for bouncing off the ground.
		launch_power = Vector3(0, 2, 0)
		
		velocity = $sonicrigged2.basis.z.normalized() * 10
		velocity.y = -5
	elif air_skill == "SET":
		# Works exactly like the grounded variant, Sonic places a mine that falls to the ground.
		# The mine explodes over time or on impact.
		# In the air, Sonic also gets a slight bit of air stall.
		$AnimationPlayer.play("setAir")
		$sonicrigged2/AnimationPlayer.play("BOMB A") # (LAZY)")
		can_air_attack = false
		if active_mine == null:	# Only works if there's no mine already active.
			velocity.y = 3
			# Instantiates a new mine object.
			var new_mine = Instantiables.create(Instantiables.objects.SET_MINE) #set_mine.instantiate()
			new_mine.name = "mine" + str(id)
			new_mine.position = position
			new_mine.user = self	# This makes sure Sonic can't hit himself with his own mine.
			active_mine = new_mine
			# Creates the mine object.
			get_tree().current_scene.add_child(new_mine, true)


## use Area3D to detect collectables like rings
func _on_ring_collider_area_entered(area):
	# store the parent of the Area3D the character collided
	if area.get_parent() != null:
		var collided_object = area.get_parent()
		# collect ring
		if collided_object.is_in_group("Ring"):
			collect_ring()
			if collided_object.has_method("delete_ring"):
				collided_object.delete_ring()
		if area.is_in_group("Hazard"):
			var hazard_impulse = Vector3(0, 6, 0)
			# make the character goes against it's forward (increasing damage too)
			hazard_impulse -= $sonicrigged2.transform.basis.z.normalized() * 15
			get_hurt(hazard_impulse, null)


func rotate_model():
	if direction:
		$sonicrigged2.rotation.y = Vector2(velocity.z, velocity.x).angle()
