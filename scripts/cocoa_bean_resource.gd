extends Resource

class_name CocoaBeanResource

enum Type { Normal, Frozen }

@export var display_name = "None": get = get_display_name
@export var type: Type
@export var bean_icon: Texture2D
@export var drink_icon: Texture2D

func get_display_name():
	return display_name

func _init(new_display_name = "None"):
	display_name = new_display_name
