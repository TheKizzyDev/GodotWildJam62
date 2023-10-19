extends RigidBody2D
class_name Cocoabean

signal collected



var player : Player = null


func _ready():
	gravity_scale = 0
	$PlayerDetection.monitoring = false


func _process(delta):
	if player:
		global_position += global_position.direction_to(player.global_position) * 2


func _on_body_entered(body):
	player = body
	$ConsumeTimer.start()


func _on_consume_timer_timeout():
	emit_signal("collected")
	queue_free()


func enable():
	gravity_scale = 1
	apply_force(Vector2(1000 if randi_range(0,1) > 0 else -1000,0))
	$EnableTimer.start()


func _on_enable_timer_timeout():
	$PlayerDetection.monitoring = true
