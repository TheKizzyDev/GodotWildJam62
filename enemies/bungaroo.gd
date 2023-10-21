extends "res://enemies/enemy_base.gd"


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
	super.attack()
