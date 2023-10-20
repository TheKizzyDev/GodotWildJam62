class_name teleporter

extends Node2D

@onready var _global_vars = get_node("/root/Global") as Global

@export var level_key: Global.LevelKeys

var _curr_player: Player


func _on_teleport_overlap_body_entered(body):
	_curr_player = body as Player
	if _curr_player:
		_curr_player.start_notify_interactable("Teleport")
		_curr_player.interacted.connect(_on_teleport_interaction)


func _on_teleport_overlap_body_exited(body):
	if _curr_player:
		_curr_player.stop_notify_interactable()
		_curr_player.interacted.disconnect(_on_teleport_interaction)
	_curr_player = null


func _on_teleport_interaction(player: Player):
	_global_vars.goto_level_key(level_key)
