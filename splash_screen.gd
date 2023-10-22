extends Control

@export var speed = 400
@export var adjust_target_offset = 200
@export var transit_wait = 1.5

@onready var _play_button = $CanvasLayer2/AspectRatioContainer/TextureRect/PlayButton
@onready var _cont = $CanvasLayer2/AspectRatioContainer as AspectRatioContainer
@onready var _image = $CanvasLayer2/AspectRatioContainer/TextureRect as TextureRect
@onready var _global_vars = get_node("/root/Global") as Global
var _opened = false
var _scrolled = false
var _default_pos = Vector2.ZERO
var _target_offset = 0

func _ready():
	_default_pos = _cont.position
	_target_offset = -_image.size.y - adjust_target_offset

func _on_play_button_mouse_entered():
	_play_button.text = "OPEN" 


func _on_play_button_mouse_exited():
	if not _opened:
		_play_button.text = "CLOSED"


func _on_play_button_pressed():
	_opened = true


func _process(delta):
	if _opened and not _scrolled:
		var new_y = move_toward(_cont.offset_top, _target_offset, delta * speed)
#		_play_button.set_position(Vector2(new_y)
		_cont.set_offset(Side.SIDE_TOP, new_y)
		_scrolled = _cont.offset_top == _target_offset
	
	if _scrolled:
		await get_tree().create_timer(transit_wait).timeout
		_global_vars.goto_level_key(Global.LevelKeys.ROOM)
