extends Resource

class_name CocoaBeanResource

@export var display_name = "None": get = get_display_name

func get_display_name():
	return display_name

func _init(new_display_name = "None"):
	display_name = new_display_name
