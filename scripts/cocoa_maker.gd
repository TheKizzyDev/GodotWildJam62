class_name CocoaMaker

extends Node2D

@export_group("Config")
@export var grinding_cocoa_bean_time = 1.0
@export var making_cocoa_time = 1.0
@export var drink_output_speed = 12.0
@export var cocoa_drink_queue: CocoaDrinkQueue

@export_group("Interaction Messages")
@export var insert_bean_interact_messsage = "Insert Bean"
@export var turn_on_interact_message = "Turn On"
@export var requires_bean_warning_message = "Requires bean to start..."
@export var grinding_bean_message = "Grinding bean..."

const COCOA_DRINK = preload("res://cocoa_shop/cocoa_drink.tscn")

enum CocoaMakerState {NONE, WAITING, REQUIRES_BEAN, INSERT_BEAN,
	GRINDING_COCOA_BEAN, READY_TO_MAKE_COCOA, MAKING_COCOA}

var _cocoa_bean_to_drink = {
	CocoaBeanResource.Type.Normal : "res://cocoa_shop/cocoa_drink_normal.tscn",
	CocoaBeanResource.Type.Frozen : "res://cocoa_shop/cocoa_drink_frozen.tscn"
}

var _curr_player: Player
var _curr_player_is_leaving = false
var _curr_cocoa_maker_state = CocoaMakerState.NONE
var _curr_cocoa_bean: CocoaBeanResource

var _is_hovering_grinder = false
var _is_hovering_switch = false
var _turned_on = false
var _making_cocoa = false
var _grinding_cocoa_bean = false

@onready var _timer_grinding_cocoa_bean = $Sprite2D/Area2D_Grinder/Timer
@onready var _timer_making_cocoa = $Sprite2D/Area2D_TurnOn/Timer
@onready var _marker_drink_output = $Sprite2D/DrinkOutputMarker


func _ready():
	if not cocoa_drink_queue:
		printerr("No cocoa drink queue configured.")
		return

	_determine_cocoa_maker_state()


func _process(delta):
	_update_current_state()


func _on_area_2d_grinder_body_exited(body):
	_curr_player_is_leaving = true
	_is_hovering_grinder = false
	_determine_cocoa_maker_state()
	_curr_player = null


func _on_area_2d_grinder_body_entered(body):
	_curr_player = body as Player
	_is_hovering_grinder = true
	_is_hovering_switch = false
	_determine_cocoa_maker_state()


func _on_area_2d_turn_on_body_entered(body):
	_curr_player = body as Player
	_is_hovering_grinder = false
	_is_hovering_switch = true
	_determine_cocoa_maker_state()


func _on_area_2d_turn_on_body_exited(body):
	_curr_player_is_leaving = true
	_is_hovering_switch = false
	_determine_cocoa_maker_state()
	_curr_player = null


##### UTILITIES #####
func _clear_player_is_leaving():
	_curr_player_is_leaving = false


###### STATE MACHINE ######
func _determine_cocoa_maker_state():
	var _new_cocoa_maker_state = CocoaMakerState.WAITING
	match _curr_cocoa_maker_state:
		CocoaMakerState.WAITING:
			if _curr_player:
				if not _curr_player_is_leaving:
					if not _curr_cocoa_bean:	
						if _curr_player.has_bean:
							_new_cocoa_maker_state = CocoaMakerState.INSERT_BEAN
						else:
							_new_cocoa_maker_state = CocoaMakerState.REQUIRES_BEAN
		CocoaMakerState.REQUIRES_BEAN:
			pass
		CocoaMakerState.INSERT_BEAN:
			if _curr_cocoa_bean:
				_new_cocoa_maker_state = CocoaMakerState.GRINDING_COCOA_BEAN
		CocoaMakerState.GRINDING_COCOA_BEAN:
			if _grinding_cocoa_bean:
				_new_cocoa_maker_state = CocoaMakerState.GRINDING_COCOA_BEAN
			else:
				_new_cocoa_maker_state = CocoaMakerState.READY_TO_MAKE_COCOA
		CocoaMakerState.READY_TO_MAKE_COCOA:
			if _turned_on:
				_new_cocoa_maker_state = CocoaMakerState.MAKING_COCOA
			else:
				_new_cocoa_maker_state = CocoaMakerState.READY_TO_MAKE_COCOA
		CocoaMakerState.MAKING_COCOA:
			if _making_cocoa:
				_new_cocoa_maker_state = CocoaMakerState.MAKING_COCOA
			else:
				_new_cocoa_maker_state = CocoaMakerState.WAITING
			
	_set_cocoa_maker_state(_new_cocoa_maker_state)


