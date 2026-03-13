class_name Projectile
extends Node2D

var RANGE: float
var SPEED: float

var move_dir: Vector2
var start_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true
	start_pos = self.global_position


func _process(delta: float) -> void:
	self.global_position += move_dir * SPEED * delta
	if self.global_position.distance_to(start_pos) >= RANGE:
		self.queue_free()
