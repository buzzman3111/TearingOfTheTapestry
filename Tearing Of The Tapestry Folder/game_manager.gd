extends Node

const damage_tick_time: float = 1.0

# Lists of current players and enemies in the active level
# 	Characters add themselves to their respective lists in the character_base _ready() baed on their group
var player_list = Dictionary()
var enemy_list = Dictionary()

# Tracks dead players: player_name -> time_died_ms (for revive tracking)
var dead_player_list = Dictionary()

signal damage_tick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tick_timer = Timer.new()
	self.add_child(tick_timer)
	tick_timer.wait_time = damage_tick_time
	tick_timer.one_shot = false
	tick_timer.connect('timeout', _damage_tick)
	tick_timer.start()
	
	await get_tree().create_timer(0.2).timeout
	print('players in scene: ', player_list)
	print('enemies in scene: ', enemy_list)


func _damage_tick() -> void:
	#print('Damage Tick')
	self.damage_tick.emit()
