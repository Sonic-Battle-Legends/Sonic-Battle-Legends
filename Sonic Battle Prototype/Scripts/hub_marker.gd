extends Node3D


@export var new_stage: PackedScene


func _on_area_3d_area_entered(area):
	var object = area.get_parent()
	# when the player attacks this area marker,
	if object != null and object.is_in_group("Player"):
		# enter the respective stage
		# using the stage provided in the hub marker field instead of
		# Instantiables to help development.
		# Set the stage in the marker inside a hub
		# or make a list in the instantiables and make it accessible as a filter
		# in the hub marker's "new_stage" field in the inspector
		GlobalVariables.go_to_stage_from_hub(new_stage)
