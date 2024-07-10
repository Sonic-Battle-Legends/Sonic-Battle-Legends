extends Node3D

## object to move
@export var object_to_move: Node3D
## from where the object is coming
## it will be set by the script on ready
@export var from: Marker3D
## to where the object is going
## move this marker where the object should go
@export var to: Marker3D
## pace to move
@export var pace: float = 0.1
## if this object should return to original position when reaching target position
@export var move_back: bool = false

var target_position: Vector3
var can_move = false
var returning: bool = false


func _ready():
	from.position = object_to_move.position


func _process(_delta):
	if can_move:
		object_to_move.position = lerp(object_to_move.position, target_position, pace)
		if object_to_move.position == target_position:
			can_move = false
			if move_back and not returning:
				reset_position()


func move():
	push_warning("here")
	can_move = true
	returning = false
	target_position = to_global(to.position)


func reset_position():
	can_move = true
	if move_back:
		returning = true
	target_position = to_global(from.position)
