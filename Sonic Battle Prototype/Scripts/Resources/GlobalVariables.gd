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


## the character that triggers this method is the winner of the battle
func win():
	game_ended = true
	var score_menu = Instantiables.create(Instantiables.objects.SCORESCREEN)
	score_menu.winner = character_id
	main_menu.get_parent().add_child(score_menu, true)
