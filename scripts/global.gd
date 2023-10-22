extends Node

var current_scene = null

enum LevelKeys { HOME, TUNDRA, FOREST, ROOM }

var last_teleport_origin: Vector2

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_level_key(level_key: LevelKeys):
	match level_key:
		LevelKeys.HOME, LevelKeys.ROOM:
			goto_scene("res://main.tscn")
		LevelKeys.TUNDRA:
			goto_scene("res://levels/tundra_level_1.tscn")
		LevelKeys.FOREST:
			goto_scene("res://levels/forest_level_1.tscn")


func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func is_combat_scene():
	var curr_level = current_scene as Level
	if curr_level:
		return curr_level.combat_zone
	
	return false


func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
