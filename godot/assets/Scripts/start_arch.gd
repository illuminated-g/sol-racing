extends Node3D

signal car_passed

var passing_cars : Array[RaceCar]

func _on_entry_body_entered(body: Node3D):
	var car = body as RaceCar
	var i: int = passing_cars.find(car)
	
	if i < 0:
		passing_cars.append(body as RaceCar)

func _on_exit_body_entered(body: Node3D):
	var car = body as RaceCar
	var i: int = passing_cars.find(car)
	
	if i < 0:
		return
	
	passing_cars.remove_at(i)
	
	car_passed.emit(car)
	print("lap!")
