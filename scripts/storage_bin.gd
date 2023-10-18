extends Node2D

class_name StorageBin

@export_group("Config")
@export var cocoa_bean_resource_type: CocoaBeanResource
@export var has_infinite_beans = false

@export_group("Interact Messages")
@export var deposit_bean_msg = "Deposit Bean"
@export var take_bean_msg = "Take Bean"


enum InteractableState {NONE, TAKE_BEAN, DEPOSIT_BEAN}

var _bean_ctr = 0
var _has_beans = false
var _curr_player_is_leaving = false
var _curr_player: Player
var _curr_interactable_state = InteractableState.NONE


func _on_area_2d_body_entered(body):
	_curr_player = body as Player
	_determine_notify_interactable_state()


func _on_area_2d_body_exited(body):
	_curr_player_is_leaving = true
	_determine_notify_interactable_state()
	_curr_player = null


func _on_deposit_bean_interact(player: Player):
	if _curr_player:
		_curr_player.take_bean()
		_determine_notify_interactable_state()
		print("Bean deposited: " + cocoa_bean_resource_type.displayName)
	else:
		print("Bean could not be deposited: " + cocoa_bean_resource_type.displayName)


func _on_take_bean_interact(player: Player):
	if _curr_player:
		_curr_player.give_bean(cocoa_bean_resource_type)
		_determine_notify_interactable_state()
		print("Bean taken: " + cocoa_bean_resource_type.displayName)
	else:
		print("Bean could not be taken: " + cocoa_bean_resource_type.displayName)


func _determine_notify_interactable_state():
	var _new_interactable_state = InteractableState.NONE
	
	if _curr_player:
		if _curr_player_is_leaving:
			_new_interactable_state = InteractableState.NONE
		elif _curr_player.has_bean:
			_new_interactable_state = InteractableState.DEPOSIT_BEAN
		elif _has_beans or has_infinite_beans:
			_new_interactable_state = InteractableState.TAKE_BEAN
	
	_set_notify_interactable_state(_new_interactable_state)


func _set_notify_interactable_state(new_interactable_state: InteractableState):
	if _curr_interactable_state == InteractableState.NONE:
		pass	
	elif _curr_interactable_state == InteractableState.TAKE_BEAN:
		if _curr_player:
			_curr_player.interacted.disconnect(_on_take_bean_interact)
			_curr_player.stop_notify_interactable()
	elif _curr_interactable_state == InteractableState.DEPOSIT_BEAN:
		if _curr_player:
			_curr_player.interacted.disconnect(_on_deposit_bean_interact)
			_curr_player.stop_notify_interactable()
	
	_curr_interactable_state = new_interactable_state
	
	if _curr_interactable_state == InteractableState.NONE:
		_curr_player_is_leaving = false
		if _curr_player:
			_curr_player.interacted.disconnect(_on_take_bean_interact)
			_curr_player.interacted.disconnect(_on_deposit_bean_interact)
	elif _curr_interactable_state == InteractableState.TAKE_BEAN:
		if _curr_player:
			_curr_player.interacted.connect(_on_take_bean_interact)
			_curr_player.start_notify_interactable(take_bean_msg)
	elif _curr_interactable_state == InteractableState.DEPOSIT_BEAN:
		if _curr_player:
			_curr_player.interacted.connect(_on_deposit_bean_interact)
			_curr_player.start_notify_interactable(deposit_bean_msg)
