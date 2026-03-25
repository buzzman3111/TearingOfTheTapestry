class_name Melee
extends Node2D

# General-use melee attack object
var OWNER: Node2D
var DAMAGE: int
var DURATION: float

@onready var hitbox: Area2D = $Hitbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('swoosh')
	_expire()


func _expire() -> void:
	await get_tree().create_timer(self.DURATION).timeout
	self.queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group('character')) and (body != OWNER):
		print('hit: ', body)
		print('owner: ', OWNER)
		body._damage(self.DAMAGE)
