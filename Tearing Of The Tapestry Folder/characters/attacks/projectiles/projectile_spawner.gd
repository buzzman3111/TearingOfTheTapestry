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
func _fire_melee(projectile_owner: Node2D,
	melee_index: int, 
	damage: int = player_stats.PROJECTILE_DAMAGE,
	rotation: float = aim.rotation) -> void:
	
	var melee = melee_scenes[melee_index].instantiate()
	
	melee.global_position = aim.global_position
	melee.DURATION = DURATION
	melee.rotation = rotation
	melee.OWNER = projectile_owner
	melee.DAMAGE = damage
	
	self.add_child(melee)


# Creates and adds to scene the projectile at index ability_index
func _fire_projectile(projectile_owner: Node2D,
	projectile_index: int, 
	damage: int = player_stats.PROJECTILE_DAMAGE,
	rotation: float = aim.rotation,
	proj_range: float = player_stats.PROJECTILE_RANGE,
	speed: float = player_stats.PROJECTILE_SPEED) -> void:
	
	var projectile = projectile_scenes[projectile_index].instantiate()
	
	projectile.global_position = aim.global_position
	projectile.RANGE = proj_range
	projectile.SPEED = speed
	projectile.DAMAGE = damage
	projectile.OWNER = projectile_owner
	
	var move_dir = _get_dir(rotation)
	_apply_dir_rot(projectile, move_dir, rotation)
	
	self.add_child(projectile)


# Transforms angle into vector direction
func _get_dir(rotation: float) -> Vector2:
	var x = cos(rotation)
	var y = sin(rotation)
	return Vector2(x,y)

# Sets projectile movement direction and rotation
func _apply_dir_rot(projectile: Node2D, move_dir: Vector2, rotation: float) -> void:
	projectile.move_dir = move_dir
	projectile.rotation = rotation + PI/2 	# Make projectiles facing upwards for this to apply
