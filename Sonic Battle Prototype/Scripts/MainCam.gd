extends Camera3D

# This code handles the main camera that follows the player.
# In online multiplayer, this will eventually only focus on the active client player.
# Original code by The8BitLeaf.

var player	# The player target.

# Called when the node enters the scene tree for the first time.
func _ready():
	# At the start of the scene, the camera locks on to the player.
	# When we have multiple characters and respawning, this will likely change to some capacity.
	player = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# The camera will always slowly accelerate to the player'slocation and look at them.
	position = lerp(position, Vector3(player.position.x, player.position.y + 10, player.position.z + 20), 0.05)
	look_at(player.position)
