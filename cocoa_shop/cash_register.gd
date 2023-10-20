class_name CashRegister

extends Node2D

signal served(customer: Customer)

enum CashRegisterState { NONE, WAITING, READY_TO_SERVE, SERVING }

var _curr_player: Player
var _curr_player_is_leaving = false
var _curr_customer: Customer: set = set_current_customer
var _curr_state: CashRegisterState

func _is_customer_ready_to_give_order():
	return false


func _curr_player_arrived():
	return _curr_player and not _curr_player_is_leaving


func _ready():
	_determine_state()


func _on_area_register_body_entered(body):
	_curr_player = body as Player
	if _curr_player:
		_determine_state()


func _on_area_register_body_exited(body):
	_curr_player_is_leaving = true
	_determine_state()
	_curr_player = null


func set_current_customer(new_customer: Customer):
	_curr_customer = new_customer

 
##### STATE MACHINE #####
func _determine_state():
	var new_state = _curr_state
	
	match _curr_state:
		CashRegisterState.NONE:
			new_state = CashRegisterState.WAITING
		CashRegisterState.WAITING:
			if _curr_player_arrived():
				if _curr_customer:
					new_state = CashRegisterState.SERVING
				else:
					new_state = CashRegisterState.READY_TO_SERVE
		CashRegisterState.READY_TO_SERVE:
			if not _curr_player_arrived():
				new_state = CashRegisterState.WAITING
		CashRegisterState.SERVING:
			if not _curr_player_arrived() or not _curr_customer:
				new_state = CashRegisterState.WAITING
	
	_set_state(new_state)


func _set_state(new_state):
	if _curr_state == new_state:
		match _curr_state:
			CashRegisterState.WAITING:
				_retrigger_waiting_state()
			CashRegisterState.READY_TO_SERVE:
				_retrigger_ready_to_serve_state()
			CashRegisterState.SERVING:
				_retrigger_serving_state()
	
	# Exit State
	match _curr_state:
		CashRegisterState.WAITING:
			_exit_waiting_state()
		CashRegisterState.READY_TO_SERVE:
			_exit_ready_to_serve_state()
		CashRegisterState.SERVING:
			_exit_serving_state()
	
	print("Cash Register Transition [%s]->[%s]" % \
		[CashRegisterState.keys()[_curr_state], CashRegisterState.keys()[new_state]])
	_curr_state = new_state
	
	# Enter State
	match _curr_state:
		CashRegisterState.WAITING:
			_enter_waiting_state()
		CashRegisterState.READY_TO_SERVE:
			_enter_ready_to_serve_state()
		CashRegisterState.SERVING:
			_enter_serving_state()


### WAITING STATE ###
func _retrigger_waiting_state():
	_curr_player_is_leaving = false


func _update_waiting_state(delta):
	pass


func _enter_waiting_state():
	pass


func _exit_waiting_state():
	pass


### READY TO SERVE STATE ###
func _retrigger_ready_to_serve_state():
	pass


func _update_ready_to_serve_state():
	pass


func _enter_ready_to_serve_state():
	if _curr_player:
		_curr_player.start_message("Waiting for customer...")


func _exit_ready_to_serve_state():
	_curr_player_is_leaving = false
	if _curr_player:
		_curr_player.stop_message()


### SERVING STATE ###
func _retrigger_serving_state():
	_curr_player_is_leaving = false


func _update_serving_state():
	pass


func _enter_serving_state():
	if _curr_player:
		_curr_player.start_notify_interactable("Take Order")
#		_curr_player.interacted.connect()


func _exit_serving_state():
	_curr_player_is_leaving = false
	if _curr_player:
		_curr_player.stop_notify_interactable()
