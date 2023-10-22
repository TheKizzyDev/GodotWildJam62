extends Node2D


var _curr_player: Player


func _on_strummed(player: Player):
	print("Played")


func _on_area_2d_body_entered(body):
	_curr_player = body as Player
	if _curr_player:
		_curr_player.interacted.connect(_on_strummed)
		_curr_player.start_notify_interactable("Strum")


func _on_area_2d_body_exited(body):
	if _curr_player:
		_curr_player.interacted.disconnect(_on_strummed)
		_curr_player.stop_notify_interactable()
	_curr_player = null
