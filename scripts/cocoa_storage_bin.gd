extends Node2D

@export var beanType: Resource
@onready var _label = $Sprite2D/DebugLabel

func _ready():
	if beanType and "debugDisplayName" in beanType:
		_label.set_text(beanType.debugDisplayName)

func _on_area_2d_body_entered(body):
	if body:
		print("Body Entered: " + body.name)
	else:
		print("Empty Body")
