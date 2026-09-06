extends Projectile

var target: Node2D = null
var initial_dir: Vector2

const TURN_SPEED: float = 10.0

func _ready() -> void:
	super._ready()
	target = call_deferred('_find_nearest_player')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if !is_instance_valid(target):
		target = _find_nearest_player()
	
	if target:
		var desired_dir = (target.global_position - self.global_position).normalized()
		move_dir = move_dir.move_toward(desired_dir, TURN_SPEED * delta).normalized()


func _find_nearest_player():
	var possible_targets = GameManager.player_list
	
	var nearest_target = null
	var nearest_target_pos = Vector2(INF, INF)
	
	for obj_targetting in possible_targets:
		var targeting = possible_targets[obj_targetting]
		if targeting != owner:
			if (owner.global_position - targeting.global_position).length_squared() < nearest_target_pos.length_squared():
				nearest_target_pos = owner.global_position - targeting.global_position
				nearest_target = targeting
	
	return nearest_target
