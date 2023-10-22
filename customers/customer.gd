class_name Customer

extends CharacterBody2D

signal move_to_succeeded(customer: Customer, destination: Vector2)

@export var speed = 20.0
@export var glass_event: EventAsset
@export var order_event: EventAsset
@export var waiting_event: EventAsset
@export var happy_event: EventAsset
@export var sad_event: EventAsset
@export var leave_event: EventAsset
@export var pay_event: EventAsset

@onready var _drink_icon = $CollisionShape2D/Sprite2D/OrderIcon/PanelContainer/DrinkIcon
@onready var _order_icon = $CollisionShape2D/Sprite2D/OrderIcon
@onready var _drink_pos_marker = $DrinkPosition as Marker2D
@onready var _sprite = $CollisionShape2D/Sprite2D
@onready var _animation_player = $AnimationPlayer

var _curr_destination: Vector2
var _curr_direction: Vector2
var _is_fulfilling_move_to_request = false
var _curr_order: CustomerOrder: set = set_order, get = get_order
var _order_taken = false
var _curr_drink: CocoaDrink


func _physics_process(delta):
	if not is_at_destination():
		velocity = _curr_direction * speed
		if abs(velocity.x) > 0 or abs(velocity.y) > 0:
			if sign(velocity.x) >= 0:
				_sprite.set_flip_h(false)
				_animation_player.play("Walking")
			else:
				_sprite.set_flip_h(true)
				_animation_player.play("Walking")
		else:
			_sprite.set_flip_h(false)
			_animation_player.play("Idle_Blinking")
		move_and_slide()
	elif _is_fulfilling_move_to_request:
		_animation_player.play("Idle_Blinking")
		_is_fulfilling_move_to_request = false
		move_to_succeeded.emit(self, _curr_destination)


func set_order(new_order: CustomerOrder):
	_drink_icon.texture = new_order._cocoa_bean_resource.drink_icon
	_curr_order = new_order


func give_drink(drink: CocoaDrink):
	_curr_drink = drink
	if _curr_drink:
		_order_icon.set_visible(false)
		_curr_drink.reparent(self)
		_curr_drink.set_position(_drink_pos_marker.position)
		FMODRuntime.play_one_shot(glass_event, _curr_drink)


func take_order():
	_order_taken = true
	_order_icon.set_visible(true)
	FMODRuntime.play_one_shot(order_event, self)
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


func exit():
	FMODRuntime.play_one_shot(leave_event, self)
	await get_tree().create_timer(0.2).timeout
	queue_free()
