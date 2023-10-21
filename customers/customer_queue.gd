class_name CustomerQueue

extends Node2D

signal dequeued(customer: Customer)
signal first_customer_readied(customer: Customer)
signal queue_full()

@onready var _queue_path = $Path2D

var _queue_capacity = 0
var _customers: Array
var _queue_slots: Array


func _ready():
	_queue_capacity = _queue_path.curve.point_count
	for idx in _queue_capacity:
		
		_queue_slots.append(_queue_path.curve.get_point_position(idx))
	print("Capacity: %d" % _queue_capacity)	


func _process(delta):
	for idx in _customers.size():
		var curr_customer = _customers[idx]
		var exp_pos = _queue_slots[idx]
		if curr_customer and curr_customer.position.distance_to(exp_pos) > 0.1:
			curr_customer.request_move_to(exp_pos)


#func _draw():
#	for _slot in _queue_slots:
#		print("%s" % str(_slot))
#		draw_circle(_slot, 2, Color.RED)

func _update_customer_positions():
	for idx in _customers.size():
		var curr_customer = _customers[idx] as Customer
		var exp_pos = _queue_slots[idx]
		if curr_customer and curr_customer.position.distance_to(exp_pos) > 0.1:
			if idx == 0:
				curr_customer.move_to_succeeded.connect(_on_first_customer_ready)
			curr_customer.move_to_succeeded.connect(_on_customer_ready)
			curr_customer.request_move_to(exp_pos)


func _on_first_customer_ready(customer: Customer, destination: Vector2):
	first_customer_readied.emit(customer)


func _on_customer_ready(customer: Customer, destination: Vector2):
	customer._sprite.set_flip_h(true)


func is_empty():
	return _customers.is_empty()


func has_capacity():
	return _customers.size() < _queue_capacity


func can_dequeue():
	if _customers.is_empty():
		return false
	
	return _customers[0].is_at_destination()


func get_first_customer():
	return _customers[0]


func enqueue(new_customer: Customer):
	if has_capacity() && new_customer:
		new_customer.reparent(self)
		_customers.push_back(new_customer)
		if not has_capacity():
			queue_full.emit()
		_update_customer_positions()
		return true
	
	return false


func dequeue():
	if can_dequeue():
		var popped_customer = _customers.pop_front() as Customer
		popped_customer.move_to_succeeded.disconnect(_on_first_customer_ready)
		popped_customer.move_to_succeeded.disconnect(_on_customer_ready)
		dequeued.emit(popped_customer)
		_update_customer_positions()
		return popped_customer
