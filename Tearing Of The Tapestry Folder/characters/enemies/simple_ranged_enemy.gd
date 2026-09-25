class_name SimpleEnemyRanged
extends EnemyBase

@onready var projectile_spawner: ProjectileSpawner = $ProjectileSpawner
@onready var aim: Node2D = $Aim

@export var attack_range: float = 400.0
@export var detection_range: float = 500.0
@export var attack_cooldown_time: float = 1.5
@export var projectile_index: int = 0

var attack_cooldown: float = 0.0
var can_attack: bool = true

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not can_attack:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			can_attack = true

	target = find_nearest_player()

	if target and is_instance_valid(target) and global_position.distance_to(target.global_position) < detection_range:
		var dist = global_position.distance_to(target.global_position)

		if dist > attack_range:
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * STATS.SPEED
		else:
			velocity = Vector2.ZERO
			_aim_at_target()
			if can_attack:
				_fire_at_target()
	else:
		velocity = Vector2.ZERO

func _aim_at_target() -> void:
	aim.global_rotation = (target.global_position - aim.global_position).angle()

func _fire_at_target() -> void:
	projectile_spawner._fire_projectile(self, projectile_index, STATS.PROJECTILE_DAMAGE, aim.rotation)
	can_attack = false
	attack_cooldown = attack_cooldown_time

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
