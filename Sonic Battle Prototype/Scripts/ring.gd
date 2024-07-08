extends Node3D


## add a method unique to the ring
## to prevent deleting another object
func delete_ring():
	delete()


@rpc("any_peer", "call_local")
func delete():
	# effects
	# audio
	# remove from scene
	queue_free()
