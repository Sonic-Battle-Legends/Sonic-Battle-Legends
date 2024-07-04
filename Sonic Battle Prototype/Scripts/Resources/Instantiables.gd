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

# final score screen
const SCORE_SCREEN = preload("res://Scenes/score_screen.tscn")

# sonic character
const SONIC = preload("res://Scenes/Sonic.tscn")

# pointer to spawn the character at target spot
const POINTER_SPAWNER = preload("res://Scenes/pointer_spawner.tscn")

# the hub area with the hub markers that lead to stages
const HUB_TEST = preload("res://Scenes/Hubs/hub_test.tscn")

# to match-case block
# should get a variable with the name of a string instead
enum objects {SHOT_PROJECTILE, RING, SET_MINE, ABILITYSELECT, POINTERSPAWNER, SCORESCREEN}

enum hubs {HUBTEST}


# create a Sonic character
func add_player(parent_node, spawn_position = Vector3.ZERO):
	GlobalVariables.defeated = false
	var player = SONIC.instantiate()
	player.name = str(GlobalVariables.character_id)
	# add the selected abilities to the character
	player.set_abilities(GlobalVariables.selected_abilities)
	player.position = spawn_position + Vector3(0, 0.2, 0)
	parent_node.add_child(player, true)


## load a stage in the Main hierarchy
func load_stage(new_stage):
	# store the current stage on global variables
	GlobalVariables.current_stage = new_stage.instantiate()
	# create the stage in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_stage)


## load a hub in the Main hierarchy
func load_hub(hub_to_create):
	var new_hub
	match hub_to_create:
		hubs.HUBTEST:
			new_hub = HUB_TEST.instantiate()
	
	# store the current hub on global variables
	GlobalVariables.current_hub = new_hub
	# create the hub in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_hub)


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
		objects.SCORESCREEN:
			new_object = SCORE_SCREEN.instantiate()
			
	if place_to_add_as_child == null:
		return new_object


## respawn the character
func respawn():
	GlobalVariables.current_character.queue_free()
	# create the ability selection that will later create the
	# point spawner to spawn the character on the stage
	var ability_selection_menu = Instantiables.create(Instantiables.objects.ABILITYSELECT)
	GlobalVariables.main_menu.get_parent().add_child(ability_selection_menu, true)


## bridge from the hub area's hub marker to the selected stage
func go_to_stage_from_hub(new_stage: PackedScene):
	GlobalVariables.game_ended = false
	# remove the hub and the character from the main scene
	if GlobalVariables.current_hub != null:
		GlobalVariables.current_hub.queue_free()
	GlobalVariables.main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	respawn()
	
	# create the new stage
	Instantiables.load_stage(new_stage)


## bridge from the battle's pause menu back to the main menu
func go_to_main_menu_from_battle():
	# remove the hub and the character from the main scene
	if GlobalVariables.current_stage != null:
		GlobalVariables.current_stage.queue_free()
	if GlobalVariables.current_hub != null:
		GlobalVariables.current_hub.queue_free()
	GlobalVariables.main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	GlobalVariables.current_character.queue_free()
	GlobalVariables.main_menu.start_menu()
