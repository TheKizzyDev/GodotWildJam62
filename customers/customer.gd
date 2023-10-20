class_name Customer

extends CharacterBody2D

signal move_to_succeeded(customer: Customer, destination: Vector2)

@export var speed = 20.0

var _curr_destination: Vector2
var _curr_direction: Vector2
var _is_new_move_to_request = false


func request_move_to(new_position: Vector2):
	_curr_destination = new_position
	_curr_direction = (_curr_destination - position).normalized()
	_is_new_move_to_request = true


func _physics_process(delta):
	if _curr_destination.distance_to(position) > 0.1:
		velocity = _curr_direction * speed
		
		move_and_slide()
	elif _is_new_move_to_request:
		_is_new_move_to_request = false
		move_to_succeeded.emit(self, _curr_destination)
