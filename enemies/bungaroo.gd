extends "res://enemies/enemy_base.gd"

var is_facing_left : bool:
	get: return skin.flip_h
var is_facing_right : bool:
	get: return not skin.flip_h

func enter_walk():
	super.enter_walk()


func walk_state():
	super.walk_state()
	if velocity.y > 0:
		skin.frame = 0
	else:
		skin.frame = 1
	if is_on_floor():
		velocity.y = -160


func enter_chase():
	super.enter_chase()


func chase_state():
	super.chase_state()
	if not is_attacking:
		if velocity.y > 0:
			skin.frame = 1
		else:
			skin.frame = 0
			
		if is_on_floor():
			velocity.y = -160

func attack():
	hitbox.position.x = -20 if is_facing_left else 3
	is_attacking = true
	skin.play("attack")
	velocity.x = 0
	#print("OPEN")
	Callable(set_interrupt.bind(.4)).call()
	await interrupt
	hitbox.enable()
	if is_instance_valid($AttackPlayerArea):
		$AttackPlayerArea.set_deferred("monitoring", false)
	else:
		return
	
	#print("OPEN2")
	#await skin.animation_finished
	Callable(set_interrupt.bind(.4)).call()
	await interrupt
	if is_instance_valid($AttackPlayerArea):
		$AttackPlayerArea.set_deferred("monitoring", true)
	else:
		return
	hitbox.disable()
	#print("CLOSING")
	skin.play("walk")
	is_attacking = false


