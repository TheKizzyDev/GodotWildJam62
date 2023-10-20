class_name CustomerManager

extends Node

@export_group("Config")
@export var cocoa_drink_queue: CocoaDrinkQueue
@export var cash_register: CashRegister
@export var customer_spawn_time := 1
@export var customer_queue: CustomerQueue

@export_group("Markers")
@export var spawn_marker: Marker2D
@export var exit_marker: Marker2D

@onready var _timer_customer_spawning = $TimerCustomerSpawning as Timer


const CUSTOMER = preload("res://customers/customer.tscn")


func _ready():
	_timer_customer_spawning.set_one_shot(true)
	_timer_customer_spawning.timeout.connect(_spawn_customer)
	_timer_customer_spawning.start(customer_spawn_time)
	customer_queue.dequeued.connect(_on_queue_changed)


func _on_queue_changed(customer: Customer):
	if _timer_customer_spawning.is_stopped() and customer_queue.has_capacity():
		_timer_customer_spawning.start(customer_spawn_time)


func _spawn_customer():
	if customer_queue.has_capacity():
		var new_cust = CUSTOMER.instantiate() as Customer
		add_child(new_cust)
		new_cust.set_position(spawn_marker.position)
		customer_queue.enqueue(new_cust)
		_timer_customer_spawning.start(customer_spawn_time)
