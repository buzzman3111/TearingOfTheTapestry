extends Node

@onready var damage_tick: Timer = $DamageTick

@export var damage_tick_time := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_tick.wait_time = damage_tick_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass



func _on_damage_tick_timeout() -> void:
	print('Damage tick')
	
	### Call damage tick for all damage effects on all characters in scene tree
