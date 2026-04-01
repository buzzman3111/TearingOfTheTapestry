class_name Projectile
extends Node2D

var RANGE: float
var SPEED: float
var DAMAGE: float
var OWNER: Node2D

var move_dir: Vector2
var start_pos: Vector2

@onready var hitbox: Area2D = $Hitbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true
	start_pos = self.global_position
	if !self.hitbox.is_connected('body_entered', _on_hitbox_body_entered):
		self.hitbox.connect('body_entered', _on_hitbox_body_entered)


func _process(delta: float) -> void:
	self.global_position += move_dir * SPEED * delta
	if self.global_position.distance_to(start_pos) >= RANGE:
		self.queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group('character')) and (body != OWNER):
		print('hit: ', body)
		print('owner: ', OWNER)
		body._damage(roundf(DAMAGE))
