extends CharacterBody2D

class_name Player

signal interacted(player: Player)
signal interacted_with_secondary(player: Player)

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

var bean_ctr = 0
var has_bean = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _interact_action_event = InputMap.action_get_events("interact")[0]
var _interact_action_key = OS.get_keycode_string(_interact_action_event.physical_keycode)
var _interact_secondary_action_event = InputMap.action_get_events("interact_secondary")[0]
var _interact_secondary_action_key = OS.get_keycode_string(_interact_secondary_action_event.physical_keycode)
var is_facing_left : bool:
	get: return _sprite.flip_h
var is_facing_right : bool:
	get: return not _sprite.flip_h
var _bean_inventory: Dictionary
var _curr_selected_bean_index := 0
var _curr_bean_key: CocoaBeanResource

func _ready():
	hitbox.disable()
	_animation_player.play("Idle_Blinking")
	stop_notify_interactable()
	stop_message()
	
	for bean in beans:
		_bean_inventory[bean] = 0
	
	_curr_bean_key = beans[_curr_selected_bean_index]


func is_in_combat_zone():
	# TODO Determine when player is in combat zone. This is probably the player
	#      portaling to another world.
	return true


func _handle_input_combat_zone(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("attack"):
		hitbox.scale.x = -1 if is_facing_left else 1
		hitbox.enable()
		await get_tree().create_timer(.1).timeout
		hitbox.disable()
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if horizontal_direction:
		velocity.x = horizontal_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if abs(velocity.x) > 0:
		_sprite.flip_h = (sign(velocity.x) <= 0)
		_animation_player.play("Walking")
	else:
		_animation_player.play("Idle_Blinking")
		
	move_and_slide()


func _handle_cocoa_shop_input(delta):
#	if not is_on_floor():
#		velocity.y += gravity * delta
		
	# TODO: Remove, if confident jump is not needed in the cocoa shop.
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		velocity.y = jump_velocity

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


func get_selected_bean():
	return _curr_bean_key


func give_bean(beanResourceType: CocoaBeanResource):
	bean_ctr += 1
	has_bean = bean_ctr > 0
	if _bean_inventory.has(beanResourceType):
		_bean_inventory[beanResourceType] += 1
	print("Bean Inventory: %s" % str(_bean_inventory))


func take_bean():
	if _curr_bean_key:
		bean_ctr -= 1
		bean_ctr = max(0, bean_ctr)
		has_bean = bean_ctr > 0
		_bean_inventory[_curr_bean_key] = max(0, _bean_inventory[_curr_bean_key] - 1)
		print("Bean Inventory: %s" % str(_bean_inventory))
		return _curr_bean_key
	print("Bean Inventory: %s" % str(_bean_inventory))


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
