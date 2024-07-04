extends Node

# this script was autoloaded so you can put all preloaded scenes in one place
# so you can change which scene is instantiated in multiple places from here
# all script that requires a scene to be instantiate should
# use this Instantiables script.

# The prefab for spawning Sonic's "shot" projectile.
const SHOT_PROJECTILE = preload("res://Scenes/SonicWave.tscn")

# The ring prefab that Sonic will throw when he uses his "pow" move on the ground.
const RING = preload("res://Scenes/ThrowRing.tscn")

# The mine prefab for Sonic's "set" special moves.
const SET_MINE = preload("res://Scenes/SonicMine.tscn")

# ability selection menu
const ABILITY_SELECT = preload("res://Scenes/ability_select.tscn")

# sonic character
const SONIC = preload("res://Scenes/Sonic.tscn")

# pointer to spawn the character at target spot
const POINTER_SPAWNER = preload("res://Scenes/pointer_spawner.tscn")

# to match-case block
# should get a variable with the name of a string instead
enum objects {SHOT_PROJECTILE, RING, SET_MINE, ABILITYSELECT, POINTERSPAWNER}


# create a Sonic character
func add_player(parent_node, spawn_position = Vector3.ZERO):
	GlobalVariables.defeated = false
	var player = SONIC.instantiate()
	player.name = str(GlobalVariables.character_id)
	# add the selected abilities to the character
	player.set_abilities(GlobalVariables.selected_abilities)
	player.position = spawn_position + Vector3(0, 0.2, 0)
	parent_node.add_child(player, true)


## create a preloaded scene
func create(object_to_create, place_to_add_as_child = null):
	var new_object
	
	# there should be a way to get a variable with the name equal to a string
	# using match-case for now
	match object_to_create:
		objects.SHOT_PROJECTILE:
			new_object = SHOT_PROJECTILE.instantiate()
		objects.RING:
			new_object = RING.instantiate()
		objects.SET_MINE:
			new_object = SET_MINE.instantiate()
		objects.ABILITYSELECT:
			new_object = ABILITY_SELECT.instantiate()
		objects.POINTERSPAWNER:
			new_object = POINTER_SPAWNER.instantiate()
	
	if place_to_add_as_child == null:
		return new_object
	
	
