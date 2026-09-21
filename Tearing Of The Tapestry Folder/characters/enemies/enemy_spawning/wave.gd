class_name Wave

# Simple data class to hold wave configuration
var enemies: Array[Dictionary] = []  # [{scene: PackedScene, count: int}, ...]
var spawn_delay: float = 0.1
var wave_start_delay: float = 0.0

func _init(p_spawn_delay: float = 0.1, p_wave_start_delay: float = 0.0) -> void:
	spawn_delay = p_spawn_delay
	wave_start_delay = p_wave_start_delay

# Helper function to add an enemy type to this wave
func add_enemy(scene: PackedScene, count: int = 1) -> Wave:
	enemies.append({"scene": scene, "count": count})
	return self  # Return self for chaining
