extends Node2D

class_name StorageBin

@export_group("Config")
@export var cocoa_bean_resource_type: CocoaBeanResource
@export var has_infinite_beans = false

@export_group("Interact Messages")
@export var deposit_bean_msg = "Deposit Bean"
@export var take_bean_msg = "Take Bean"

@onready var _label = $Sprite2D/DebugLabel

enum InteractableState {NONE, TAKE_BEAN, DEPOSIT_BEAN}

var _bean_ctr = 0
var _has_beans = false
var _curr_player: Player
var _curr_interactable_state = InteractableState.NONE


func _ready():
	if cocoa_bean_resource_type and "debugDisplayName" in cocoa_bean_resource_type:
		_label.set_text(cocoa_bean_resource_type.debugDisplayName)


func _on_area_2d_body_entered(body):
	_curr_player = body as Player
	_determine_notify_interactable_state()


func _on_area_2d_body_exited(body):
	_curr_player = null
	_determine_notify_interactable_state()


func _on_deposit_bean_interact(player: Player):
	if _curr_player:
		_curr_player.take_bean()
		_determine_notify_interactable_state()
		print("Bean deposited...")
	else:
		print("Bean could not be deposited...")


func _on_take_bean_interact(player: Player):
	if _curr_player:
		_curr_player.give_bean(cocoa_bean_resource_type)
		_determine_notify_interactable_state()
		print("Bean taken...")
	else:
		print("Bean could not be taken...")


func _determine_notify_interactable_state():
	var _new_interactable_state = InteractableState.NONE
	
	if _curr_player:	
		if _curr_player.has_bean:
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
	elif _curr_interactable_state == InteractableState.DEPOSIT_BEAN:
		if _curr_player:
			_curr_player.interacted.disconnect(_on_deposit_bean_interact)
	
	_curr_interactable_state = new_interactable_state
	
	if _curr_interactable_state == InteractableState.NONE:
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
