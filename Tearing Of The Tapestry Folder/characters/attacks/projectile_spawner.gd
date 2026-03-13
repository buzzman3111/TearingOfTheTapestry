class_name ProjectileSpawner
extends Node

# General-use object that sets projectile attacks

# This array hold all projectiles the character has access to
# 	0 is always the basic projectile
@export var projectile_scene: Array[PackedScene]
@export var player_stats: Stats
@export var aim: Node2D

#func _ready() -> void:
	#pass

#func _process(delta: float) -> void:
	#pass


func _fire(ability_index: int) -> void:
	var projectile = projectile_scene[ability_index].instantiate()
	
	projectile.global_position = aim.global_position
	projectile.RANGE = player_stats.PROJECTILE_RANGE
	projectile.SPEED = player_stats.PROJECTILE_SPEED
	
	var move_dir = _get_move_dir()
	_apply_dir_rot(projectile, move_dir, aim.rotation)
	
	self.add_child(projectile)


func _get_move_dir() -> Vector2:
	var x = cos(aim.rotation)
	var y = sin(aim.rotation)
	return Vector2(x,y)

func _apply_dir_rot(projectile: Node2D, move_dir: Vector2, rotation: float) -> void:
	projectile.move_dir = move_dir
	projectile.rotation = rotation + PI/2
