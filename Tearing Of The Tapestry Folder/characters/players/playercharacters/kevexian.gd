extends PlayerBase

@onready var buff_area: Area2D = $BuffArea

const effect_setters := {
	"HOLY BURN": preload("res://effects/holy_burn.tscn")
}

@export var A1_BASE_HEAL: int = 10 	# Base healing applied to allies regardless of stacks removed
@export var A1_HEAL_PER_STACK: int = 2 	# Additional healing per negative effect stack removed
@export var A2_HB_STACKS: int = 1
@export var A2_EFFECT_RADIUS: float = 150.0	# Radius around each ally where they inflict holy burn on enemies
@export var ULT_HB_STACKS: int = 5	# Holy burn stacks applied by ultimate
@export var ULT_HB_RADIUS: float = 150.0	# Radius of holy burn applied by ultimate


const BUFF_AREA_DETECTION_WINDOW: float = 0.1

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _A1() -> void:
	update_a1_ui.emit()
	await _cleanse_buff_area()
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	update_a1_ui.emit()
	CAN_A1 = true


func _A2() -> void:
	update_a2_ui.emit()
	await _apply_holy_burn_aura()
	await get_tree().create_timer(STATS.A2_COOLDOWN).timeout
	update_a2_ui.emit()
	CAN_A2 = true


# Strips all dispellable negative effects from every character (ally or enemy) inside
# 	the Buff Area, then heals allies in range for a base amount plus a bonus per stack removed
func _cleanse_buff_area() -> void:
	
	await get_tree().create_timer(BUFF_AREA_DETECTION_WINDOW).timeout
	
	
	var removed_stacks := 0
	var allies_in_range: Array = []
	
	for body in buff_area.get_overlapping_bodies():
		if not (body.is_in_group('player') or body.is_in_group('enemy')):
			continue
		
		removed_stacks += _strip_negative_effects(body)
		
		if body.is_in_group('player'):
			allies_in_range.append(body)
	
	if allies_in_range.is_empty():
		return
	
	var heal_amount = A1_BASE_HEAL + (removed_stacks * A1_HEAL_PER_STACK)
	if heal_amount <= 0:
		return
	
	for ally in allies_in_range:
		ally._take_damage(-heal_amount)


# Enables allies in buff area to inflict holy burn stacks on enemies within A2_EFFECT_RADIUS
func _apply_holy_burn_aura() -> void:
	await get_tree().create_timer(BUFF_AREA_DETECTION_WINDOW).timeout
	
	var allies_in_range: Array = []
	for body in buff_area.get_overlapping_bodies():
		if body.is_in_group('player'):
			allies_in_range.append(body)
	
	if allies_in_range.is_empty():
		return
	
	# For each ally, apply holy burn to nearby enemies
	# TODO: Change back to enemies
	for ally in allies_in_range:
		#for enemy_name in GameManager.enemy_list:
		for player_name in GameManager.player_list:
			#var enemy = GameManager.enemy_list[enemy_name]
			var enemy = GameManager.player_list[player_name]
			if enemy and ally.global_position.distance_to(enemy.global_position) <= A2_EFFECT_RADIUS:
				_set_effect('HOLY BURN', enemy, enemy, false, INF, A2_HB_STACKS)


# Removes all dispellable effects (holy burn, bleed, poison, burn, slowed, haste, weakened, etc.)
# 	from the given character and returns the total number of stacks that were removed
func _strip_negative_effects(body: Node) -> int:
	var stacks_removed := 0
	for child in body.get_children():
		if child is Effect and child.is_debuff:
			stacks_removed += child._dispel()
	return stacks_removed


func _ultimate() -> void:
	update_ult_ui.emit()
	
	# Find the dead player who's been dead the longest
	var longest_dead_player = null
	var earliest_death_time = INF
	
	for dead_name in GameManager.dead_player_list:
		var death_time = GameManager.dead_player_list[dead_name]
		if death_time < earliest_death_time:
			earliest_death_time = death_time
			longest_dead_player = GameManager.player_list.get(dead_name)
	
	if longest_dead_player:
		# Revive the longest dead player
		longest_dead_player._revive()
		# Apply max holy burn damage (10 stacks) to nearby enemies for instant detonation
		_apply_ult_holy_burn(longest_dead_player.global_position, longest_dead_player, 10)
	else:
		# No dead allies, apply stacking holy burn to enemies nearby Kevexian
		_apply_ult_holy_burn(self.global_position, self, ULT_HB_STACKS)
	
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	update_ult_ui.emit()
	CAN_ULT = true


# Apply holy burn to enemies within ULT_HB_RADIUS of the given position
# Excludes the source_ally so they don't burn themselves
# stack_amount: number of stacks to apply (10 = instant detonation at max damage)
func _apply_ult_holy_burn(from_position: Vector2, source_ally: Node, stack_amount: int) -> void:
	print('Applying ult holy burn from position: ', from_position, ' with radius: ', ULT_HB_RADIUS, ' stacks: ', stack_amount)
	for player_name in GameManager.player_list:
		var enemy = GameManager.player_list[player_name]
		if enemy:
			var distance = from_position.distance_to(enemy.global_position)
			print('  Checking ', enemy.name, ' at distance ', distance)
			if enemy != source_ally and distance <= ULT_HB_RADIUS:
				print('    Applying ', stack_amount, ' holy burn stacks to ', enemy.name)
				_set_effect('HOLY BURN', enemy, enemy, false, INF, stack_amount)
			elif enemy == source_ally:
				print('    Skipping source ally: ', enemy.name)
