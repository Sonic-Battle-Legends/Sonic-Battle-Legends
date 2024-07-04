extends Node


# to store the main menu node
var main_menu

# store rather if the player selected to play online or offline
var play_online: bool = false

# server/client related  variables
var server_node
var character_id

enum modes {battle, story, challenge}
# which mode was selected (battle mode, story mode,...)
var play_mode = modes.battle

# enumerator with all playable characters
# maybe make another list for unlockable characters
enum playable_characters {sonic}
var character_selected = playable_characters.sonic
# to store the character node that was created in-game
var current_character

# enumerator for all world areas
# which contain some number of hubs each
# maybe make another list for unlockable characters
enum playable_areas {area1}
var area_selected = playable_areas.area1

# current hub created in-game
var current_hub

# current stage created in-game
var current_stage

var selected_abilities: Array
var defeated: bool = true


func go_to_stage_from_hub(new_stage: PackedScene):
	# remove the hub and the character from the main scene
	if current_hub != null:
		current_hub.queue_free()
	main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	current_character.queue_free()
	# create the new stage
	current_stage = new_stage.instantiate()
	main_menu.get_parent().add_child(current_stage)
	#get_tree().call_deferred("change_scene_to_file", new_stage)
	# create the ability selection that will later create the
	# point spawner to spawn the character on the stage
	var ability_selection_menu = Instantiables.create(Instantiables.objects.ABILITYSELECT)
	main_menu.get_parent().add_child(ability_selection_menu, true)


func go_to_main_menu_from_battle():
	# remove the hub and the character from the main scene
	if current_stage != null:
		current_stage.queue_free()
	if current_hub != null:
		current_hub.queue_free()
	main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	current_character.queue_free()
	main_menu.start_menu()
