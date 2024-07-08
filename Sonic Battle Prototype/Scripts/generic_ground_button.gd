extends Node3D

@export var object_with_method: Node3D
@export var method_name: String


func _on_area_3d_area_entered(_area):
	if object_with_method != null and object_with_method.has_method(method_name):
		#object_with_method.method_name
		object_with_method.call(method_name)
