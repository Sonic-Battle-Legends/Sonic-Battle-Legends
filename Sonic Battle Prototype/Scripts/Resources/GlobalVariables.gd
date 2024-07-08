extends Node

# right now everyone and everything should have a gravity of 20.
var gravity: float = 20.0

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

# bellow there are many "current" and "selected" variables
# the "current" is used to track and later delete the instantiated scene
# the "selected" is used to instantiate a new one
# enumerator with all playable characters
# maybe make another list for unlockable characters
enum playable_characters {sonic, shadow}
var character_selected = playable_characters.sonic
# to store the character node that was instantiated in-game
var current_character

# enumerator for all world areas
# which contain some number of hubs each
# maybe make another list for unlockable characters
enum playable_areas {world1}
# store the area selected in the main menu
var area_selected # = playable_areas.area1
# store the instantiated area
var current_area

enum playable_hubs {hub1}
# store the hub selected in the main menu
var hub_selected
# current hub instantiated in-game
var current_hub

# stage selected (with PackedScene type) by hitting a hub marker in a hub area
var stage_selected
# current stage instantiated in-game
var current_stage

# timer to select ability and place character on stage
var select_ability_timer: SceneTreeTimer

# timer to count the time scattered rings last
var scattered_ring_timer: SceneTreeTimer
# time to set the scattered rings timer
const SCATTERED_RINGS_TIME = 4.0

var ring_count_towards_extra_life: int = 0

var selected_abilities: Array
var character_points: int = 0
var defeated: bool = true

# variables for the hud on areas and hubs
var total_rings: int = 0
var extra_lives: int = 2

# win condition
var points_to_win: int = 1
# store if someone won the game already
var game_ended: bool = false


## the character that triggers this method is the winner of the battle
func win():
	game_ended = true
	var score_menu = Instantiables.create(Instantiables.objects.SCORESCREEN)
	score_menu.winner = character_id
	main_menu.get_parent().add_child(score_menu, true)
