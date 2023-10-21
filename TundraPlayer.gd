extends "res://scripts/player.gd"

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite

var is_attacking = false
var is_facing_left : bool:
	get: return animated_sprite.flip_h
var is_facing_right : bool:
	get: return not animated_sprite.flip_h


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


func _on_animated_sprite_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false


func attack():
	is_attacking = true
	velocity.x = 0
	animated_sprite.play("attack")
	hitbox.position.x = -34 if is_facing_left else 3
	await get_tree().create_timer(.22).timeout
	hitbox.enable()
	await get_tree().create_timer(.6).timeout
	hitbox.disable()


func _on_hurtbox_died():
	set_physics_process(false)
	set_collision_layer_value(0, false)
	hitbox.disable()
	hurtbox.disable()
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	visible = false
	await get_tree().create_timer(1).timeout
	Global.goto_level_key(Global.LevelKeys.HOME)
