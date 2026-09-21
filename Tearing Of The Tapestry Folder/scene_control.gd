extends Node

@onready var main_menu: Node2D = $MainMenu

var current_level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu.connect('change_scene', _handle_level_change)
	current_level = main_menu


func _handle_level_change(chapter: String, level: String) -> void:
	print('Changed scene to ' + chapter + ': ' + level)
	
	var level_scene = load('res://levels/' + chapter.to_lower() + level.to_lower() + '.tscn')
	var next_level = level_scene.instantiate()
	self.add_child(next_level)
	current_level.queue_free()
	current_level = next_level
	
	var level_camera = current_level.find_child('LevelCamera')
	level_camera.make_current()
