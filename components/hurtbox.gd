extends Area2D
class_name Hurtbox

signal health_changed
signal died

@export var max_health = 3

var health = max_health:
	set(_health):
		if health != _health:
			emit_signal("health_changed")
		health = _health
		if health <= 0:
			emit_signal("died")


func _ready():
	health = max_health


func take_damage(_damage : int = 1):
	health -= _damage


func enable(_set_enable: bool = true):
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", not _set_enable)


func disable():
	enable(false)