func _set_cocoa_maker_state(_new_cocoa_maker_state):
	# Retrigger Current State
	if _curr_cocoa_maker_state == _new_cocoa_maker_state:
		print("Retriggering State: %s" % CocoaMakerState.keys()[_curr_cocoa_maker_state])
		match _curr_cocoa_maker_state:
			CocoaMakerState.WAITING:
				_retrigger_waiting_state()
			CocoaMakerState.REQUIRES_BEAN:
				_retrigger_requires_bean_state()
			CocoaMakerState.INSERT_BEAN:
				_retrigger_insert_bean_state()
			CocoaMakerState.GRINDING_COCOA_BEAN:
				_retrigger_grinding_cocoa_bean_state()
			CocoaMakerState.READY_TO_MAKE_COCOA:
				_retrigger_ready_to_make_cocoa_state()
			CocoaMakerState.MAKING_COCOA:
				_retrigger_making_cocoa_state()
		return
	
	# Exit State
	match _curr_cocoa_maker_state:
		CocoaMakerState.WAITING:
			_exit_waiting_state()
		CocoaMakerState.REQUIRES_BEAN:
			_exit_requires_bean_state()
		CocoaMakerState.INSERT_BEAN:
			_exit_insert_bean_state()
		CocoaMakerState.GRINDING_COCOA_BEAN:
			_exit_grinding_cocoa_bean_state()
		CocoaMakerState.READY_TO_MAKE_COCOA:
			_exit_ready_to_make_cocoa_state()
		CocoaMakerState.MAKING_COCOA:
			_exit_making_cocoa_state()
	
	print("Cocoa Maker Transition: [%s]->[%s]" % [ \
		CocoaMakerState.keys()[_curr_cocoa_maker_state], \
		CocoaMakerState.keys()[_new_cocoa_maker_state] \
	])
	_curr_cocoa_maker_state = _new_cocoa_maker_state
	
	# Enter State
	match _curr_cocoa_maker_state:
		CocoaMakerState.WAITING:
			_enter_waiting_state()
		CocoaMakerState.REQUIRES_BEAN:
			_enter_requires_bean_state()
		CocoaMakerState.INSERT_BEAN:
			_enter_insert_bean_state()
		CocoaMakerState.GRINDING_COCOA_BEAN:
			_enter_grinding_cocoa_bean_state()
		CocoaMakerState.READY_TO_MAKE_COCOA:
			_enter_ready_to_make_cocoa_state()
		CocoaMakerState.MAKING_COCOA:
			_enter_making_cocoa_state()


func _update_current_state():
	match _curr_cocoa_maker_state:
		CocoaMakerState.WAITING:
			_update_waiting_state()
		CocoaMakerState.REQUIRES_BEAN:
			_update_requires_bean_state()
		CocoaMakerState.INSERT_BEAN:
			_update_requires_bean_state()
		CocoaMakerState.GRINDING_COCOA_BEAN:
			_update_grinding_cocoa_bean_state()
		CocoaMakerState.READY_TO_MAKE_COCOA:
			_update_ready_to_make_cocoa_state()
		CocoaMakerState.MAKING_COCOA:
			_update_making_cocoa_state()


### WAITING STATE ###
func _retrigger_waiting_state():
	_clear_player_is_leaving()
	_curr_cocoa_bean = null
	_grinding_cocoa_bean = false
	_making_cocoa = false
	_turned_on = false
	
	if _curr_player:
		if _curr_player.interacted.is_connected(_on_insert_bean_into_grinder):
			_curr_player.interacted.disconnect(_on_insert_bean_into_grinder)
		if _curr_player.interacted.is_connected(_on_turn_on):
			_curr_player.interacted.disconnect(_on_turn_on)
		_curr_player.stop_notify_interactable()
		_curr_player.stop_message()


func _update_waiting_state():
	pass


func _enter_waiting_state():
	_retrigger_waiting_state()


func _exit_waiting_state():
	pass


### REQUIRES BEAN STATE ###
func _retrigger_requires_bean_state():
	pass


func _update_requires_bean_state():
	pass


func _enter_requires_bean_state():
	if _curr_player:
		_curr_player.start_message(requires_bean_warning_message)


func _exit_requires_bean_state():
	if _curr_player:
		_curr_player.stop_message()


### INSERT BEAN STATE ###
func _retrigger_insert_bean_state():
	pass


func _update_insert_bean_state():
	pass


func _enter_insert_bean_state():
	if _curr_player:
		_curr_player.interacted.connect(_on_insert_bean_into_grinder)
		_curr_player.start_notify_interactable(insert_bean_interact_messsage)


func _exit_insert_bean_state():
	if _curr_player:
		_curr_player.interacted.disconnect(_on_insert_bean_into_grinder)
		_curr_player.stop_notify_interactable()


