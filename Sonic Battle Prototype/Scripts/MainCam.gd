extends Camera3D

# This code handles the main camera that follows the player.
# In online multiplayer, this will eventually only focus on the active client player.
# Original code by The8BitLeaf.

# code modified later on


var player	# The player target.
var spin = 1

const NORMAL_SPEED = 0.025
const FAST_SPEED = 0.08
var current_speed = NORMAL_SPEED

func _ready():
	# The camera locks on to the player.
	# When we have multiple characters and respawning, this will likely change to some capacity.
	player = get_parent()
	# if it's in perspective mode, set the position to where it should be
	if projection == 0:
		position = Vector3(0, 10, 10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	# speed up the pace when changing camera direction
	var target_z_value = player.position.z + (15 * spin) - player.velocity.z
	var difference = abs(abs(target_z_value) - abs(global_position.z))
	if difference > 1:
		current_speed = FAST_SPEED
	else:
		current_speed = NORMAL_SPEED
	
	# The camera will always slowly accelerate to the player'slocation and look at them.
	global_position = lerp(global_position, Vector3(player.position.x - player.velocity.x, player.position.y + 5 + difference - player.velocity.y, player.position.z + (15 * spin) - player.velocity.z), current_speed)
	look_at(player.position)

	# make the camera farther away on the areas
	if GlobalVariables.current_area != null:
		size = 5
	else:
		size = 3


func rotate_camera():
	# spin control which side the camera will lerp to along the Z axis
	spin = -spin
	# store character position
	var character_position = get_parent().position
	# store distance between character and camera
	#var character_distance = (character_position - position).length()
	# store direction from camera to character
	var direction = (character_position - position).normalized()
	# invert the Y axis of the direction so it won't cross the ground
	direction.y = -direction.y
	# set the new camera position to behind the character
	#global_position = direction * character_distance
