extends Node2D

class_name StorageBin

@export_group("Config")
@export var cocoa_bean_resource_type: CocoaBeanResource
@export var has_infinite_beans = false

@export_group("Interact Messages")
@export var deposit_bean_msg = "Deposit Bean"
@export var take_bean_msg = "Take Bean"

enum StorageBinState {NONE, WAITING, READY_TO_INTERACT, TAKE_BEAN, DEPOSIT_BEAN}

var _bean_ctr = 0
var _has_beans = false
var _curr_player_is_leaving = false
var _curr_player: Player
var _curr_state = StorageBinState.NONE


func _ready():
	_determine_state()


func _on_area_2d_body_entered(body):
	_curr_player = body as Player
	_determine_state()


func _on_area_2d_body_exited(body):
	_curr_player_is_leaving = true
	_determine_state()
	_curr_player = null


func _on_deposit_bean_interact(player: Player):
	if _curr_player and _curr_player.get_selected_bean() == cocoa_bean_resource_type:
		var taken_bean = _curr_player.take_bean()
		if taken_bean:
			_bean_ctr += 1
			print("'%s' deposited. " % taken_bean.get_display_name())
		_determine_state()
	else:
		printerr("'%s' NOT deposited. Expected: %s" % [_curr_player.get_selected_bean().get_display_name(), cocoa_bean_resource_type.get_display_name()])


func _on_take_bean_interact(player: Player):
	if _curr_player:
		_curr_player.give_bean(cocoa_bean_resource_type)
		_determine_state()
		print("'%s' taken." % cocoa_bean_resource_type.get_display_name())
	else:
		printerr("'%s' NOT taken." % cocoa_bean_resource_type.get_display_name())


func _determine_state():
	var new_state = _curr_state
	
	match _curr_state:
		StorageBinState.NONE:
			new_state = StorageBinState.WAITING
		StorageBinState.WAITING:
			if _curr_player:
				new_state = StorageBinState.READY_TO_INTERACT
		StorageBinState.READY_TO_INTERACT:
			if not _curr_player or _curr_player_is_leaving:
				new_state = StorageBinState.WAITING
	
	_set_state(new_state)


func _set_state(new_state: StorageBinState):
	match _curr_state:
		StorageBinState.WAITING:
			pass
		StorageBinState.READY_TO_INTERACT:
			if _curr_player:
				_curr_player.interacted.disconnect(_on_take_bean_interact)
				_curr_player.interacted_with_secondary.disconnect(_on_deposit_bean_interact)
				_curr_player.stop_notify_interactable()
	
	_curr_state = new_state
	
	match _curr_state:
		StorageBinState.WAITING:
			_curr_player_is_leaving = false
			if _curr_player:
				if _curr_player.interacted.is_connected(_on_take_bean_interact):
					_curr_player.interacted.disconnect(_on_take_bean_interact)
				if _curr_player.interacted_with_secondary.is_connected(_on_deposit_bean_interact):
					_curr_player.interacted_with_secondary.disconnect(_on_deposit_bean_interact)
		StorageBinState.READY_TO_INTERACT:
			if _curr_player:
				_curr_player.interacted.connect(_on_take_bean_interact)
				_curr_player.interacted_with_secondary.connect(_on_deposit_bean_interact)
				_curr_player.start_notify_interactable(take_bean_msg, deposit_bean_msg)
