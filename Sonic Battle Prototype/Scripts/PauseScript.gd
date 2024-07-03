extends Node

@export var pause_menu: Control


func _process(_delta):
	# pause / resume the game when pressing "pause" button
	if Input.is_action_just_pressed("pause"):
		# if game is paused, resume
		if get_tree().is_paused():
			get_tree().paused = false
		else:
		# if game is not paused, pause
			get_tree().paused = true
	
	if get_tree().is_paused():
		# show the mouse the confine it within the screen while paused
		pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		# hide the mouse and hold it in place while not paused
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
