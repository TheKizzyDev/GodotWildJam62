extends Node2D

@export_file("*.tscn") var Cocoabean
@export_group("Cocoa Spawn")
@export var min_cocoas = 1
@export var max_cocoas = 2
@export var bean_type: CocoaBeanResource.Type

@onready var skin = $Skin

var cocoa_beans = []


func _ready():
	var cocoa_count = randi_range(min_cocoas, max_cocoas)
	var locations = $CocoasLocation.get_children()
	locations.shuffle()
	for i in range(cocoa_count):
		var cocoa = load(Cocoabean).instantiate()
		cocoa.bean_type = bean_type
		#cocoa.global_position = locations[i].global_position
		locations[i].add_child(cocoa)
		cocoa_beans.append(cocoa)


func _on_hurtbox_health_changed():
	if not cocoa_beans.is_empty():
		cocoa_beans.pop_front().enable()


func _on_detect_player_body_entered(body):
	skin.frame = 1


func _on_detect_player_body_exited(body):
	skin.frame = 0
