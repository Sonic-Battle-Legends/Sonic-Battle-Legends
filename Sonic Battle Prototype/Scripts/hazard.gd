extends Node3D

@export var anim: AnimationPlayer


func _on_spike_area_collider_area_entered(area):
	var col = area.get_parent()
	if col != null and col.is_in_group("Player"):
		anim.play("action")
		var hazard_impulse = Vector3(0, 6, 0)
		# make the character goes against it's forward (increasing damage too)
		hazard_impulse -= col.model_node.transform.basis.z.normalized() * 15
		
		col.get_hurt.rpc_id(col.get_multiplayer_authority(), hazard_impulse, self)
