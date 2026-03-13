class_name MeleeSpawner
extends Node

# General-use object that sets melee attacks

# This array hold all melee attacks the character has access to
# 	0 is always the basic melee
@export var melee_scene: Array[PackedScene]
@export var player_stats: Stats
@export var aim: Node2D

const DURATION: float = 0.1

#func _ready() -> void:
	#pass

#func _process(delta: float) -> void:
	#pass

func _slash(ability_index: int) -> void:
	var melee = melee_scene[ability_index].instantiate()
	melee.DURATION = DURATION
	aim.add_child(melee)
