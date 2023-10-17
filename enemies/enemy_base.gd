extends CharacterBody2D

@export var speed = 80.0
@export var jump_velocity = -400.0

@onready var idle_walk_timer : Timer = $IdleWalkTimer
@onready var skin : Sprite2D = $Skin
@onready var ground_detector_left = $GroundDetectorLeft
@onready var ground_detector_right = $GroundDetectorRight

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_left : bool:
	get: return skin.flip_h
var facing_right : bool:
	get: return not skin.flip_h
var player : Player = null

enum States {
	IDLE,
	WALK,
	NOTICE,
	ATTACK,
	JUMP,
	FALL,
	DEATH
}
var current_state = States.IDLE


func _ready():
	enter_idle()


func _physics_process(delta):
	match current_state:
		States.IDLE:
			idle_state()
		States.WALK:
			walk_state()
		States.NOTICE:
			notice_state()
		States.ATTACK:
			attack_state()
		States.JUMP:
			jump_state()
		States.FALL:
			fall_state()
		States.DEATH:
			death_state()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()



############################### STATE MACHINE ###############################


func enter_idle():
	current_state = States.IDLE
	idle_walk_timer.start(randi_range(1, 2))
	velocity.x = 0

func idle_state():
	if idle_walk_timer.is_stopped():
		skin.flip_h = not skin.flip_h
		enter_walk()
	else:
		pass


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_walk():
	current_state = States.WALK
	idle_walk_timer.start(randi_range(3, 6))
	velocity.x = speed if facing_right else -speed

func walk_state():
	if idle_walk_timer.is_stopped():
		enter_idle()
	else:
		if facing_left and not ground_detector_left.get_collider():
			enter_idle()
		if facing_right and not ground_detector_right.get_collider():
			enter_idle()


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_notice():
	current_state = States.NOTICE
	$TemporaryExclamationMark.visible = true

func notice_state():
	pass


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_attack():
	current_state = States.ATTACK

func attack_state():
	velocity.x = (player.global_position - global_position).normalized().x * speed
	skin.flip_h = true if velocity.x<0 else false


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_jump():
	current_state = States.JUMP

func jump_state():
	pass


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_fall():
	current_state = States.FALL

func fall_state():
	pass


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_death():
	current_state = States.DEATH

func death_state():
	pass


################################## SIGNALS ##################################


func _on_notice_player_area_body_entered(body):
	if current_state == States.IDLE or current_state == States.WALK:
		enter_notice()


func _on_attack_area_body_entered(body):
	player = body as Player
	enter_attack()


func _on_notice_player_area_body_exited(body):
	if current_state == States.NOTICE or current_state == States.ATTACK:
		enter_idle()
		$TemporaryExclamationMark.visible = false
