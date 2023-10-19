extends CharacterBody2D

class_name Player

signal interacted(player: Player)

@export var speed = 150
@export var jump_velocity = -400.0

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $CollisionShape2D/Sprite2D
@onready var _label_text = $InteractableDialogue/PanelContainer/Label_Text
@onready var _interactable_dialogue_control = $InteractableDialogue
@onready var _message_dialogue_control = $MessageDialogue
@onready var _label_message_text = $MessageDialogue/PanelContainer/Label_Text

const _interactable_message_format = "[%s] %s"

var bean_ctr = 0
var has_bean = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _interact_action_event = InputMap.action_get_events("interact")[0]
var _interact_action_key = OS.get_keycode_string(_interact_action_event.physical_keycode)


func _ready():
	_animation_player.play("Idle_Blinking")
	stop_notify_interactable()
	stop_message()


func is_in_combat_zone():
	# TODO Determine when player is in combat zone. This is probably the player
	#      portaling to another world.
	return false


func _handle_input_combat_zone(delta):
	# TODO: Implement. This is a stub to implement combat zone movement.
	pass


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


func give_bean(beanResourceType):
	bean_ctr += 1
	has_bean = bean_ctr > 0


func take_bean():
	bean_ctr -= 1
	bean_ctr = max(0, bean_ctr)
	has_bean = bean_ctr > 0
	return CocoaBeanResource.new("Test Bean")


func start_notify_interactable(interact_msg = ""):
	stop_message()
	
	_interactable_dialogue_control.set_visible(true)
	_label_text.set_text(_interactable_message_format % [_interact_action_key, interact_msg])


func stop_notify_interactable():
	_interactable_dialogue_control.set_visible(false)
	_label_text.set_text("")


func start_message(warning_msg = ""):
	stop_notify_interactable()
	
	_label_message_text.set_text(warning_msg)
	_message_dialogue_control.set_visible(true)


func stop_message():
	_message_dialogue_control.set_visible(false)
	_label_message_text.set_text("")
