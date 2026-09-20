class_name EnemySpawner
extends Node2D

# Path to the JSON file containing wave configurations for this level
@export var level_config_file: String = ""

# This spawner's ID in the JSON file (e.g., "spawner_1", "spawner_2")
@export var spawner_id: String = ""

# Spawn radius - can be overridden in JSON per spawner
@export var spawn_radius: float = 200.0

# Spawner state
var waves: Array[Wave] = []
var current_wave_index: int = 0
var enemies_spawned_this_wave: int = 0
var progression_enabled: bool = false
var waiting_for_next_wave: bool = false

@onready var spawn_position: Vector2 = global_position


func _ready() -> void:
	if level_config_file.is_empty() or spawner_id.is_empty():
		push_error("EnemySpawner: level_config_file or spawner_id not set!")
		return
	
	_load_waves_from_json()
	
	if waves.is_empty():
		push_error("EnemySpawner: No waves configured for spawner_id '", spawner_id, "'")
		return
	
	await get_tree().create_timer(0.5).timeout
	_start_wave()


func _process(_delta: float) -> void:
	# Check if current wave is cleared
	if not progression_enabled and not waiting_for_next_wave and enemies_spawned_this_wave > 0:
		_check_wave_cleared()


# Load waves from JSON file
func _load_waves_from_json() -> void:
	if not ResourceLoader.exists(level_config_file):
		push_error("JSON file not found: ", level_config_file)
		return
	
	var file_content = FileAccess.get_file_as_string(level_config_file)
	
	if file_content.is_empty():
		push_error("Failed to read JSON file: ", level_config_file)
		return
	
	var data = JSON.parse_string(file_content)
	
	if data == null:
		push_error("Failed to parse JSON file (invalid format): ", level_config_file)
		push_error("File content: ", file_content)
		return
	
	if not data.has(spawner_id):
		push_error("Spawner ID '", spawner_id, "' not found in JSON file: ", level_config_file)
		push_error("Available spawner IDs: ", data.keys())
		return
	
	var spawner_data = data[spawner_id]
	
	# Set spawn radius if specified in JSON
	if spawner_data.has("spawn_radius"):
		spawn_radius = spawner_data["spawn_radius"]
	
	# Load all waves
	var wave_list = spawner_data.get("waves", [])
	for wave_data in wave_list:
		var spawn_delay = wave_data.get("spawn_delay", 0.1)
		var wave_start_delay = wave_data.get("wave_start_delay", 0.0)
		var enemies = wave_data.get("enemies", [])
		
		var wave = Wave.new(spawn_delay, wave_start_delay)
		
		for enemy_data in enemies:
			var scene_path = enemy_data.get("scene", "")
			var count = enemy_data.get("count", 1)
			
			# Load scene from path string
			var scene = _load_enemy_scene(scene_path)
			if scene:
				wave.add_enemy(scene, count)
		
		if not wave.enemies.is_empty():
			waves.append(wave)


# Helper function to load enemy scene from string path
func _load_enemy_scene(scene_path: String) -> PackedScene:
	if scene_path.is_empty():
		return null
	
	# If path doesn't include "res://", assume it's in enemies folder
	if not scene_path.begins_with("res://"):
		scene_path = "res://characters/enemies/" + scene_path
	
	# Add .tscn if not present
	if not scene_path.ends_with(".tscn"):
		scene_path += ".tscn"
	
	var scene = ResourceLoader.load(scene_path)
	if scene == null:
		push_error("Failed to load enemy scene: ", scene_path)
		return null
	
	return scene


# Start the current wave by spawning all enemies
func _start_wave() -> void:
	if current_wave_index >= waves.size():
		# All waves complete
		progression_enabled = true
		print("All waves cleared!")
		return
	
	var current_wave = waves[current_wave_index]
	enemies_spawned_this_wave = 0
	
	print("Starting wave ", current_wave_index + 1, " of ", waves.size())
	
	# Spawn all enemies in this wave
	for enemy_config in current_wave.enemies:
		var enemy_scene: PackedScene = enemy_config.get("scene")
		var count: int = enemy_config.get("count", 1)
		
		if not enemy_scene:
			push_error("Wave ", current_wave_index, " has a null enemy scene")
			continue
		
		# Spawn 'count' instances of this enemy
		for i in range(count):
			await get_tree().create_timer(current_wave.spawn_delay).timeout
			_spawn_enemy(enemy_scene)
			enemies_spawned_this_wave += 1


# Spawn a single enemy at a random position within spawn_radius
func _spawn_enemy(enemy_scene: PackedScene) -> void:
	var enemy = enemy_scene.instantiate()
	
	# Set random spawn position
	var random_offset = Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	enemy.global_position = spawn_position + random_offset
	
	# Add to scene
	get_parent().add_child(enemy)
	
	print("Spawned enemy: ", enemy.name, " at position ", enemy.global_position)


# Check if the current wave is cleared (all enemies dead)
func _check_wave_cleared() -> void:
	var alive_enemies = 0
	
	# Count enemies still alive in GameManager
	for enemy_name in GameManager.enemy_list:
		var enemy = GameManager.enemy_list[enemy_name]
		if is_instance_valid(enemy):
			alive_enemies += 1
	
	if alive_enemies == 0:
		print("Wave ", current_wave_index + 1, " cleared!")
		current_wave_index += 1
		waiting_for_next_wave = true
		
		# Wait before starting next wave
		var wait_time = 0.5
		if current_wave_index < waves.size():
			wait_time = waves[current_wave_index].wave_start_delay
		
		await get_tree().create_timer(wait_time).timeout
		waiting_for_next_wave = false
		_start_wave()
