class_name CustomerManager

extends Node

enum EmotionalState { HAPPY = 0, SAD = 1 }

@export_group("Config")
@export var cocoa_drink_queue: CocoaDrinkQueue
@export var cash_register: CashRegister
@export var customer_spawn_time := 1
@export var customer_queue: CustomerQueue
@export var pickup_queue: CustomerQueue
@export var customer_types: Array

@export_group("Orders")
@export var possible_orders: Array

@export_group("Markers")
@export var spawn_marker: Marker2D
@export var exit_marker: Marker2D
@export var entry_marker: Marker2D

@onready var _timer_customer_spawning = $TimerCustomerSpawning as Timer

var _rand: RandomNumberGenerator


func _ready():
	_rand = RandomNumberGenerator.new()
	
	_timer_customer_spawning.set_one_shot(true)
	_timer_customer_spawning.timeout.connect(_spawn_customer)
	_timer_customer_spawning.start(customer_spawn_time)
	
	cocoa_drink_queue.first_drink_readied.connect(_on_first_drink_readied)
	
	customer_queue.dequeued.connect(_on_order_queue_dequeued)
	customer_queue.first_customer_readied.connect(_on_order_queue_first_customer_readied)
	
	pickup_queue.dequeued.connect(_on_pickup_queue_dequeued)
	pickup_queue.queue_full.connect(_on_pickup_queue_full)
	pickup_queue.first_customer_readied.connect(_on_pickup_queue_first_customer_readied)
	
	cash_register.order_taken.connect(_on_order_taken)


func _pickup_drink():
	if not pickup_queue.is_empty() and cocoa_drink_queue.can_take_drink():
		var customer = pickup_queue.dequeue() as Customer
		var drink = cocoa_drink_queue.take_drink()
		customer.reparent(self)
		customer.give_drink(drink)
		customer.move_to_succeeded.connect(_on_customer_exit)
		customer.request_move_to(exit_marker.global_position)


func _on_first_drink_readied():
	_pickup_drink()


func _on_customer_exit(customer: Customer, destination: Vector2):
	customer.exit()


func _on_order_taken(customer: Customer):
	var cust = customer_queue.dequeue()
	if not cust:
		printerr("Could not dequeue customer: %s" % str(cust))
		return
	
	cash_register.set_current_customer(null)
	pickup_queue.enqueue(cust)


func _on_order_queue_first_customer_readied(customer: Customer):
	cash_register.set_current_customer(customer)


func _on_order_queue_dequeued(customer: Customer):
	if _timer_customer_spawning.is_stopped() and customer_queue.has_capacity():
		_timer_customer_spawning.start(customer_spawn_time)


func _on_pickup_queue_full():
	cash_register.set_pickup_queue_full(true)


func _on_pickup_queue_dequeued(customer: Customer):
	if pickup_queue.has_capacity() and cash_register.is_stopped():
		cash_register.set_pickup_queue_full(false)


func _on_pickup_queue_first_customer_readied(customer: Customer):
	_pickup_drink()


func _get_random_order():
	_rand.randomize()
	return possible_orders[_rand.randi_range(0, possible_orders.size() - 1)]


func _on_entry_move_to_succeeded(customer: Customer, destination: Vector2):
	customer.move_to_succeeded.disconnect(_on_entry_move_to_succeeded)
	customer_queue.enqueue(customer)


func _spawn_customer():
	if customer_queue.has_capacity():
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var randi = rng.randi_range(0, customer_types.size() - 1)
		var cust_template = customer_types[randi]
		var new_cust = cust_template.instantiate() as Customer # CUSTOMER.instantiate() as Customer
		add_child(new_cust)
		new_cust.set_order(_get_random_order())
		new_cust.set_position(spawn_marker.position)
		customer_queue.reserve()
		new_cust.move_to_succeeded.connect(_on_entry_move_to_succeeded)
		new_cust.request_move_to(entry_marker.position)
		_timer_customer_spawning.start(customer_spawn_time)
