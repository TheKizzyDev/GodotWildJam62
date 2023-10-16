extends CharacterBody2D

@export var speed = 300.0
@export var jumpVelocity = -400.0

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $CollisionShape2D/Sprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	_animation_player.play("Idle_Blinking")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

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
