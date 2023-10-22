extends Level

@export var cocoa_bean_selection_color: Color
@export var cocoa_bean_selection_theme_override: StyleBoxFlat
@export var camera_speed = 300.0
@export var master_bank_asset: BankAsset
@export var ambiance_bank_asset: BankAsset
@export var music_bank_asset: BankAsset
@export var sfx_bank_asset: BankAsset

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
@onready var _camera = $Camera2D as Camera2D
@onready var _storage_bins = [ $CocoaShop/CocoaStorageBin_FrozenHot, $CocoaShop/CocoaStorageBin_Regular ]

var _curr_cocoa_bean_panel: PanelContainer
var _cocoa_bean_default_theme_override: StyleBoxFlat
var _available_music: Array
var _curr_selected_music: StudioEventEmitter2D
var _curr_selected_music_idx := 0


func _exit_tree():
	
	_player_vars.is_initialized = true
	for sb in _storage_bins:
		var bin = sb as StorageBin
		if bin:
			var bean_type = bin.cocoa_bean_resource_type.type
			_player_vars.storage_bean_inventory[bean_type] = bin._bean_ctr


func _ready():
	if _player_vars.is_initialized:
		for sb in _storage_bins:
			var bin = sb as StorageBin
			if bin:
				var bean_type = bin.cocoa_bean_resource_type.type
				bin._bean_ctr = _player_vars.storage_bean_inventory[bean_type] 
	
	_available_music = get_tree().get_nodes_in_group("music")
	_curr_selected_music = $Music_0
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
		CocoaBeanResource.Type.Frozen:
			_curr_cocoa_bean_panel = _fcb_slot_panel
	_curr_cocoa_bean_panel.add_theme_stylebox_override("panel", cocoa_bean_selection_theme_override)


func _input(event):
	if event.is_action_pressed("change_music"):
		_curr_selected_music.stop()
		_curr_selected_music_idx = (_curr_selected_music_idx + 1) % _available_music.size()
		_curr_selected_music = _available_music[_curr_selected_music_idx]
		_curr_selected_music.play()
		print("Changing Music: %s" % str(_curr_selected_music_idx))


func _process(delta):
	if _curr_player:
		_camera.set_position(Vector2(_curr_player.global_position.x, 48))
		var offset_target = 64
		if sign(_curr_player.velocity.x) > 0:
			var new_offset_x = move_toward(_camera.offset.x, offset_target, delta * camera_speed)
			_camera.set_offset(Vector2(new_offset_x, 0))
		elif sign(_curr_player.velocity.x) < 0:
			offset_target = -64
			var new_offset_x = move_toward(_camera.offset.x, offset_target, delta * camera_speed)
			_camera.set_offset(Vector2(new_offset_x, 0))
		
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
