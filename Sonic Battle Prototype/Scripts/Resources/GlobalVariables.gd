extends Node

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

# enumerator for all world areas
# which contain some number of hubs each
# maybe make another list for unlockable characters
enum playable_areas {area1}
var area_selected = playable_areas.area1

var selected_abilities: Array
var defeated: bool = true
