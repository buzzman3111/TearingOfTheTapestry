extends PlayerBase

@onready var deactivate_passive_timer: Timer = $DeactivatePassiveTimer

@onready var starry_cloak_sprite: Sprite2D = $StarryCloakSprite
@onready var starry_cloak_sprite_2: Sprite2D = $StarryCloakSprite2


@onready var aim: Node2D = $Aim
@onready var new_buff_area: Area2D = $NewBuffArea

const effect_setters := {
	"HASTE": preload("res://effects/speed.tscn"),
	"SLOW": preload("res://effects/speed.tscn"),
	"BARRIER": preload("res://effects/barrier.tscn"),
	"HA": preload("res://effects/healing_aura.tscn"),
	"CHICKEN": preload("res://effects/chicken.tscn")
}

enum FORM {FULL, NEW}
var current_form = FORM.NEW

enum NEW_ABILITY_BUFF_TYPE {BARRIER, HASTE}
var CURRENT_NEW_BUFF = NEW_ABILITY_BUFF_TYPE.BARRIER

var STARRY_CLOAK_ACTIVE: bool = false
var ULT_ACTIVE: bool = false
var passive_count: int = 0

const DASH_WINDUP_DURATION: float = 0.25
const STARRY_CLOAK_ROT_SPEED: float = 20.0

@export var A1_FULL_DAMAGE: int = 20
@export var A2_FULL_DAMAGE: int = 10


func _ready() -> void:
	super._ready()


### PASSIVE ###

func _layfe_passive() -> void:
	deactivate_passive_timer.start()
	passive_count += 1
	if passive_count >= 5:
		current_form = FORM.FULL

func _on_deactivate_passive_timer_timeout() -> void:
	passive_count = 0
	self.current_form = FORM.NEW
	
### --- ###


func _process(delta: float) -> void:
	super._process(delta)
	
	if STARRY_CLOAK_ACTIVE:
		# I also wanna experiment with just straight spinning around but this works for now
		var full_a2_rot = Vector2(cos(starry_cloak_sprite.rotation), sin(starry_cloak_sprite.rotation))
		full_a2_rot = full_a2_rot.move_toward(aim_dir, STARRY_CLOAK_ROT_SPEED * delta)
		starry_cloak_sprite.rotation = full_a2_rot.angle()
		starry_cloak_sprite_2.rotation = full_a2_rot.angle()


func _basic_ranged_attack():
	super._basic_ranged_attack()
	if STARRY_CLOAK_ACTIVE:
		projectile_spawner._fire_projectile(self, 1, _calc_damage(A2_FULL_DAMAGE), aim.rotation + PI/4, 9999)
		projectile_spawner._fire_projectile(self, 1, _calc_damage(A2_FULL_DAMAGE), aim.rotation - PI/4, 9999)
		if ULT_ACTIVE:
			projectile_spawner._fire_projectile(self, 1, _calc_damage(A2_FULL_DAMAGE), aim.rotation + PI/2, 9999)
			projectile_spawner._fire_projectile(self, 1, _calc_damage(A2_FULL_DAMAGE), aim.rotation - PI/2, 9999)
	_layfe_passive() # Only increments when using basic attacks. Should also increment on abilities?


func _dash(movement_dir: Vector2):
	if current_form == FORM.FULL:
		current_form = FORM.NEW
		self.passive_count = 0
	else:
		current_form = FORM.FULL
	
	print(current_form)
	
	_set_effect('SLOW', self, self, false, DASH_WINDUP_DURATION)
	
	await get_tree().create_timer(DASH_WINDUP_DURATION).timeout
	
	self.global_position += movement_dir.normalized() * (STATS.DASH_SPEED/4)
	
	await get_tree().create_timer(STATS.DASH_COOLDOWN - DASH_WINDUP_DURATION).timeout
	CAN_DASH = true


func _A1() -> void:
	match current_form:
		FORM.FULL:
			print('full a1')
			deactivate_passive_timer.start() # Using FUll Moon abilities keeps passive in Full form?
			
			if ULT_ACTIVE:
				projectile_spawner._fire_melee(self, 0, _calc_damage(A1_FULL_DAMAGE), aim_node.rotation + PI/3)
				await get_tree().create_timer(0.02).timeout
				projectile_spawner._fire_melee(self, 0, _calc_damage(A1_FULL_DAMAGE), aim_node.rotation + PI/2)
				await get_tree().create_timer(0.02).timeout
				projectile_spawner._fire_melee(self, 0, _calc_damage(A1_FULL_DAMAGE), aim_node.rotation + 2*PI/3)
				ULT_ACTIVE = false
			else:
				projectile_spawner._fire_melee(self, 0, _calc_damage(A1_FULL_DAMAGE), aim_node.rotation + PI/2)
			
		FORM.NEW:
			print('new a1')
			CURRENT_NEW_BUFF = NEW_ABILITY_BUFF_TYPE.HASTE
			new_buff_area.monitoring = true
			await get_tree().create_timer(0.1).timeout
			new_buff_area.monitoring = false
	
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true


func _A2() -> void:
	match current_form:
		FORM.FULL:
			print('full a2')
			deactivate_passive_timer.start() # Using FUll Moon abilities keeps passive in Full form?
			
			if ULT_ACTIVE:
				starry_cloak_sprite.show()
				starry_cloak_sprite_2.show()
				STARRY_CLOAK_ACTIVE = true
			else:
				starry_cloak_sprite.show()
				STARRY_CLOAK_ACTIVE = true
			
			_deactivate_A2(STATS.A2_COOLDOWN - 2)
		FORM.NEW:
			print('new a2')
			CURRENT_NEW_BUFF = NEW_ABILITY_BUFF_TYPE.BARRIER
			new_buff_area.monitoring = true
			await get_tree().create_timer(0.1).timeout
			new_buff_area.monitoring = false
	
	await get_tree().create_timer(STATS.A2_COOLDOWN).timeout
	CAN_A2 = true


func _deactivate_A2(uptime: float):
	await get_tree().create_timer(uptime).timeout
	STARRY_CLOAK_ACTIVE = false
	starry_cloak_sprite.hide()
	if ULT_ACTIVE:
		ULT_ACTIVE = false
		starry_cloak_sprite_2.hide()


func _ultimate() -> void:
	match current_form:
		FORM.FULL:
			print('full ult')
			deactivate_passive_timer.start() # Using FUll Moon abilities keeps passive in Full form?
			
			ULT_ACTIVE = true
		FORM.NEW:
			var character_list = GameManager.player_list.duplicate()
			character_list.merge(GameManager.enemy_list, false)
			var ult_targets = character_list
			for target in ult_targets:
				var targetting = ult_targets[target]
				_set_effect('BARRIER', targetting, targetting, false, INF, 3)
				_set_effect('HA', targetting, targetting, true, INF, 2)
				_set_effect('CHICKEN', targetting)
				
			print('new ult')
	
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true


func _new_buff(body: Node2D) -> void:
	print(body)
	if body.is_in_group('player'):
		match CURRENT_NEW_BUFF:
			NEW_ABILITY_BUFF_TYPE.BARRIER:
				_set_effect('BARRIER', body)
			NEW_ABILITY_BUFF_TYPE.HASTE:
				_set_effect('HASTE', body)
