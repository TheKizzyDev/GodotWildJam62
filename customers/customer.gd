class_name Customer

extends CharacterBody2D

signal move_to_succeeded(customer: Customer, destination: Vector2)

@export var speed = 20.0

@onready var _order_icon = $CollisionShape2D/Sprite2D/OrderIcon

var _curr_destination: Vector2
var _curr_direction: Vector2
var _is_fulfilling_move_to_request = false
var _curr_order: CustomerOrder: set = set_order, get = get_order
var _order_taken = false
var _curr_drink: CocoaDrink


func _physics_process(delta):
	if not is_at_destination():
		velocity = _curr_direction * speed
		
		move_and_slide()
	elif _is_fulfilling_move_to_request:
		_is_fulfilling_move_to_request = false
		move_to_succeeded.emit(self, _curr_destination)


func set_order(new_order: CustomerOrder):
	_curr_order = new_order


func give_drink(drink: CocoaDrink):
	_curr_drink = drink
	if _curr_drink:
		_order_icon.set_visible(false)
		_curr_drink.reparent(self)
		_curr_drink.set_position($DrinkPosition.position)


func take_order():
	_order_taken = true
	_order_icon.set_visible(true)
	# TODO: Determine state.
	return _curr_order


func get_order():
	return _curr_order


func has_ordered():
	return _order_taken


func is_at_destination():
	return _curr_destination.distance_to(position) < 0.5


func request_move_to(new_position: Vector2):
	_curr_destination = new_position
	_curr_direction = (_curr_destination - position).normalized()
	_is_fulfilling_move_to_request = true
