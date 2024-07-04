extends Control

# this script should handle the starting menus (intro animation, main
# menu, onlie or offline setup, mode selection, character selection, 
# area selection)
# after an area is selected, the player would be directed to that 
# area's hub with the selected character
# in the hub the player selects which stage to play

@export_category("MENUS")
@export var intro_animation: VideoStreamPlayer
@export var main_menu: Control
@export var options_menu: Control
@export var online_or_offline_menu: Control
@export var online_menu: Control
@export var mode_selection_menu: Control
@export var character_selection_menu: Control
@export var area_selection_menu: Control

@export_category("SERVER CANVAS MENU")
@export var canvas_server_menu: Node3D

var current_selection: int = 0


func _ready():
	GlobalVariables.main_menu = self
	# hide menus and show intro animation
	start_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# intro animation
	if intro_animation.is_visible_in_tree() and Input.is_anything_pressed():
		intro_animation.hide()
		main_menu.show()


func start_menu():
	hide_menus()
	intro_animation.show()


## hide all menu screens so they won't overlap each other
func hide_menus():
	intro_animation.hide()
	main_menu.hide()
	options_menu.hide()
	online_or_offline_menu.hide()
	online_menu.hide()
	mode_selection_menu.hide()
	character_selection_menu.hide()
	area_selection_menu.hide()


## proceed with the normal screens sequence after online setup
func after_online_setup():
	hide_menus()
	mode_selection_menu.show()


## called after the area has been selected
func go_to_area_scene():
	# go to the area scene or hub of the selected area
	# the area is a placeholder for now
	# testing a game loop
	# the same hub will be selected every time for now
	GlobalVariables.playable_areas.find_key(GlobalVariables.area_selected)
	Instantiables.load_hub(Instantiables.hubs.HUBTEST)
	# create the character in the Main scene
	Instantiables.add_player(get_parent())
	# hide menus
	hide_menus()


# sequence of menu buttons
# there might be a better way to do this

# main menu
func _on_start_button_pressed():
	hide_menus()
	online_or_offline_menu.show()


func _on_options_button_pressed():
	hide_menus()
	options_menu.show()


func _on_quit_button_pressed():
	# this quit won't work on iOS, need home button press instead
	get_tree().quit()


func _on_options_back_button_pressed():
	hide_menus()
	main_menu.show()


func _on_online_button_pressed():
	GlobalVariables.play_online = true
	hide_menus()
	online_menu.show()


func _on_offline_button_pressed():
	GlobalVariables.play_online = false
	hide_menus()
	canvas_server_menu.add_player()
	mode_selection_menu.show()


func _on_story_mode_button_pressed():
	GlobalVariables.play_mode = GlobalVariables.modes.story
	hide_menus()
	character_selection_menu.show()


func _on_battle_mode_button_pressed():
	GlobalVariables.play_mode = GlobalVariables.modes.battle
	hide_menus()
	character_selection_menu.show()


func _on_challenge_mode_button_pressed():
	GlobalVariables.play_mode = GlobalVariables.modes.challenge
	hide_menus()
	character_selection_menu.show()


func _on_sonic_character_button_pressed():
	GlobalVariables.character_selected = GlobalVariables.playable_characters.sonic
	hide_menus()
	area_selection_menu.show()


func _on_area_1_button_pressed():
	GlobalVariables.area_selected = GlobalVariables.playable_areas.area1
	hide_menus()
	go_to_area_scene()


# most of the back buttons from the menus trigger this method
# except for the options menu, which can be changed to call this as well
func _on_back_button_pressed():
	if online_or_offline_menu.is_visible_in_tree():
		hide_menus()
		main_menu.show()
	if online_menu.is_visible_in_tree():
		hide_menus()
		online_or_offline_menu.show()
	if mode_selection_menu.is_visible_in_tree():
		hide_menus()
		online_or_offline_menu.show()
	if character_selection_menu.is_visible_in_tree():
		hide_menus()
		mode_selection_menu.show()
	if area_selection_menu.is_visible_in_tree():
		hide_menus()
		character_selection_menu.show()