func _on_insert_bean_into_grinder(player: Player):
	if not player:
		printerr("Invalid player")
		return
	
	if not _curr_cocoa_bean:
		_curr_cocoa_bean = player.take_bean() as CocoaBeanResource
		if not _curr_cocoa_bean:
			printerr("Bean did not exist.")
		else:
			print("%s inserted." % _curr_cocoa_bean.get_display_name())
		_determine_cocoa_maker_state()
	else:
		player.start_message("Already has cocoa bean.")
		printerr("Already has cocoa bean: %s" % _curr_cocoa_bean.get_display_name())


### GRINDING COCOA BEAN STATE ###
func _retrigger_grinding_cocoa_bean_state():
	if _curr_player:
		if _curr_player_is_leaving:
			_curr_player.stop_message()
		else:
			_curr_player.start_message(grinding_bean_message)
	
	_clear_player_is_leaving()


func _update_grinding_cocoa_bean_state():
	pass


func _enter_grinding_cocoa_bean_state():
	_grinding_cocoa_bean = true
	_timer_grinding_cocoa_bean.wait_time = grinding_cocoa_bean_time
	_timer_grinding_cocoa_bean.one_shot = true
	_timer_grinding_cocoa_bean.connect("timeout", _on_timer_grinding_cocoa_bean_timeout)
	_timer_grinding_cocoa_bean.start()
	# TODO: Play animation for grinding cocoa bean.
		
	_retrigger_grinding_cocoa_bean_state()


func _exit_grinding_cocoa_bean_state():
	_grinding_cocoa_bean = false
	_timer_grinding_cocoa_bean.stop()
	_timer_grinding_cocoa_bean.disconnect("timeout", _on_timer_grinding_cocoa_bean_timeout)
	
	if _curr_player:
		_curr_player.stop_message()


func _on_timer_grinding_cocoa_bean_timeout():
	print("Done grinding cocoa bean.")
	_grinding_cocoa_bean = false
	_determine_cocoa_maker_state()


### READY TO MAKE COCOA STATE ###
func _retrigger_ready_to_make_cocoa_state():
	if _curr_player:
		if _curr_player and not _curr_player_is_leaving:
			if _is_hovering_switch:
				_curr_player.interacted.connect(_on_turn_on)
				_curr_player.start_notify_interactable(turn_on_interact_message)
			else:
				_curr_player.interacted.disconnect(_on_turn_on)
				_curr_player.stop_notify_interactable()
		else:
			_curr_player.interacted.disconnect(_on_turn_on)
			_curr_player.stop_notify_interactable()
	
	_clear_player_is_leaving()


func _update_ready_to_make_cocoa_state():
	pass


func _enter_ready_to_make_cocoa_state():
	_retrigger_ready_to_make_cocoa_state()


func _exit_ready_to_make_cocoa_state():
	if _curr_player:
		_curr_player.stop_notify_interactable()


func _on_turn_on(player: Player):
	if not player:
		printerr("Invalid player")
		return

	_turned_on = true
	_determine_cocoa_maker_state()


### MAKING COCOA ###
func _retrigger_making_cocoa_state():
	if _curr_player:
		if _curr_player_is_leaving:
			_curr_player.stop_message()
		else:
			_curr_player.start_message("Making cocoa...")
	
	if _curr_player_is_leaving:
		_curr_player_is_leaving = false


func _update_making_cocoa_state():
	pass


func _enter_making_cocoa_state():
	_making_cocoa = true
	_timer_making_cocoa.wait_time = making_cocoa_time
	_timer_making_cocoa.one_shot = true
	_timer_making_cocoa.connect("timeout", _on_timer_making_cocoa_timeout)
	_timer_making_cocoa.start()
	_retrigger_making_cocoa_state()
	# TODO: Play animation for making cocoa.


func _exit_making_cocoa_state():
	if _cocoa_bean_to_drink.has(_curr_cocoa_bean.type):
		var cocoa_drink_path = _cocoa_bean_to_drink[_curr_cocoa_bean.type]
		var cocoa_drink = ResourceLoader.load(cocoa_drink_path)
		var _cocoa_drink = cocoa_drink.instantiate() # COCOA_DRINK.instantiate()
		cocoa_drink_queue.enqueue(_cocoa_drink)
		print("MADE COCOA: %s" % cocoa_drink_path)
	_making_cocoa = false
	_curr_cocoa_bean = null
	_timer_making_cocoa.stop()
	_timer_making_cocoa.disconnect("timeout", _on_timer_making_cocoa_timeout)
	if _curr_player:
		_curr_player.stop_message()


func _on_timer_making_cocoa_timeout():
	_making_cocoa = false
	_determine_cocoa_maker_state()
