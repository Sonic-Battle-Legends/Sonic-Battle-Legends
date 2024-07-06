extends Control

# winner ID
var winner
var done: bool = false
var button_pressed: bool = false

@export var win_text_node: RichTextLabel


func _process(_delta):
	if winner != null and done == false:
		done = true
		win_text_node.text = "Player " + str(winner) + " Won!"
	
	if button_pressed:
		queue_free()


## play again with the same settings
func _on_play_again_button_pressed():
	# delete this screen
	button_pressed = true
	
	# restart current match
	Instantiables.go_to_stage(GlobalVariables.stage_selected) #restart_current_stage()	


func _on_back_to_hub_button_pressed():	
	# delete this screen
	button_pressed = true
	
	# reset win conditions
	GlobalVariables.game_ended = false
	GlobalVariables.character_points = 0
	GlobalVariables.current_character.hud.update_hud(GlobalVariables.current_character.life_total, GlobalVariables.current_character.special_amount, GlobalVariables.current_character.points)
	
	Instantiables.go_to_hub(GlobalVariables.hub_selected)
	get_tree().paused = false
