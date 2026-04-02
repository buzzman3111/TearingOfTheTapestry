extends Node
class_name Effect

@onready var duration_timer: Timer = $DurationTimer

#@export var deals_damage: bool = false
@export var damage: float = 0.0				# Damage this effect deals per tick
@export var effect_duration: float = 1.0	# How long the effect lasts before removing itself
@export var effect_strength: float = 1.0 	# If effect applies buff/debuff, this multiplies value
@export var effect_amount: float = 0.0 		# If effect applies buff/debuff, this adds to the value

var num_stacks: int = 1
@export var max_stacks: int = 999


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duration_timer.wait_time = effect_duration
	duration_timer.start()


func _on_effect_duration_timeout() -> void:
	print('Removing: ', self.name)
	num_stacks -= 1
	if num_stacks <= 0:
		self.queue_free()


func _add_stacks(amount: int = 1) -> void:
	num_stacks += amount
	if num_stacks > max_stacks:
		num_stacks = max_stacks


# Called by the GameManager to deal damage to owner if applicable
func _damage() -> void:
	var victim = self.owner
	if victim.has_method('_damage'):
		victim._damage(self.damage)


# Called by functions to increase attack/ability effectiveness
func _increase_effect(base_val: int) -> int:
	return (roundf(base_val * effect_strength) + effect_amount)
