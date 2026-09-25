class_name SimpleMeleeEnemy
extends EnemyBase

var patrol_points: Array[Vector2] = []
var current_patrol = 0
var detection_range = 500.0
var patrol_speed = 100.0

@export var recoil_strength: float = 200.0
@export var recoil_duration: float = 0.15

var recoil_time_left = 0.0

func _init() -> void:
	damage_cooldown = 0.75

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if recoil_time_left > 0.0:
		recoil_time_left -= delta
		return  # skip normal movement while recoiling

	# Find nearest player
	target = find_nearest_player()

	if target and global_position.distance_to(target.global_position) < detection_range:
		# Chase the player
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * STATS.SPEED
	else:
		# Patrol or idle
		velocity = Vector2.ZERO

func find_nearest_player() -> CharacterBase:
	var players = GameManager.player_list.values()
	if players.is_empty():
		return null

	var nearest = null
	var min_dist = INF

	for player in players:
		if is_instance_valid(player) and not player.IS_DEAD:
			var dist = global_position.distance_to(player.global_position)
			if dist < min_dist:
				nearest = player
				min_dist = dist

	return nearest

func deal_damage_to(target: CharacterBase, damage: int) -> void:
	super.deal_damage_to(target, damage)
	var recoil_direction = (global_position - target.global_position).normalized()
	velocity = recoil_direction * recoil_strength
	recoil_time_left = recoil_duration