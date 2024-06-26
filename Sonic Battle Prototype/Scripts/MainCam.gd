extends Camera3D

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = lerp(position, Vector3(player.position.x, player.position.y + 10, player.position.z + 20), 0.05)
	look_at(player.position)
