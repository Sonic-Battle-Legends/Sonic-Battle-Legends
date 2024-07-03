extends Control

# each part of the hud
@export var life_ui: RichTextLabel
@export var special_ui: RichTextLabel
@export var points_ui: RichTextLabel
@export var avatar_ui: TextureRect


# update the all hud fields
func update_hud(life_amount, special_amount, points_amount):
	change_life(life_amount)
	change_special(special_amount)
	change_points(points_amount)


## change the amount shown in the life points on hud in-game
func change_life(life_amount):
	var new_life_bar = fill_bar_with(life_amount)
	life_ui.text = new_life_bar


## change the amount shown in the special bar on hud in-game
func change_special(special_amount):
	var new_special_bar = fill_bar_with(special_amount)
	special_ui.text = new_special_bar


## change the amount of points gained shown on hud in-game
func change_points(points_amount):
	points_ui.text = str(points_amount) + "Pt"


## change the avatar image next to the points shown on hud in-game
func change_avatar(new_avatar):
	avatar_ui.texture = new_avatar


func fill_bar_with(resource) -> String:
	var new_bar = "/"
	# add a char for each 4 points
	var char_amount = resource / 4
	for i in range(char_amount):
		new_bar += "|"
	
	# fill blank spaces
	var empty = (100 - resource) / 4
	for j in range(empty):
		new_bar += "_"
	new_bar += "/"
	return new_bar
