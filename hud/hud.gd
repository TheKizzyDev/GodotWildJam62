extends CanvasLayer

# quick and dirty

@export var current_health = 5


func _ready():
	pass


func decrease_health():
	find_child(str(current_health)).get_child(0).play("shrink")
	current_health -= 1
	if current_health <= 0:
		return
	find_child(str(current_health)).get_child(0).play("glow")
