extends PlayerBase

@onready var deactivate_passive_timer: Timer = $DeactivatePassiveTimer
@onready var starry_cloak_sprite: Sprite2D = $StarryCloakSprite
@onready var aim: Node2D = $Aim

@export var SLOW_setter: PackedScene # Change to preload() for performance ?

enum FORM {FULL, NEW}
var current_form = FORM.FULL
var STARRY_CLOAK_ACTIVE: bool = false
var passive_count: int = 0

const DASH_WINDUP_DURATION: float = 0.25
const STARRY_CLOAK_ROT_SPEED: float = 20.0

@export var A1_FULL_DAMAGE: int = 20
@export var A2_FULL_DAMAGE: int = 10


func _ready() -> void:
	super._ready()
	starry_cloak_sprite.hide()


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


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if STARRY_CLOAK_ACTIVE:
		# I also wanna experiment with just straight spinning around but this works for now
		var full_a2_rot = Vector2(cos(starry_cloak_sprite.rotation), sin(starry_cloak_sprite.rotation))
		full_a2_rot = full_a2_rot.move_toward(aim_dir, STARRY_CLOAK_ROT_SPEED * delta)
		starry_cloak_sprite.rotation = full_a2_rot.angle()


func _basic_ranged_attack():
	super._basic_ranged_attack()
	if STARRY_CLOAK_ACTIVE:
		projectile_spawner._fire_projectile(self, 1, _calc_damage(A2_FULL_DAMAGE), aim.rotation + PI/4, 9999)
		projectile_spawner._fire_projectile(self, 1, _calc_damage(A2_FULL_DAMAGE), aim.rotation - PI/4, 9999)
	_layfe_passive() # Only increments when using basic attacks. Should also increment on abilities?


func _dash(movement_dir: Vector2):
	if current_form == FORM.FULL:
		current_form = FORM.NEW
		self.passive_count = 0
	else:
		current_form = FORM.FULL
	
	print(current_form)
	var slow = self.find_child('SLOW')
	if slow:
		slow._add_stacks(self)
		slow.effect_duration += DASH_WINDUP_DURATION
	else:
		var new_SLOW = SLOW_setter.instantiate()
		new_SLOW.name = 'SLOW'
		new_SLOW.effect_duration = DASH_WINDUP_DURATION
		self.add_child(new_SLOW)
		new_SLOW.owner = self
	
	await get_tree().create_timer(DASH_WINDUP_DURATION).timeout
	
	self.global_position += movement_dir.normalized() * (STATS.DASH_SPEED/4)
	
	await get_tree().create_timer(STATS.DASH_COOLDOWN - DASH_WINDUP_DURATION).timeout
	CAN_DASH = true


func _A1() -> void:
	match current_form:
		FORM.FULL:
			print('full a1')
			deactivate_passive_timer.start() # Using FUll Moon abilities keeps passive in Full form?
			projectile_spawner._fire_melee(self, 0, _calc_damage(A1_FULL_DAMAGE), aim_node.rotation + PI/2)
		FORM.NEW:
			print('new a1')
			
	
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true


func _A2() -> void:
	match current_form:
		FORM.FULL:
			print('full a2')
			
			starry_cloak_sprite.show()
			STARRY_CLOAK_ACTIVE = true
			
			deactivate_passive_timer.start() # Using FUll Moon abilities keeps passive in Full form?
		FORM.NEW:
			print('new a2')
	
	await get_tree().create_timer(STATS.A2_COOLDOWN).timeout
	CAN_A2 = true


func _ultimate() -> void:
	match current_form:
		FORM.FULL:
			print('full ult')
			deactivate_passive_timer.start() # Using FUll Moon abilities keeps passive in Full form?
		FORM.NEW:
			print('new ult')
	
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true
