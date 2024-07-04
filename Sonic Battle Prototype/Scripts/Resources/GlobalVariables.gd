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
var character_points: int = 0
var defeated: bool = true

# win condition
var points_to_win: int = 8
# store if someone won the game already
var game_ended: bool = false


func go_to_stage_from_hub(new_stage: PackedScene):
	game_ended = false
	# remove the hub and the character from the main scene
	if current_hub != null:
		current_hub.queue_free()
	main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	respawn()
	
	# create the new stage
	current_stage = new_stage.instantiate()
	main_menu.get_parent().add_child(current_stage)


func go_to_main_menu_from_battle():
	# remove the hub and the character from the main scene
	if current_stage != null:
		current_stage.queue_free()
	if current_hub != null:
		current_hub.queue_free()
	main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	current_character.queue_free()
	main_menu.start_menu()


func respawn():
	current_character.queue_free()
	# create the ability selection that will later create the
	# point spawner to spawn the character on the stage
	var ability_selection_menu = Instantiables.create(Instantiables.objects.ABILITYSELECT)
	main_menu.get_parent().add_child(ability_selection_menu, true)


# the character that triggers this method is the winner
func win():
	game_ended = true
	var score_menu = Instantiables.create(Instantiables.objects.SCORESCREEN)
	score_menu.winner = character_id
	main_menu.get_parent().add_child(score_menu, true)
