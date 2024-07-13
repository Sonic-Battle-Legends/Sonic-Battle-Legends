extends Node

# this script was autoloaded so you can put all preloaded scenes in one place
# so you can change which scene is instantiated in multiple places from here
# all script that requires a scene to be instantiate should
# use this Instantiables script.

# The prefab for spawning Sonic's "shot" projectile.
const SHOT_PROJECTILE = preload("res://Scenes/SonicWave.tscn")

# The ring prefab that Sonic will throw when he uses his "pow" move on the ground.
const TOSS_RING = preload("res://Scenes/ThrowRing.tscn")

# The mine prefab for Sonic's "set" special moves.
const SET_MINE = preload("res://Scenes/SonicMine.tscn")

# ability selection menu
const ABILITY_SELECT = preload("res://Scenes/ability_select.tscn")

# final score screen
const SCORE_SCREEN = preload("res://Scenes/score_screen.tscn")

# pointer to spawn the character at target spot
const POINTER_SPAWNER = preload("res://Scenes/pointer_spawner.tscn")

# ring that bounces
const SCATTERED_RING = preload("res://Scenes/collectables/scattered_ring.tscn")

# sonic character
const SONIC = preload("res://Scenes/Sonic.tscn")

# shadow character
const SHADOW = preload("res://Scenes/Shadow.tscn")

var ENEMY_BOT = load("res://Scenes/enemies/Sonic_BOT.tscn")

var first_world = load("res://Scenes/Areas/world1.tscn")

# the hub area with the hub markers that lead to stages
var city_hub = load("res://Scenes/Hubs/city_hub.tscn")
var ruins1 = load("res://Scenes/Hubs/ruins_1.tscn")
var puzzle_map = load("res://Scenes/isometric_map_1.tscn")
var puzzle_map_2 = load("res://Scenes/isometric_map_2.tscn")
var puzzle_map_3 = load("res://Scenes/isometric_map_3.tscn")

# to match-case block
# should get a variable with the name of a string instead
# attacks (shots and sets)
enum objects {SHOT_PROJECTILE, TOSS_RING, SET_MINE, ABILITYSELECT, POINTERSPAWNER, SCORESCREEN}

# pointer spawner is not a screen though
#enum screens {ABILITYSELECT, POINTERSPAWNER, SCORESCREEN}

## the possible worlds to select
#enum worlds {first_world} #, second_world}

## the possible hubs to select
#enum hubs {city_hub, puzzle_map, puzzle_map_2, puzzle_map_3}

## possible worlds and hubs to select with place markers
enum worlds_and_hubs {first_world, city_hub, ruins1, puzzle_map, puzzle_map_2, puzzle_map_3}


## create a Sonic character
# called from pointer_spawner
func add_player(parent_node, spawn_position = Vector3.ZERO):
	GlobalVariables.defeated = false
	
	var player
	if GlobalVariables.character_selected == GlobalVariables.playable_characters.sonic:
		player = SONIC.instantiate()
	elif GlobalVariables.character_selected == GlobalVariables.playable_characters.shadow:
		player = SHADOW.instantiate()
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
		objects.TOSS_RING:
			new_object = TOSS_RING.instantiate()
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


func create_scattered_ring(ring_position, scatter_origin_position):
	var new_scattered_ring = SCATTERED_RING.instantiate()
	new_scattered_ring.position = scatter_origin_position
	new_scattered_ring.velocity = (ring_position - scatter_origin_position).normalized() * 2
	GlobalVariables.main_menu.get_parent().add_child(new_scattered_ring)


## got to area
# areas that contains hubs
func go_to_area(selected_area: PackedScene):
	delete_places()
	# make the selected hub also null to prevent issues with the exit button on pause menu
	GlobalVariables.hub_selected = null
	
	load_area(selected_area)
	
	# allow a new character to be spawned
	if GlobalVariables.current_character != null:
		GlobalVariables.current_character.queue_free()
		# the reference is still there so nullify it
		GlobalVariables.current_character = null
	# create the character in the Main scene
	add_player(GlobalVariables.main_menu.get_parent())


func load_area(new_area):
	# store the current area on global variables
	GlobalVariables.current_area = new_area.instantiate()
	# create the area in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_area) # GlobalVariables.area_selected) 


