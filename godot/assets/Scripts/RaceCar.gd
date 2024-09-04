extends VehicleBody3D
class_name RaceCar

@export var max_steer : float = 0.2
@export var engine_power : float = 20
@export var steer_rate : float = 0.7

@export var steering_pct : float = 0.0
@export var throttle_pct : float = 0.0

@export var raycasts : Array[RayCast3D]
@export var hits : Array[CSGSphere3D]
@onready var range: Node3D = $Range

func read_ranges() -> Array[float]:
	var ranges : Array[float]
	ranges.resize(raycasts.size())
	ranges.fill(0)
	
	for i in raycasts.size():
		if (raycasts[i].is_colliding()):
			var p = raycasts[i].get_collision_point()
			var d = p - raycasts[i].global_position
			#hits[i].global_position = p
			ranges[i] = d.length()
		else:
			ranges[i] = 6
	
	return ranges
	
func set_range_visibility(visible: bool):
	range.visible = visible

func reset(position: Node3D):
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	PhysicsServer3D.body_set_state(
		get_rid(),
		PhysicsServer3D.BODY_STATE_TRANSFORM,
		position.global_transform
	)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	steering = move_toward(steering,
		steering_pct * max_steer, delta * steer_rate)
		
	engine_force = throttle_pct * engine_power
