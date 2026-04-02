extends PlayerBase

@onready var ult_duration_timer: Timer = $UltDurationTimer


var move_dir: Vector2

enum KaKesMelee {A1, Ult1, Ult2, Ult3, Ult4}

@export var A1_damage := 5
#@export var A2_duration := 1.0
@export var ULT_damage := [5, 10, 20, 40]
@export var ULT_duration := 5.0

@export var BI_setter: PackedScene

#var CAN_BACKSTAB := false
var IS_ULTING: bool = false # Will eventually have form of dread stat changes, so using this controls that
var current_ult_melee: int = 1

func _ready() -> void:
	ult_duration_timer.wait_time = ULT_duration
	super._ready()


# Override for ult melee funcitonality
func _attack():
	if current_ult_melee > 4:
		_on_ult_duration_timeout()
	elif IS_ULTING:
		projectile_spawner._fire_melee(self, current_ult_melee, _calc_damage(ULT_damage[current_ult_melee-1]))
		current_ult_melee += 1
		await get_tree().create_timer(1.0).timeout
	else:
		super._attack()
		
		await get_tree().create_timer(STATS.ATTACK_COOLDOWN).timeout
	
	CAN_ATTACK = true


func _basic_ranged_attack():
	projectile_spawner._fire_projectile(self, 0, _calc_damage(STATS.PROJECTILE_DAMAGE))
	await get_tree().create_timer(0.1).timeout
	projectile_spawner._fire_projectile(self, 0, _calc_damage(STATS.PROJECTILE_DAMAGE))
	await get_tree().create_timer(0.1).timeout
	projectile_spawner._fire_projectile(self, 0, _calc_damage(STATS.PROJECTILE_DAMAGE))


func _A1() -> void:
	projectile_spawner._fire_melee(self, KaKesMelee.A1, _calc_damage(A1_damage))
	print('Ka Kes A1')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true


func _A2() -> void:
	var BI = self.find_child('BI')	# Bardic inspiration
	
	if BI:
		BI._add_stacks()
	else:
		var new_BI = BI_setter.instantiate()
		new_BI.name = 'BI'
		self.add_child(new_BI)
		new_BI.owner = self
	
	print('Ka Kes A2')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true


func _ultimate() -> void:
	print('Ka Kes Ult')
	ult_duration_timer.start()
	IS_ULTING = true


func _on_ult_duration_timeout() -> void:
	print('end ult')
	IS_ULTING = false
	current_ult_melee = 1
	CAN_ULT = true # Add to ult charge logic once implemented
