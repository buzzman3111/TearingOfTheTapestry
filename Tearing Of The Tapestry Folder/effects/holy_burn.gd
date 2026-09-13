extends Effect

@onready var collision_area: Area2D = $CollisionArea

@export var damage_per_stack: float = 5.0
@export var max_bomb_stacks: int = 10
@export var tick_damage_per_stack: float = 1.0

var has_detonated: bool = false

func _ready() -> void:
	max_stacks = max_bomb_stacks
	super._ready()
	GameManager.connect('damage_tick', _damage)


# Add stacks and check for immediate detonation if max is reached
func _add_stacks(amount: int = 1) -> void:
	super._add_stacks(amount)
	if num_stacks >= max_stacks:
		_detonate()


# Called each damage tick while the bomb is armed
func _damage() -> void:
	var afflicted_target := get_parent()
	if afflicted_target and afflicted_target.has_method('_take_damage'):
		var tick_damage := int(roundf(num_stacks * tick_damage_per_stack))
		if tick_damage > 0:
			afflicted_target._take_damage(tick_damage)


func _on_effect_duration_timeout() -> void:
	if GameManager.is_connected('damage_tick', _damage):
		GameManager.disconnect('damage_tick', _damage)
	_detonate()


func _detonate() -> void:
	if has_detonated:
		return
	has_detonated = true

	var total_damage := int(roundf(num_stacks * damage_per_stack))
	if total_damage <= 0:
		queue_free()
		return

	var afflicted_target := get_parent()
	var hit_targets: Array = []
	if afflicted_target and afflicted_target.is_in_group('player') and afflicted_target.has_method('_take_damage'):
		hit_targets.append(afflicted_target)

	for body in collision_area.get_overlapping_bodies():
		if body == afflicted_target:
			continue
		if body.is_in_group('player') and body.has_method('_take_damage'):
			hit_targets.append(body)

	for target in hit_targets:
		target._take_damage(total_damage)

	queue_free()
