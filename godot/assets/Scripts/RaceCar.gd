extends VehicleBody3D
class_name RaceCar

@export var max_steer : float = 0.2
@export var engine_power : float = 20
@export var steer_rate : float = 0.7

@export var steering_pct : float = 0.0
@export var throttle_pct : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	steering = move_toward(steering,
		steering_pct * max_steer, delta * steer_rate)
		
	engine_force = throttle_pct * engine_power
