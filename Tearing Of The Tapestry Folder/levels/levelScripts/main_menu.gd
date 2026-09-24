extends Node2D

signal change_scene(chapter_name: String, level_name: String)


@export var menu_swap_dur: float = 1.0

var can_interact: bool = true # Specific to moving camera to other containers
#var can_open_select: bool = true # Specific to opening level panels
var chapter_nav_hidden: bool = true # Controls if buttons on camera are visible or not
var current_container: Array = [] # Set as reference to node, plus index along containers

var queued_chapter: String = ''
var queued_level: String = ''

## Camera ##
@onready var menu_nav_cam: Camera2D = $MenuNavCam
@onready var prev_next_containter: Control = $MenuNavCam/PrevNextContainter
@onready var start_level_cont: Control = $MenuNavCam/StartLevelCont


## View Containers ##
### Arguments to pass into _move_cam and move_cam_init
@onready var main: Control = $CanvasLayer/Menu/Main
@onready var exit: Control = $CanvasLayer/Menu/Exit
@onready var chapter_module_1: Control = $CanvasLayer/Menu/ChapterModule1
@onready var chapter_module_2: Control = $CanvasLayer/Menu/ChapterModule2

var containers: Array = []
var level_mods: Array[Control] = []
var level_select_vis: Dictionary[Control, bool]

## Menu Buttons ##
### Naming convention: CurrentNext (nodes) current_next (code)
@onready var main_continue: Button = $CanvasLayer/Menu/Main/CenterContainer/VBoxContainer/VBoxContainer/MainContinue
@onready var main_new: Button = $CanvasLayer/Menu/Main/CenterContainer/VBoxContainer/VBoxContainer/MainNew
@onready var main_encyclopedia: Button = $CanvasLayer/Menu/Main/CenterContainer/VBoxContainer/VBoxContainer/MainEncyclopedia
@onready var main_settings: Button = $CanvasLayer/Menu/Main/CenterContainer/VBoxContainer/VBoxContainer/MainSettings
@onready var main_exit: Button = $CanvasLayer/Menu/Main/CenterContainer/VBoxContainer/VBoxContainer/MainExit

@onready var previous: TextureButton = $MenuNavCam/PrevNextContainter/MarginContainer/Previous
@onready var next: TextureButton = $MenuNavCam/PrevNextContainter/MarginContainer/Next


func _ready() -> void:
	menu_nav_cam.make_current()
	var cam_start_pos = Vector2(
		ProjectSettings.get_setting('display/window/size/viewport_width')/2,
		ProjectSettings.get_setting('display/window/size/viewport_height')/2)
	menu_nav_cam.position = cam_start_pos
	prev_next_containter.modulate.a = 0
	start_level_cont.hide()
	
	prev_next_containter.process_mode = Node.PROCESS_MODE_DISABLED
	start_level_cont.process_mode = Node.PROCESS_MODE_DISABLED
	
	level_mods = [chapter_module_1, chapter_module_2]
	containers = [main, exit] + level_mods
	
	level_select_vis = {
		chapter_module_1: false, 
		chapter_module_2: false
		}
	
	current_container = [containers[0], 0]
	_init_level_buttons()

# Connects all the level buttons to a custom function that will change the level to the selected level
func _init_level_buttons() -> void:
	await self.ready
	
	for chapter in level_mods:
		var butt = [
			chapter.find_child('Lvl1'),
			chapter.find_child('Lvl2'),
			chapter.find_child('Lvl3'),
			chapter.find_child('Lvl4'),
		]
		
		for b in butt:
			b.pressed.connect(_open_start.bind(chapter.name, b.name))


func _move_cam(node: int, custom_pos: Vector2) -> void:
	current_container = [containers[node], node]
	
	var offset = Vector2(
			ProjectSettings.get_setting('display/window/size/viewport_width')/2,
			ProjectSettings.get_setting('display/window/size/viewport_height')/2
		)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	if custom_pos != Vector2.INF:
		tween.tween_property(menu_nav_cam, 'position', custom_pos + offset, menu_swap_dur)
	else:
		tween.tween_property(menu_nav_cam, 'position', current_container[0].position + offset, menu_swap_dur)
	
	await tween.finished
	if can_interact == false:
		can_interact = true


func _move_cam_init(node: int, custom_pos: Vector2 = Vector2.INF) -> void:
	if can_interact:
		can_interact = false
		_move_cam(node, custom_pos)


func _toggle_chapter_nav() -> void:
	var mod: int = 0
	if chapter_nav_hidden:
		mod = 255
		chapter_nav_hidden = false
		prev_next_containter.process_mode = Node.PROCESS_MODE_INHERIT
		await get_tree().create_timer(0.5).timeout
	else:
		mod = 0
		chapter_nav_hidden = true
		prev_next_containter.process_mode = Node.PROCESS_MODE_DISABLED
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(prev_next_containter, 'modulate:a', mod, menu_swap_dur/2.0)


func _toggle_level_select() -> void:
	if !can_interact:
		return
	
	can_interact = false
	var level_buttons = current_container[0].find_child('LevelSelect')
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	
	if level_select_vis[current_container[0]] == false:
		level_select_vis[current_container[0]] = true
		tween.tween_property(level_buttons, 'position:x', level_buttons.position.x + 600, menu_swap_dur/2.0)
	else:
		level_select_vis[current_container[0]] = false
		tween.tween_property(level_buttons, 'position:x', level_buttons.position.x - 600, menu_swap_dur/2.0)
	
	await get_tree().create_timer(menu_swap_dur/2.0).timeout
	can_interact = true


func _change_scene(chapter: String, level: String) -> void:
	print('changing scene to ' + chapter + ': ' + level)
	change_scene.emit(chapter, level)



### Menu Control Connections ###
func _on_main_exit_pressed() -> void:
	_move_cam_init(1)

func _on_main_new_pressed() -> void:
	_move_cam_init(2)
	_toggle_chapter_nav()

func _on_exit_exit_pressed() -> void:
	get_tree().quit()

func _on_exit_main_pressed() -> void:
	_move_cam_init(0)

func _on_previous_pressed() -> void:
	if current_container[0] == chapter_module_1:
		_move_cam_init(0)
		_toggle_chapter_nav()
	else:
		var screen_width = ProjectSettings.get_setting('display/window/size/viewport_width')
		_move_cam_init(current_container[1]-1, current_container[0].position - Vector2(screen_width, 0))

func _on_next_pressed() -> void:
	if current_container[0] == containers[-1]:
		pass
	else:
		var screen_width = ProjectSettings.get_setting('display/window/size/viewport_width')
		_move_cam_init(current_container[1]+1, current_container[0].position + Vector2(screen_width, 0))

func _open_start(chapter_name: String, button_name: String) -> void:
	start_level_cont.show()
	can_interact = false
	start_level_cont.process_mode = Node.PROCESS_MODE_INHERIT
	
	queued_chapter = chapter_name.substr(0, 2) + chapter_name.substr(chapter_name.length() - 1, 1)
	queued_level = button_name


func _on_start_selected_level_pressed() -> void:
	if (queued_chapter != queued_level) and (queued_chapter != ''):
		_change_scene(queued_chapter, queued_level)


func _on_back_to_level_select_pressed() -> void:
	start_level_cont.hide()
	can_interact = true
	start_level_cont.process_mode = Node.PROCESS_MODE_DISABLED
	
	queued_chapter = ''
	queued_level = ''
