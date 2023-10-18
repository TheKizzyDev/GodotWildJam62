extends Area2D
class_name Hitbox

@export var damage = 1


func enable(_set_enable: bool = true):
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", not _set_enable)


func disable():
	enable(false)


################################## SIGNALS ##################################

func _on_area_entered(area):
	if area is Hurtbox:
		print("attacking ", area.owner.name)
		area.take_damage(damage)
