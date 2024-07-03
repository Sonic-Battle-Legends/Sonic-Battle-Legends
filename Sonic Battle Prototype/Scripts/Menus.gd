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
@export var mode_selection_menu: Control
@export var character_selection_menu: Control
@export var area_selection_menu: Control

var current_selection: int = 0


func _ready():
	# hide menus and show intro animation
	hide_menus()
	intro_animation.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# intro animation
	if intro_animation.is_visible_in_tree() and Input.is_anything_pressed():
		intro_animation.hide()
		main_menu.show()
	
	'''
	# main menu
	if main_menu.is_visible_in_tree() and current_selection == 0 and Input.is_action_just_pressed("punch"):
		main_menu.hide()
		online_or_offline_menu.show()
	
	# options menu
	if main_menu.is_visible_in_tree() and current_selection == 1 and Input.is_action_just_pressed("punch"):
		main_menu.hide()
		options_menu.show()
	
	# quit
	if main_menu.is_visible_in_tree() and current_selection == 2 and Input.is_action_just_pressed("punch"):
		hide_menus()
		# quit game
		# this quit won't work on iOS, need home button press instead
		get_tree().quit()
	
	# online or offline menu
	if online_or_offline_menu.is_visible_in_tree() and Input.is_action_just_pressed("punch"):
		online_or_offline_menu.hide()
		mode_selection_menu.show()
	
	# mode selection menu
	if mode_selection_menu.is_visible_in_tree() and Input.is_action_just_pressed("punch"):
		mode_selection_menu.hide()
		character_selection_menu.show()
	
	# character selection menu
	if character_selection_menu.is_visible_in_tree() and Input.is_action_just_pressed("punch"):
		character_selection_menu.hide()
		area_selection_menu.show()
	
	# area selection menu
	if area_selection_menu.is_visible_in_tree() and Input.is_action_just_pressed("punch"):
		area_selection_menu.hide()
		# go to the hub of the selected area with the selected character
	'''


func hide_menus():
	intro_animation.hide()
	main_menu.hide()
	options_menu.hide()
	online_or_offline_menu.hide()
	mode_selection_menu.hide()
	character_selection_menu.hide()
	area_selection_menu.hide()


func go_to_area_scene():
	# go to the area scene or hub of the selected area
	var selected_area = GlobalVariables.playable_areas.find_key(GlobalVariables.area_selected)
	var path = "res://Scenes/Areas/" + selected_area
	push_warning("path: ", path)
	#get_tree().change_scene_to_file(path)


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
	mode_selection_menu.show()


func _on_offline_button_pressed():
	GlobalVariables.play_online = false
	hide_menus()
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
