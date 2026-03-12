class_name ProjectileSpawner
extends Node

@export var projectile_scene: PackedScene
@export var projectile_sprite: CompressedTexture2D
@export var player_stats: Stats
@export var aim: Node2D


func _ready() -> void:
	pass


#func _process(delta: float) -> void:
	#pass


func _fire() -> void:
	var projectile = projectile_scene.instantiate()
	
	projectile.global_position = aim.global_position
	projectile.RANGE = player_stats.PROJECTILE_RANGE
	projectile.SPEED = player_stats.PROJECTILE_SPEED
	projectile.find_child('Sprite2D').texture = projectile_sprite
	
	var move_dir = _get_move_dir()
	projectile._apply_dir_rot(move_dir, aim.rotation)
	
	self.add_child(projectile)


func _get_move_dir() -> Vector2:
	var x = cos(aim.rotation)
	var y = sin(aim.rotation)
	return Vector2(x,y)
