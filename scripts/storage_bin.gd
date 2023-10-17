extends Node2D

class_name StorageBin

@export_group("Config")
@export var cocoa_bean_resource_type: CocoaBeanResource
@export var has_infinite_beans = false

@export_group("Interact Messages")
@export var deposit_bean_msg = "Deposit Bean"
@export var take_bean_msg = "Take Bean"

@onready var _label = $Sprite2D/DebugLabel

var _beanCtr = 0
var _hasBeans = false


func _ready():
	if cocoa_bean_resource_type and "debugDisplayName" in cocoa_bean_resource_type:
		_label.set_text(cocoa_bean_resource_type.debugDisplayName)

func _on_area_2d_body_entered(body):
	var player := body as Player
	if player:
		# TODO: Make sure the player can't lose a bean, if the current store hasn't a different bean type.
		if player.has_bean:
			player.start_interact(deposit_bean_msg)
		elif _hasBeans or has_infinite_beans:
			player.start_interact(take_bean_msg)
		else:
			print("There are no beans to do anything with...")
	else:
		print("Not the player...")


func _on_area_2d_body_exited(body):
	var player := body as Player
	if player:
		player.stop_interact()
	else:
		print("Not the player...")
