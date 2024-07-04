extends Control

# winner ID
var winner
var done: bool = false

@export var win_text_node: RichTextLabel


func _process(_delta):
	if winner != null and done == false:
		done = true
		win_text_node.text = "Player " + str(winner) + " Won!"

'''
func _on_play_again_button_pressed():
	# restart current match
	get_tree().paused = false
	GlobalVariables.game_ended = false
	GlobalVariables.character_points = 0
	# this reloads the entire Main scene not only the stage
	get_tree().reload_current_scene()
'''


func _on_main_menu_button_pressed():
	GlobalVariables.go_to_main_menu_from_battle()
	get_tree().paused = false
	GlobalVariables.game_ended = false
	GlobalVariables.character_points = 0
	queue_free()
