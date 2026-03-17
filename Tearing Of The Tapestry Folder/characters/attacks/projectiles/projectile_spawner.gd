class_name ProjectileSpawner
extends Node

# General-use object that sets projectile attacks

# This array hold all projectiles the character has access to, melee or ranged
@export var projectile_scenes: Array[PackedScene]
@export var melee_scenes: Array[PackedScene]
@export var player_stats: Stats
@export var aim: Node2D

const DURATION: float = 0.1


# Creates and adds to scene the melee attack at index 
func _fire_melee(melee_index: int, direction: float = aim.rotation) -> void:
	var melee = melee_scenes[melee_index].instantiate()
	
	melee.global_position = aim.global_position
	melee.DURATION = DURATION
	melee.rotation = direction
	
	self.add_child(melee)


# Creates and adds to scene the projectile at index ability_index
func _fire_projectile(projectile_index: int) -> void:
	var projectile = projectile_scenes[projectile_index].instantiate()
	
	projectile.global_position = aim.global_position
	projectile.RANGE = player_stats.PROJECTILE_RANGE
	projectile.SPEED = player_stats.PROJECTILE_SPEED
	
	var move_dir = _get_move_dir()
	_apply_dir_rot(projectile, move_dir, aim.rotation)
	
	self.add_child(projectile)


# Transforms angle into vector direction
func _get_move_dir() -> Vector2:
	var x = cos(aim.rotation)
	var y = sin(aim.rotation)
	return Vector2(x,y)

# Sets projectile movement direction and rotation
func _apply_dir_rot(projectile: Node2D, move_dir: Vector2, rotation: float) -> void:
	projectile.move_dir = move_dir
	projectile.rotation = rotation + PI/2 	# Make projectiles facing upwards for this to apply
