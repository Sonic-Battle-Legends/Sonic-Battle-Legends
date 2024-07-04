extends Node3D


@export var new_stage: PackedScene


func _on_area_3d_area_entered(area):
	var object = area.get_parent()
	# when the player attacks this area marker,
	# enter the respective stage
	if object != null and object.is_in_group("Player"):
		GlobalVariables.go_to_stage_from_hub(new_stage)
		#get_tree().call_deferred("change_scene_to_file", full_path)
