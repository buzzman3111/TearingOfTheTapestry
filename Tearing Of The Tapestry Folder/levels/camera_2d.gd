extends Camera2D

var timer := 0.0

@export var camera_update_interval := 0.2

@export var position_smooth_speed := 2.0
@export var zoom_smooth_speed := 2.0

@export var min_zoom := 0.5
@export var max_zoom := 10.0

@export var screen_padding := 500.0

var target_position := Vector2.ZERO
var target_zoom := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	
	if timer >= camera_update_interval:
		timer = 0.0
		var character_list = GameManager.player_list
		character_list.merge(GameManager.enemy_list)
		_update_camera(character_list)
	
	self.position = self.position.lerp(target_position, position_smooth_speed * delta)
	self.zoom = self.zoom.lerp(Vector2.ONE * target_zoom, zoom_smooth_speed * delta)



func _update_camera(character_list: Dictionary) -> void:
	if character_list.is_empty():
		return
	
	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	
	for character in character_list:
		var pos = character_list[character].position
		
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	var bounds_size = max_pos - min_pos
	
	bounds_size += Vector2.ONE * screen_padding
	
	var viewport_size = get_viewport_rect().size
	
	var zoom_x = viewport_size.x / bounds_size.x
	var zoom_y = viewport_size.y / bounds_size.y
	
	target_zoom = min(zoom_x, zoom_y)
	target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	
	target_position = (max_pos + min_pos) / 2.0
	# Maybe clamp position of camera wrt the current room somehow?
