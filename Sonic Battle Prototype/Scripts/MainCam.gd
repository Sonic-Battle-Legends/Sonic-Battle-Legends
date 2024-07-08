extends Camera3D

# This code handles the main camera that follows the player.
# In online multiplayer, this will eventually only focus on the active client player.
# Original code by The8BitLeaf.

# code modified later on


var player	# The player target.
var spin = 1

func _ready():
	# The camera locks on to the player.
	# When we have multiple characters and respawning, this will likely change to some capacity.
	player = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	# The camera will always slowly accelerate to the player'slocation and look at them.
	global_position = lerp(global_position, Vector3(player.position.x - player.velocity.x, player.position.y + 10 - player.velocity.y, player.position.z + (20 * spin) - player.velocity.z), 0.025)
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
	var character_distance = (character_position - position).length()
	# store direction from camera to character
	var direction = (character_position - position).normalized()
	# invert the Y axis of the direction so it won't cross the ground
	direction.y = -direction.y
	# set the new camera position to behind the character
	global_position = direction * character_distance
