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
	life_ui.text = str(life_amount)


## change the amount shown in the special bar on hud in-game
func change_special(special_amount):
	special_ui.text = str(special_amount)


## change the amount of points gained shown on hud in-game
func change_points(points_amount):
	points_ui.text = str(points_amount) + "Pt"


## change the avatar image next to the points shown on hud in-game
func change_avatar(new_avatar):
	avatar_ui.texture = new_avatar
