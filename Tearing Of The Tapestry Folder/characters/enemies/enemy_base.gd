class_name EnemyBase
extends CharacterBase

@onready var STATS: Stats = $Stats
var can_deal_damage = true
var damage_cooldown = 0.5
var target: CharacterBase = null
var bodies_in_damage_area: Array = []

@export var knockback_enabled: bool = true
@export var knockback_strength: float = 500.0

func _ready() -> void:
	super._ready()
	add_to_group("enemy")
	# Find collision areas for damage detection
	for area in find_children("*", "Area2D"):
		if area.name.contains("DamageArea"):
			area.body_entered.connect(_on_damage_area_entered)
			area.body_exited.connect(_on_damage_area_exited)

func _physics_process(delta: float) -> void:
	# AI behavior here (move, attack patterns, etc.)
	if !can_deal_damage:
		damage_cooldown -= delta
		if damage_cooldown <= 0:
			can_deal_damage = true
			damage_cooldown = 0.5
	
	# Apply damage to all bodies currently in damage area
	if can_deal_damage:
		for body in bodies_in_damage_area:
			if is_instance_valid(body) and body.is_in_group("player"):
				deal_damage_to(body, STATS.PROJECTILE_DAMAGE)
				can_deal_damage = false
				break
	
	move_and_slide()

func _on_damage_area_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body not in bodies_in_damage_area:
		bodies_in_damage_area.append(body)

func _on_damage_area_exited(body: Node2D) -> void:
	if body in bodies_in_damage_area:
		bodies_in_damage_area.erase(body)

func _take_damage(damage: int, knockback_source: Vector2 = Vector2.ZERO) -> void:
	STATS.HP -= damage
	if knockback_enabled and knockback_source != Vector2.ZERO:
		var knockback_direction = (global_position - knockback_source).normalized()
		velocity = knockback_direction * knockback_strength
	if STATS.HP <= 0:
		_die()

func deal_damage_to(target: CharacterBase, damage: int) -> void:
	target.STATS.HP -= damage
	target.update_hp_ui.emit(target.STATS.HP)
	if target.STATS.HP <= 0:
		target._die()
