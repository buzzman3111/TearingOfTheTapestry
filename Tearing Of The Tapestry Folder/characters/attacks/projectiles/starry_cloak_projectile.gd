extends Projectile

var target: Node2D = null
var initial_dir: Vector2

const TURN_SPEED: float = 10.0

func _ready() -> void:
	super._ready()
	target = _find_nearest_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if !is_instance_valid(target):
		target = _find_nearest_player()
	
	if target:
		var desired_dir = (target.global_position - self.global_position).normalized()
		move_dir = move_dir.move_toward(desired_dir, TURN_SPEED * delta).normalized()

func _find_nearest_player():
	var level_children = get_tree().current_scene.get_children() # Will break when creating actual levels
	var nearest_child = null
	var nearest_distance = INF
	for child in level_children:
		if child.is_in_group('character') and (child != self.OWNER):
			var child_rel_pos = self.global_position.distance_squared_to(child.global_position)
			if child_rel_pos < nearest_distance:
				nearest_child = child
				nearest_distance = child_rel_pos
	
	return nearest_child