## go to a hub
# hubs that contains stages
# called from menu after an area is selected
# it should go to an area first them the player selects a hub
func go_to_hub(selected_hub: PackedScene):
	delete_places()
	
	#var hub = match_place(selected_hub)
	load_hub(selected_hub)
	
	# allow a new character to be spawned
	#GlobalVariables.main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	if GlobalVariables.current_character != null:
		GlobalVariables.current_character.queue_free()
		# the reference is still there so nullify it
		GlobalVariables.current_character = null
	# create the character in the Main scene
	add_player(GlobalVariables.main_menu.get_parent())


## load a hub in the Main hierarchy
func load_hub(hub_to_create):
	# store the current hub on global variables
	GlobalVariables.current_hub = hub_to_create.instantiate()
	# create the hub in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_hub)


## bridge from the hub area's hub marker to the selected stage
func go_to_stage(new_stage: PackedScene):
	# unpause if restarted
	get_tree().paused = false
	
	# reset win condition variables
	GlobalVariables.game_ended = false
	GlobalVariables.character_points = 0
	
	delete_places()
	
	# allow a new character to be spawned
	ServerJoin.remove_player(multiplayer.multiplayer_peer)
	# spawn a character with ability selector
	respawn()
	
	# create the new stage
	load_stage(new_stage)
	
	if GlobalVariables.play_online == false:
		spawn_bot()
	else:
		spawn_bot()
		spawn_bot()
		spawn_bot()


## load a stage in the Main hierarchy
func load_stage(new_stage):
	# store the current stage on global variables
	GlobalVariables.current_stage = new_stage.instantiate()
	# create the stage in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_stage)


func spawn_bot():
	# create a cpu character to fight
	var new_enemy = ENEMY_BOT.instantiate()
	var enemy_abilities = ["SET", "POW", "SHOT"]
	new_enemy.set_abilities(enemy_abilities)
	new_enemy.position = Vector3(0, 0.1, 0)
	GlobalVariables.main_menu.get_parent().add_child(new_enemy)


## match the selected enumerator with the place the player wants to go
## get an enumerator as parameter and return a packedscene
func match_place(place_to_match: int):
	var place_to_go
	
	match place_to_match:
		worlds_and_hubs.first_world:
			place_to_go = first_world
		worlds_and_hubs.city_hub:
			place_to_go = city_hub
		worlds_and_hubs.ruins1:
			place_to_go = ruins1
		worlds_and_hubs.puzzle_map:
			place_to_go = puzzle_map
		worlds_and_hubs.puzzle_map_2:
			place_to_go = puzzle_map_2
		worlds_and_hubs.puzzle_map_3:
			place_to_go = puzzle_map_3
	return place_to_go


## respawn the character
## ability selection will be spawn first, then pointer selector, then the character
func respawn():
	if not is_multiplayer_authority(): return
	
	if GlobalVariables.current_character != null:
		GlobalVariables.current_character.queue_free()
		GlobalVariables.current_character = null
	# create the ability selection that will later create the
	# point spawner to spawn the character on the stage
	if GlobalVariables.current_ability_seletor == null:
		#var ability_selection_menu = create(objects.ABILITYSELECT)
		GlobalVariables.current_ability_seletor = create(objects.ABILITYSELECT) #ability_selection_menu
		GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_ability_seletor, true)


func delete_places():
	# delete area
	if GlobalVariables.current_area != null:
		GlobalVariables.current_area.queue_free()
		GlobalVariables.current_area = null
	# delete hub if it's restarting the scene
	if GlobalVariables.current_hub != null:
		GlobalVariables.current_hub.queue_free()
		GlobalVariables.current_hub = null
	# delete stage if it's restarting the scene from score screen
	if GlobalVariables.current_stage != null:
		GlobalVariables.current_stage.queue_free()
		GlobalVariables.current_stage = null
	
	# destroy bots
	get_tree().call_group("Bot", "queue_free")
	# destroy remaining rings
	get_tree().call_group("Ring", "queue_free")


func reload_current_scene():
	# destroy bots
	get_tree().call_group("Bot", "queue_free")
	#GlobalVariables.enemy_bots.clear()
	# reload scene
	get_tree().reload_current_scene()


## go to previous ambient
## exit from stage to hub
## exit from hub to area
## exit from area to main menu
func exit_current_ambient():
	if GlobalVariables.hub_selected != null and GlobalVariables.current_hub == null:
		# if on stage, return to current hub
		go_to_hub(GlobalVariables.hub_selected)
	elif GlobalVariables.area_selected != null and GlobalVariables.current_area == null:
		# if on hub, return to current area
		go_to_area(GlobalVariables.area_selected)
	else:
		# if on area, return to main menu
		#get_tree().reload_current_scene()
		reload_current_scene()
