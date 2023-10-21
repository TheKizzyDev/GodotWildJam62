extends CharacterBody2D

class_name Player

signal interacted(player: Player)
signal interacted_with_secondary(player: Player)
signal cocoa_bean_selected(cocoa_bean_type: CocoaBeanResource.Type)

@export_group("Config")
@export var speed = 150
@export var jump_velocity = -400.0
@export var beans: Array

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $CollisionShape2D/Sprite2D
@onready var _label_text = $InteractableDialogue/PanelContainer/Label_Text as Label
@onready var _interactable_dialogue_control = $InteractableDialogue
@onready var _message_dialogue_control = $MessageDialogue
@onready var _panelcontainer_message = $MessageDialogue/PanelContainer as PanelContainer
@onready var _label_message_text = $MessageDialogue/PanelContainer/Label_Text as Label

const _interactable_message_format = "[%s] %s"
const _interactable_message_with_secondary_format = "[%s] %s\n[%s] %s"
@onready var hitbox = $Hitbox as Hitbox
@onready var hurtbox = $Hurtbox as Hurtbox
@onready var _player_vars = get_node("/root/GlobalPlayerVariables") as GlobalPlayerVariables
@onready var _global_vars = get_node("/root/Global") as Global

var bean_ctr = 0
var has_bean = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _interact_action_event = InputMap.action_get_events("interact")[0]
var _interact_action_key = OS.get_keycode_string(_interact_action_event.physical_keycode)
var _interact_secondary_action_event = InputMap.action_get_events("interact_secondary")[0]
var _interact_secondary_action_key = OS.get_keycode_string(_interact_secondary_action_event.physical_keycode)
var _bean_inventory: Dictionary
var _curr_selected_bean_index := 0
var _curr_bean_key: CocoaBeanResource


func _exit_tree():
	print("Saving bean inventory...")
	_player_vars.bean_inventory = _bean_inventory
	if not _player_vars.has_bean_inventory_initialized:
		_player_vars.has_bean_inventory_initialized = true


func _ready():
	hitbox.disable()
	_animation_player.play("Idle_Blinking")
	stop_notify_interactable()
	stop_message()
	
	if _player_vars.has_bean_inventory_initialized:
		print("Loading bean inventory...")
		_bean_inventory = _player_vars.bean_inventory
	else:
		print("Initializing bean inventory...")
		for bean in beans:
			_bean_inventory[bean] = 0
	
	_curr_bean_key = beans[_curr_selected_bean_index]


func is_in_combat_zone():
	return _global_vars.is_combat_scene()


func _handle_input_combat_zone(delta):
	pass


func _find_bean(bean_type: CocoaBeanResource.Type):
	for bean in beans:
		var bean_typed = bean as CocoaBeanResource
		if bean_typed.type == bean_type:
			return bean_typed


func _handle_cocoa_shop_input(delta):
	if Input.is_action_just_pressed("frozen_cocoa_bean"):
		_select_bean(_find_bean(CocoaBeanResource.Type.Frozen))
		
	if Input.is_action_just_pressed("normal_cocoa_bean"):
		_select_bean(_find_bean(CocoaBeanResource.Type.Normal))
	
	var _up_down_direction = Input.get_axis("move_up", "move_down")
	if _up_down_direction:
		velocity.y = _up_down_direction * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	var _left_right_direction = Input.get_axis("move_left", "move_right")
	if _left_right_direction:
		velocity.x = _left_right_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
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


func _physics_process(delta):
	if is_in_combat_zone():
		_handle_input_combat_zone(delta)
	else:
		_handle_cocoa_shop_input(delta)


func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		interacted.emit(self)
	if event.is_action_pressed("interact_secondary"):
		interacted_with_secondary.emit(self)


func _select_bean(bean_resource: CocoaBeanResource):
	_curr_bean_key = bean_resource
	cocoa_bean_selected.emit(_curr_bean_key.type)


func get_selected_bean():
	return _curr_bean_key


func teleport_to(level_key: Global.LevelKeys):
	_player_vars.teleported = true
	_global_vars.goto_level_key(level_key)


func give_bean(beanResourceType: CocoaBeanResource):
	bean_ctr += 1
	has_bean = bean_ctr > 0
	for key in _bean_inventory:
		var bean = key as CocoaBeanResource
		if bean.type == beanResourceType.type:
			_bean_inventory[key] += 1
			_select_bean(beanResourceType)


func take_bean_with_selection(cocoa_bean_resource_type: CocoaBeanResource):
	if cocoa_bean_resource_type:
		_curr_bean_key = cocoa_bean_resource_type
		_select_bean(_curr_bean_key)
		return take_bean()


func take_bean():
	if _curr_bean_key:
		bean_ctr -= 1
		bean_ctr = max(0, bean_ctr)
		has_bean = bean_ctr > 0
		for key in _bean_inventory:
			var bean = key as CocoaBeanResource
			if bean.type == _curr_bean_key.type:
				var curr_bean_ctr = _bean_inventory[key]
				if curr_bean_ctr > 0:
					_bean_inventory[key] = max(0, curr_bean_ctr - 1)
					return _curr_bean_key


func start_notify_interactable(interact_msg = "", interact_secondary_msg = ""):
	stop_message()
	
	if not interact_msg.is_empty() and not interact_secondary_msg.is_empty():
		_label_text.set_text(_interactable_message_with_secondary_format % [_interact_action_key, interact_msg, _interact_secondary_action_key, interact_secondary_msg])
	elif not interact_msg.is_empty():
		_label_text.set_text(_interactable_message_format % [_interact_action_key, interact_msg])
	elif not interact_secondary_msg.is_empty():
		_label_text.set_text(_interactable_message_format % [_interact_secondary_action_key, interact_secondary_msg])
	else:
		return
	_interactable_dialogue_control.set_visible(true)


func stop_notify_interactable():
	_interactable_dialogue_control.set_visible(false)
	_label_text.set_text("")


func start_message(warning_msg = ""):
	stop_notify_interactable()
	
	var font = _label_message_text.label_settings.font
	var msg_size = font.get_string_size(warning_msg) as Vector2
	_panelcontainer_message.set_size(msg_size)
	_label_message_text.set_text(warning_msg)
	_message_dialogue_control.set_visible(true)


func stop_message():
	_message_dialogue_control.set_visible(false)
	_label_message_text.set_text("")

func _on_hurtbox_health_changed():
	$Hurtbox/AnimationPlayer.play("hurt")

