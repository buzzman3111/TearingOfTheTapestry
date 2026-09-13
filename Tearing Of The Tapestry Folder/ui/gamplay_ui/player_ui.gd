extends MarginContainer

var player_ui_module = preload("res://ui/gamplay_ui/player_ui_module.tscn")

@onready var module_cont_side: VBoxContainer = $UISide/VBoxContainer

@onready var module_cont_bot: VBoxContainer = $UIBottom/HBoxContainer/ModuleCont
@onready var module_cont_bot_2: VBoxContainer = $UIBottom/HBoxContainer/ModuleCont2
@onready var module_cont_bot_3: VBoxContainer = $UIBottom/HBoxContainer/ModuleCont3
@onready var module_contr_bot_4: CenterContainer = $UIBottom/HBoxContainer/ModuleContr4
@onready var module_cont_bot_5: CenterContainer = $UIBottom/HBoxContainer/ModuleCont5

@onready var module_conts_bot = [
	module_cont_bot,
	module_cont_bot_2,
	module_cont_bot_3,
	module_contr_bot_4,
	module_cont_bot_5
]

var num_active_modules := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	for player in GameManager.player_list:
		var new_module = player_ui_module.instantiate()
		new_module.connected_player = GameManager.player_list[player]
		_add_ui_module(new_module)
		num_active_modules += 1


func _add_ui_module(new_module) -> void:
	match Settings.health_bar_loc:
		Settings.health_bar_locations.SIDE:
			module_cont_side.add_child(new_module)
		Settings.health_bar_locations.BOTTOM:
			var module_tracker = num_active_modules % 5
			module_conts_bot[module_tracker].add_child(new_module)
