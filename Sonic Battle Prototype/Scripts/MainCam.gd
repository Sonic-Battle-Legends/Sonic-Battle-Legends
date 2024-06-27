extends Camera3D

# This code handles the main camera that follows the player.
# In online multiplayer, this will eventually only focus on the active client player.
# Original code by The8BitLeaf.

var player	# The player target.

func _ready():
	# The camera locks on to the player.
	# When we have multiple characters and respawning, this will likely change to some capacity.
	player = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# The camera will always slowly accelerate to the player'slocation and look at them.
	global_position = lerp(global_position, Vector3(player.position.x - player.velocity.x, player.position.y + 10 - player.velocity.y, player.position.z + 20 - player.velocity.z), 0.025)
	look_at(player.position)
