extends Level

@export var cocoa_bean_selection_color: Color
@export var cocoa_bean_selection_theme_override: StyleBoxFlat

@onready var _curr_player = $Player2D as Player
@onready var _ui = $UI
@onready var _ncb_bean_icon = $UI/MarginContainer/GridContainer/NormalCocoaBeanSlot/VBoxContainer/BeanIcon as TextureRect
@onready var _ncb_slot_panel = $UI/MarginContainer/GridContainer/NormalCocoaBeanSlot as PanelContainer
@onready var _ncb_ctr = $UI/MarginContainer/GridContainer/NormalCocoaBeanSlot/VBoxContainer/Counter as Label
@onready var _fcb_bean_icon = $UI/MarginContainer/GridContainer/NormalCocoaBeanSlot/VBoxContainer/BeanIcon as TextureRect
@onready var _fcb_slot_panel = $UI/MarginContainer/GridContainer/FrozenCocoaBeanSlot as PanelContainer
@onready var _fcb_ctr = $UI/MarginContainer/GridContainer/FrozenCocoaBeanSlot/VBoxContainer/Counter as Label
@onready var _player_vars = get_node("/root/GlobalPlayerVariables") as GlobalPlayerVariables
@onready var _global_vars = get_node("/root/Global") as Global

var _curr_cocoa_bean_panel: PanelContainer
var _cocoa_bean_default_theme_override: StyleBoxFlat

func _ready():
	_curr_cocoa_bean_panel = _ncb_slot_panel
	_cocoa_bean_default_theme_override = _ncb_slot_panel.get_theme_stylebox("panel") as StyleBoxFlat
	_on_cocoa_bean_selected(CocoaBeanResource.Type.Normal)
	_curr_player.cocoa_bean_selected.connect(_on_cocoa_bean_selected)
	
	for t in get_tree().get_nodes_in_group("teleporters"):
		var tele = t as Teleporter
		if tele:
			tele.teleported.connect(_on_teleported)
	
	if _player_vars.teleported:
		_player_vars.teleported = false
		_curr_player.set_position(_player_vars.last_teleport_origin)


func _on_teleported(teleporter: Teleporter, origin: Vector2):
	_player_vars.teleported = true
	_player_vars.last_teleport_origin = origin
	_global_vars.goto_level_key(teleporter.level_key)


func _on_cocoa_bean_selected(cocoa_bean_type: CocoaBeanResource.Type):
	_curr_cocoa_bean_panel.remove_theme_stylebox_override("panel")
	_curr_cocoa_bean_panel.add_theme_stylebox_override("panel", _cocoa_bean_default_theme_override)
	
	match cocoa_bean_type:
		CocoaBeanResource.Type.Normal:
			_curr_cocoa_bean_panel = _ncb_slot_panel
			print("Normal")
		CocoaBeanResource.Type.Frozen:
			_curr_cocoa_bean_panel = _fcb_slot_panel
			print("Frozen")
	_curr_cocoa_bean_panel.add_theme_stylebox_override("panel", cocoa_bean_selection_theme_override)


func _process(delta):
	if _curr_player:
		var bi = _curr_player._bean_inventory
		for key in bi:
			var bean = key as CocoaBeanResource
			if bean:
				var count = bi[bean] as int
				match bean.type:
					CocoaBeanResource.Type.Normal:
						_ncb_ctr.set_text(str(count))
					CocoaBeanResource.Type.Frozen:
						_fcb_ctr.set_text(str(count))
