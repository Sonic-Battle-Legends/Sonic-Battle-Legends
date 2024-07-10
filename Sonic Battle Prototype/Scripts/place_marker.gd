extends Label3D

## which place this marker leads to
@export var new_place: PackedScene
@export var new_world_or_hub: Instantiables.worlds_and_hubs

enum place {area, hub, stage}
## what type of place this marker leads to
@export var place_type: place

## how many rings the character needs to enter this place.
## It will be added in the next line in the label's text if
## the character doesn't have enough rings
@export var rings_to_enter: int = 0


func _ready():
	if rings_to_enter > 0 and GlobalVariables.total_rings < rings_to_enter:
		var old_text = text
		text = old_text + "\nRings: " + str(rings_to_enter)


func _on_area_3d_area_entered(area):
	var object = area.get_parent()
	# when the player attacks this area marker
	# will probably need a boolean to store which place the player have already visited
	if GlobalVariables.total_rings >= rings_to_enter and object != null and object.is_in_group("Player") and object.attacking:
		# enter the respective stage
		# using the stage provided in the place marker field instead of
		# a stage provided by the Instantiables script to help development
		# or make a list in the instantiables and make it accessible as a filter
		# in the hub marker's "new_stage" field in the inspector
		match place_type:
			place.area:
				GlobalVariables.area_selected = Instantiables.match_place(new_world_or_hub)
				Instantiables.go_to_area(GlobalVariables.area_selected)
			place.hub:
				GlobalVariables.hub_selected = Instantiables.match_place(new_world_or_hub)
				Instantiables.go_to_hub(GlobalVariables.hub_selected)
			place.stage:
				GlobalVariables.stage_selected = new_place
				Instantiables.go_to_stage(new_place)
