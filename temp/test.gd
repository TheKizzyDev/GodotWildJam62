extends Node


func x():
	await get_tree().create_timer(.1).timeout
	print("sss")


func _ready():
	print("1")
	Callable(x).call()
	print("2")
