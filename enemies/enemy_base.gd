extends CharacterBody2D

signal interrupt

@export var walking_event: EventAsset
@export var jumping_event: EventAsset
@export var landing_event: EventAsset
@export var idling_event: EventAsset
@export var alert_event: EventAsset
@export var attack_event: EventAsset
@export var death_event: EventAsset
@export var hurt_event: EventAsset

@export var speed = 80.0
@export var jump_velocity = -400.
@export var min_attenuation_radius = 300.0

@onready var idle_walk_timer : Timer = $IdleWalkTimer
@onready var skin : AnimatedSprite2D = $Skin
@onready var ground_detector_left = $GroundDetectorLeft
@onready var ground_detector_right = $GroundDetectorRight
@onready var hitbox = $Hitbox
@onready var hurtbox = $Hurtbox
@onready var notice_player_timer = $NoticePlayerArea/NoticePlayerTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_left : bool:
	get: return skin.flip_h
var facing_right : bool:
	get: return not skin.flip_h
var player : Player = null
var is_attacking = false

var _player_from_query: Player = null

enum States {
	IDLE = 0,
	WALK,
	NOTICE,
	CHASE,
	JUMP,
	FALL,
	DEATH
}
var current_state = States.IDLE


var _rng: RandomNumberGenerator


func _ready():
	_player_from_query = get_tree().get_first_node_in_group("Player")
	_rng = RandomNumberGenerator.new()
	%Skin.frame_changed.connect(_on_skin_frame_changed)
	enter_idle()
	hitbox.disable()


func _on_skin_frame_changed():
	match %Skin.animation:
		"attack":
			match %Skin.frame:
				7:
					FMODRuntime.play_one_shot_attached(attack_event, self)
		"die":
			match %Skin.frame:
				4:
					FMODRuntime.play_one_shot_attached(death_event, self)
		"idle":
			if not _player_from_query or position.distance_to(_player_from_query.position) > min_attenuation_radius:
				return
			
			match %Skin.frame:
				1:
#					_rng.randomize()
#					await get_tree().create_timer(_rng.randf_range(1.0, 10.0)).timeout
					FMODRuntime.play_one_shot_attached(idling_event, self)
		"walk":
			if not _player_from_query or position.distance_to(_player_from_query.position) > min_attenuation_radius:
				return

			match %Skin.frame:
				0, 2:
					FMODRuntime.play_one_shot_attached(walking_event, self)


func _physics_process(delta):
	match current_state:
		States.IDLE:
			idle_state()
		States.WALK:
			walk_state()
		States.NOTICE:
			notice_state()
		States.CHASE:
			chase_state()
		States.JUMP:
			jump_state()
		States.FALL:
			fall_state()
		States.DEATH:
			death_state()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()


func set_interrupt(_time):
	await get_tree().create_timer(_time).timeout
	emit_signal("interrupt")


func attack():
	is_attacking = true
	skin.play("attack")
	velocity.x = 0
	#print("OPEN")
	Callable(set_interrupt.bind(.7)).call()
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


############################### STATE MACHINE ###############################


func enter_idle():
	skin.play("idle")
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
	skin.play("walk")
	current_state = States.WALK
	idle_walk_timer.start(randi_range(3, 6))
	velocity.x = speed if facing_right else -speed

func walk_state():
	if idle_walk_timer.is_stopped():
		enter_idle()
	else:
		if facing_left and not ground_detector_left.get_collider():
			enter_idle()
		elif facing_right and not ground_detector_right.get_collider():
			enter_idle()
		elif facing_right and not $BorderRightArea.get_overlapping_bodies().is_empty():
			enter_idle()
		elif facing_left and not $BorderLeftArea.get_overlapping_bodies().is_empty():
			enter_idle()

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_notice():
	current_state = States.NOTICE
	$TemporaryExclamationMark.visible = true
	FMODRuntime.play_one_shot(alert_event, self)
	skin.play("idle")
	velocity.x = 0
	notice_player_timer.start()

func notice_state():
	if notice_player_timer.is_stopped():
		enter_walk()
		$TemporaryExclamationMark.visible = false


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
func enter_chase():
	current_state = States.CHASE
	$TemporaryExclamationMark.visible = false
	skin.play("walk")

func chase_state():
	if not is_attacking:
		velocity.x = (player.global_position - global_position).normalized().x * speed
		skin.flip_h = true if velocity.x<0 else false
		if facing_right and not $BorderRightArea.get_overlapping_bodies().is_empty():
			velocity.y = -200
		elif facing_left and not $BorderLeftArea.get_overlapping_bodies().is_empty():
			velocity.y = -200


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
	print(name, " is dying")
	velocity = Vector2.ZERO
	remove_child($AttackPlayerArea)
	remove_child($ChasePlayerArea)
	remove_child($NoticePlayerArea)
	hitbox.disable()
	hurtbox.disable()
	current_state = States.DEATH
	if is_attacking:
		emit_signal("interrupt")
		await get_tree().create_timer(.1).timeout
		emit_signal("interrupt")
	await get_tree().create_timer(.1).timeout
	skin.play("die")
	await skin.animation_finished
	queue_free()

func death_state():
	pass


################################## SIGNALS ##################################


func _on_notice_player_area_body_entered(body):
	if is_attacking: return
	if current_state == States.IDLE or current_state == States.WALK:
		skin.flip_h = true if body.global_position.x < global_position.x else false
		enter_notice()


func _on_notice_player_area_body_exited(body):
	if is_attacking: return
	if current_state == States.NOTICE or current_state == States.CHASE:
		enter_idle()
		$TemporaryExclamationMark.visible = false


func _on_hurtbox_died():
	enter_death()


func _on_attack_player_area_body_entered(body):
	attack()


func _on_chase_player_area_body_entered(body):
	if is_attacking: return
	player = body as Player
	enter_chase()
