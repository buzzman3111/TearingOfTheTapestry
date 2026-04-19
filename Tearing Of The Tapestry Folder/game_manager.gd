extends Node

const damage_tick_time: float = 1.0

signal damage_tick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tick_timer = Timer.new()
	self.add_child(tick_timer)
	tick_timer.wait_time = damage_tick_time
	tick_timer.one_shot = false
	tick_timer.connect('timeout', _damage_tick)
	tick_timer.start()


func _damage_tick() -> void:
	#print('Damage Tick')
	self.damage_tick.emit()
