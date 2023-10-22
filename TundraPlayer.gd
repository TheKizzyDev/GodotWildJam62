extends "res://scripts/player.gd"

@export var level_key: Global.LevelKeys
@export var attack_event: EventAsset
@export var death_event: EventAsset
@export var hurt_event: EventAsset
@export var grass_walking_event: EventAsset
@export var grass_jumping_event: EventAsset
@export var grass_landing_event: EventAsset
@export var snow_walking_event: EventAsset
@export var snow_jumping_event: EventAsset
@export var snow_landing_event: EventAsset

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite

var walking_event: EventAsset
var jumping_event: EventAsset
var landing_event: EventAsset

var is_attacking = false
var is_facing_left : bool:
	get: return animated_sprite.flip_h
var is_facing_right : bool:
	get: return not animated_sprite.flip_h


func _ready():
	super()
	walking_event = grass_walking_event if level_key == Global.LevelKeys.FOREST else snow_walking_event
	jumping_event = grass_jumping_event if level_key == Global.LevelKeys.FOREST else snow_jumping_event
	landing_event = grass_landing_event if level_key == Global.LevelKeys.FOREST else snow_landing_event
	%AnimatedSprite.frame_changed.connect(_on_frame_changed)


func _on_frame_changed():
	match %AnimatedSprite.animation:
		"attack":
			match %AnimatedSprite.frame:
				0:
					FMODRuntime.play_one_shot(attack_event, self)
		"die":
			match %AnimatedSprite.frame:
				1:
					FMODRuntime.play_one_shot(death_event, self)
		"idle":
			pass
		"jump":
			match %AnimatedSprite.frame:
				0:
					FMODRuntime.play_one_shot(jumping_event, self)
				1:
					FMODRuntime.play_one_shot(landing_event, self)
		"walk":
			match %AnimatedSprite.frame:
				0, 2:
					FMODRuntime.play_one_shot(walking_event, self)


func _on_jump():
	FMODRuntime.play_one_shot(jumping_event, self)


func _on_land():
	FMODRuntime.play_one_shot(landing_event, self)


func _handle_input_combat_zone(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = jump_velocity
		animated_sprite.play("jump")
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		Callable(attack).call()
	
	if not is_attacking:
		var horizontal_direction = Input.get_axis("move_left", "move_right")
		if horizontal_direction:
			velocity.x = horizontal_direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		if abs(velocity.x) > 0:
			animated_sprite.flip_h = (sign(velocity.x) <= 0)
			if velocity.y == 0:
				animated_sprite.play("walk")
		else:
			if velocity.y == 0:
				animated_sprite.play("idle")
		
	if not is_on_floor() and not is_attacking:
		animated_sprite.play("jump")
		if velocity.y > 0:
			animated_sprite.frame = 1
		else:
			animated_sprite.frame = 0
	move_and_slide()
	

func _on_step():
	FMODRuntime.play_one_shot(walking_event, self)


func _on_animated_sprite_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false


func _on_attack():
	FMODRuntime.play_one_shot(attack_event, self)


func attack():
	is_attacking = true
	velocity.x = 0
	animated_sprite.play("attack")
	hitbox.position.x = -34 if is_facing_left else 3
	await get_tree().create_timer(.22).timeout
	hitbox.enable()
	await get_tree().create_timer(.6).timeout
	hitbox.disable()


func _on_death():
	FMODRuntime.play_one_shot(death_event, self)


func _on_hurtbox_died():
	set_physics_process(false)
	set_collision_layer_value(1, false)
	hitbox.disable()
	hurtbox.disable()
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	visible = false
	await get_tree().create_timer(1).timeout
	Global.goto_level_key(Global.LevelKeys.HOME)


func _on_hurtbox_health_changed():
	FMODRuntime.play_one_shot(hurt_event, self)
	await get_tree().create_timer(.1).timeout
	$HUD.decrease_health()
