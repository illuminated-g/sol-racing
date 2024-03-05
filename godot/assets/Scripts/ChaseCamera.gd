extends Node3D
class_name ChaseCamera

@export var target : VehicleBody3D
@export var is_physics : bool = true

@export var position_lerp_factor : float = 20.0
@export var transform_lerp_factor : float = 5.0

@onready var camera = $Camera

func update(delta: float):
	if target == null:
		return
		
	global_position = global_position.lerp(
		target.global_position, delta * position_lerp_factor)
		
	transform = transform.interpolate_with(
		target.transform, delta * transform_lerp_factor)

func _process(delta: float):
	if !is_physics:
		update(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	if is_physics:
		update(delta)
