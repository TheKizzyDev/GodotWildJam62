extends CharacterBody2D

class_name Player

@export var speed = 300.0
@export var jump_velocity = -400.0

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $CollisionShape2D/Sprite2D
@onready var _label_key = $ControlDialogue/Panel/MarginContainer/GridContainer/Label_Key
@onready var _label_message = $ControlDialogue/Panel/MarginContainer/GridContainer/Label_Message
@onready var _control_dialogue = $ControlDialogue

var has_bean = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _interact_action_event = InputMap.action_get_events("interact")[0]
var _interact_action_key = OS.get_keycode_string(_interact_action_event.physical_keycode)

func _ready():
	_animation_player.play("Idle_Blinking")
	_control_dialogue.set_visible(false)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if abs(velocity.x) > 0:
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

func start_interact(interact_msg = ""):
	_control_dialogue.set_visible(true)
	_label_key.set_text("'" + _interact_action_key + "'")
	_label_message.set_text(interact_msg)
	
func stop_interact():
	_control_dialogue.set_visible(false)
	_label_key.set_text("")
	_label_message.set_text("")

