class_name CocoaDrinkQueue

extends Node2D

signal first_drink_readied()

@export var speed = 12.0
@export var spacing = 10.0

@onready var _queue_path = $QueuePath
@onready var _end_of_queue_marker = $EndOfQueueMarker

enum CocoaDrinkQueueState { NONE, WAITING, MOVING_DRINKS }

var _capacity: int
var _queue_slots: Array
var _drinks: Array
var _queue_direction: Vector2
var _queue_end_position: Vector2
var _curr_cocoa_drink_queue_state = CocoaDrinkQueueState.NONE


func _process(delta):
	_update_current_state(delta)


func _ready():
	_queue_end_position = _end_of_queue_marker.get_position()
	_queue_direction = _queue_end_position.normalized()
	_capacity = _queue_end_position.length() / spacing
	
	for n in range(get_capacity() - 1, -1, -1):
		print(n)
		var new_pos = _queue_direction * (n + 1) * spacing
		_queue_slots.append(new_pos)
	
	for n in range(get_capacity() - 1, -1, -1):
		_queue_path.curve.add_point(_queue_slots[n])
	queue_redraw()
	
	_determine_cocoa_drink_queue_state()


func _draw():
	for p in _queue_slots:
		draw_circle(p, 1.0, Color.RED)


func _are_all_drinks_slotted():
	for index in _drinks.size():
		var curr_drink = _drinks[index] as CocoaDrink
		var exp_pos = _queue_slots[index]
		if curr_drink.position != exp_pos:
			return false
	return true


func get_capacity():
	return _capacity


func enqueue(cocoa_drink: CocoaDrink):
	if cocoa_drink:
		add_child(cocoa_drink)
		cocoa_drink.set_position(Vector2.ZERO)
		_drinks.append(cocoa_drink)
		_determine_cocoa_drink_queue_state()


func can_take_drink():
	if _drinks.size() > 0 and _drinks[0].position == _queue_slots[0]:
		return true
	
	return false


func take_drink():
	if can_take_drink():
		var drink = _drinks.pop_front()
		remove_child(drink)
		return drink
	
	return null


##### STATE MACHINE #####
func _determine_cocoa_drink_queue_state():
	var new_cocoa_drink_queue_state = _curr_cocoa_drink_queue_state
	
	match _curr_cocoa_drink_queue_state:
		CocoaDrinkQueueState.NONE:
			new_cocoa_drink_queue_state = CocoaDrinkQueueState.WAITING
		CocoaDrinkQueueState.WAITING:
			if not _are_all_drinks_slotted():
				new_cocoa_drink_queue_state = CocoaDrinkQueueState.MOVING_DRINKS
		CocoaDrinkQueueState.MOVING_DRINKS:
			if _are_all_drinks_slotted():
				new_cocoa_drink_queue_state = CocoaDrinkQueueState.WAITING
	
	_set_cocoa_drink_queue_state(new_cocoa_drink_queue_state)


func _set_cocoa_drink_queue_state(new_cocoa_drink_queue_state: CocoaDrinkQueueState):
	if _curr_cocoa_drink_queue_state == new_cocoa_drink_queue_state:
		match _curr_cocoa_drink_queue_state:
			CocoaDrinkQueueState.WAITING:
				_retrigger_waiting_state()
			CocoaDrinkQueueState.MOVING_DRINKS:
				_retrigger_moving_drinks_state()
	
	# EXIT STATE
	match _curr_cocoa_drink_queue_state:
		CocoaDrinkQueueState.WAITING:
			_exit_waiting_state()
		CocoaDrinkQueueState.MOVING_DRINKS:
			_exit_moving_drinks_state()
	
	print("Cocoa Drink Queue Transition: [%s]->[%s]" % [ \
		CocoaDrinkQueueState.keys()[_curr_cocoa_drink_queue_state], \
		CocoaDrinkQueueState.keys()[new_cocoa_drink_queue_state] \
	])
	_curr_cocoa_drink_queue_state = new_cocoa_drink_queue_state
	
	# ENTER STATE
	match _curr_cocoa_drink_queue_state:
		CocoaDrinkQueueState.WAITING:
			_enter_waiting_state()
		CocoaDrinkQueueState.MOVING_DRINKS:
			_enter_moving_drinks_state()


func _update_current_state(delta):
	match _curr_cocoa_drink_queue_state:
		CocoaDrinkQueueState.WAITING:
			_update_waiting_state(delta)
		CocoaDrinkQueueState.MOVING_DRINKS:
			_update_moving_drinks_state(delta)


### WAITING STATE ###
func _retrigger_waiting_state():
	pass


func _update_waiting_state(delta):
	pass


func _enter_waiting_state():
	pass


func _exit_waiting_state():
	pass


### MOVING DRINKS STATE ###
func _retrigger_moving_drinks_state():
	pass


func _update_moving_drinks_state(delta):
	for _index in _drinks.size():
		var _curr_drink = _drinks[_index] as CocoaDrink
		if _curr_drink and _index < _queue_slots.size():
			var _dest =  _queue_slots[_index]
			_curr_drink.position = _curr_drink.position.move_toward(_dest, delta * speed)


func _enter_moving_drinks_state():
	pass


func _exit_moving_drinks_state():
	if can_take_drink():
		first_drink_readied.emit()
