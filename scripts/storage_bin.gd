extends Node2D

class_name StorageBin

@export_group("Config")
@export var cocoa_bean_resource_type: CocoaBeanResource
@export var has_infinite_beans = false

@export_group("Interact Messages")
@export var deposit_bean_msg = "Deposit Bean"
@export var take_bean_msg = "Take Bean"

@onready var _label = $Sprite2D/DebugLabel

var _bean_ctr = 0
var _has_beans = false


func _ready():
	if cocoa_bean_resource_type and "debugDisplayName" in cocoa_bean_resource_type:
		_label.set_text(cocoa_bean_resource_type.debugDisplayName)


func _on_area_2d_body_entered(body):
	var player := body as Player
	if player:
		# TODO: Make sure the player can't lose a bean, if the current store hasn't a different bean type.
		if player.has_bean:
			player.start_notify_interactable(deposit_bean_msg)
			player.interacted.connect(_on_deposit_bean_interact)
		elif _has_beans or has_infinite_beans:
			player.start_notify_interactable(take_bean_msg)
			player.interacted.connect(_on_take_bean_interact)
		else:
			print("There are no beans to do anything with...")
	else:
		print("Not the player...")

func _on_deposit_bean_interact():
	print("Bean deposited...")


func _on_take_bean_interact():
	print("Bean taken...")


func _on_area_2d_body_exited(body):
	var player := body as Player
	if player:
		player.stop_notify_interactable()
		player.interacted.disconnect(_on_deposit_bean_interact)
		player.interacted.disconnect(_on_take_bean_interact)
	else:
		print("Not the player...")
