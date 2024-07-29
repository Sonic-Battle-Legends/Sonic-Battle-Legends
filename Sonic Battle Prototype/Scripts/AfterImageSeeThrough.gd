extends Node3D

# effect to allow the player to see the character through objects
# get current animation and seek point in the animation timeline
# play that animation at that point

@export var see_through_material: StandardMaterial3D
@export var mesh_node: MeshInstance3D
var new_material

# node that animates the mesh
@export var animation_node: AnimationPlayer
var current_animation_name = ""
var current_animation_time = 0.0


func _ready():
	# set a duplicated material so that it won't chance all instances together
	new_material = see_through_material #.duplicate()
	mesh_node.set_surface_override_material(0, new_material)
	#mesh_node.set_surface_override_material(1, new_material)


	# update the pose
func update_pose():
	if animation_node.has_animation(current_animation_name):
		# play that animation, set speed to zero
		animation_node.play(current_animation_name)#, -1, 0.0) #2)
		# seek the animation timeline to the correct one
		animation_node.seek(current_animation_time, true)
	else:
		if current_animation_name != "":
			push_warning("see through after image doesn't have animation named ", current_animation_name)
