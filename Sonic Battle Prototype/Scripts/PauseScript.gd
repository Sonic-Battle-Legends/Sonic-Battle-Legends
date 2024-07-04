extends Node

@export var pause_menu: Control
@export var resume_button: Button
@export var restart_button: Button
@export var main_menu_button: Button


func _ready():
	if GlobalVariables.play_online:
		restart_button.hide()
	else:
		restart_button.show()

func _process(_delta):	
	# pause / resume the game when pressing "pause" button
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	
	if get_tree().is_paused():
		# show the mouse the confine it within the screen while paused
		pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		# hide the mouse and hold it in place while not paused
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func toggle_pause():
	# if game is paused, resume
	if get_tree().is_paused():
		get_tree().paused = false
	else:
	# if game is not paused, pause
		get_tree().paused = true


func restart():
	if GlobalVariables.play_online == false:
		# reset the connection so it can be stablished again
		# there was an error when going offline and restating the hub and trying to go offline again 
		# the error was:
		'''
		E 0:00:07:0278   ServerJoin2.gd:26 @ add_player(): Couldn't create an ENet host.
	  	<C++ Error>    Parameter "host" is null.
  		<C++ Source>   modules/enet/enet_connection.cpp:318 @ _create()
  		<Stack Trace>  ServerJoin2.gd:26 @ add_player()
						Menus.gd:113 @ _on_offline_button_pressed()

		'''
		#if GlobalVariables.current_hub != null:
		#	GlobalVariables.main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
		
		# restart current match
		get_tree().paused = false
		get_tree().reload_current_scene()


func go_to_main_menu():
	get_tree().paused = false
	GlobalVariables.go_to_main_menu_from_battle()
	#get_tree().change_scene_to_file("res://Scenes/menus.tscn")


func _on_resume_button_pressed():
	toggle_pause()


func _on_restart_button_pressed():
	restart()


func _on_main_menu_button_pressed():
	go_to_main_menu()
