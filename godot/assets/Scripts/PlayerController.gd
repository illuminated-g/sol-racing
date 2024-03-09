extends Node
class_name PlayerController

@export var car : RaceCar
@export var ws : WebSocketClient

@export var start_position : Node3D

@export var chase_camera : Camera3D
@export var overhead_camera : Camera3D

var lap_start: int = 0
var last_lap: int = -1

func _onready():
	lap_start = Time.get_ticks_msec()

func set_camera(cam: int):	
	if cam == 0:
		chase_camera.make_current()
	elif cam == 1:
		overhead_camera.make_current()

func _on_ws_client_new_message(msg: PackedByteArray):
	var id = msg.decode_u8(0)
	
	match (id):
		1: #Reset Car
			car.reset(start_position)
			
		2: #Request ranges
			var ranges: Array[float] = car.read_ranges()
			
			var payload = PackedByteArray()
			payload.resize(ranges.size() * 4 + 1 + 4)
			payload.encode_u8(0, 2) # Range response
			payload.encode_s32(1, ranges.size()) #prepend array size
			
			var offset : int = 1 + 4
			for i in ranges.size():
				payload.encode_float(offset, ranges[i])
				offset += 4
			
			ws.send(payload)
		3: # Control car
			var steering: float = msg.decode_float(1)
			var throttle: float = msg.decode_float(5)
			
			car.steering_pct = steering
			car.throttle_pct = throttle
			
		4: # Read car info
			var speed : float = car.linear_velocity.length()
			var px : float = car.position.x
			var pz : float = car.position.z
			var ry : float = car.rotation_degrees.y
			
			var payload = PackedByteArray()
			payload.resize(4 * 4 + 1)
			payload.encode_u8(0, 4) # info response
			payload.encode_float(1, speed)
			payload.encode_float(5, px)
			payload.encode_float(9, pz)
			payload.encode_float(13, ry)
			
			ws.send(payload)
			
		5: # Set UI options
			var visible: bool = msg.decode_u8(1) > 0
			car.set_range_visibility(visible)
		
		6: #Set camera selection
			var cam: int = msg.decode_s32(1)
			set_camera(cam)
		
		7: #Set pause
			var pause: bool = msg.decode_u8(1) > 0
			get_tree().paused = pause
		
		8: #Lap Timing
			var payload = PackedByteArray()
			payload.resize (16 + 1)
			payload.encode_u8(0, 8) # time response
			
			var now: int = Time.get_ticks_msec()
			payload.encode_s64(1, now - lap_start)
			payload.encode_s64(9, last_lap)
			ws.send(payload)

func _on_ws_client_ready_state(ready_state):
	print(ready_state)


func _on_start_arch_car_passed(car: RaceCar):
	var now: int = Time.get_ticks_msec()
	last_lap = now - lap_start 
	lap_start = now
	print("Lap mS ", last_lap)
