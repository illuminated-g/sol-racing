extends Node
class_name KeyboardCarController

@export var car : RaceCar

@export var throttle : float = 0.0
@export var steering : float = 0.0

@export var chase_camera : Camera3D
@export var overhead_camera : Camera3D

@export var start_position : Node3D

var current_camera : int = 0

func switch_camera():
	current_camera = current_camera + 1
	if current_camera == 2:
		current_camera = 0
	
	if current_camera == 0:
		chase_camera.make_current()
	elif current_camera == 1:
		overhead_camera.make_current()

func reset_car():
	car.reset(start_position)

func _input(event: InputEvent):
	if event.is_action_pressed("switch_camera"):
		switch_camera()
	
	if event.is_action_pressed("reset_car"):
		reset_car()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	steering = Input.get_axis("ui_right", "ui_left")		
	throttle = Input.get_axis("ui_down", "ui_up")
	
	if car != null:
		car.steering_pct = steering
		car.throttle_pct = throttle
