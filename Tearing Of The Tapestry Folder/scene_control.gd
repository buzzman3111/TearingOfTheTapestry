extends Node

@onready var main_menu: Node2D = $MainMenu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var transition_overlay: ColorRect = $OverlayLayer/TransitionOverlay

var current_level
var next_level = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu.connect('change_scene', _handle_level_change)
	current_level = main_menu
	transition_overlay.color = Color(00000000)


func _handle_level_change(chapter: String, level: String) -> void:
	print('Changed scene to ' + chapter + ': ' + level)
	
	var level_scene = load('res://levels/' + chapter.to_lower() + '/' + chapter.to_lower() + level.to_lower() + '.tscn')
	
	if level_scene == null:
		push_error('Level does not exist')
		return
	
	next_level = level_scene.instantiate()
	next_level.visible = false
	self.add_child(next_level)
	animation_player.play("fade_in")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		'fade_in':
			current_level.queue_free()
			current_level = next_level
			next_level = null
			current_level.visible = true
			
			var level_camera = current_level.find_child('LevelCamera')
			level_camera.make_current()
			
			animation_player.play("fade_out")
		'fade_out':
			pass
