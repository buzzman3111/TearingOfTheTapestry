extends PlayerBase

var move_dir: Vector2

enum KaKesMelee {A1, Ult1, Ult2, Ult3, Ult4}

@export var A1_damage = 5.0
@export var A2_duration := 1.0

var CAN_BACKSTAB := false

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	self.move_dir = get_real_velocity().normalized()


func _A1() -> void:
	projectile_spawner._fire_melee(self, KaKesMelee.A1, A1_damage)
	print('Ka Kes A1')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true

func _A2() -> void:
	TARGETABLE = false
	CAN_BACKSTAB = true
	await get_tree().create_timer(A2_duration).timeout
	if CAN_BACKSTAB == true:
		CAN_BACKSTAB = false
	
	print('Ka Kes A2')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true

func _ultimate() -> void:
	print('Ka Kes Ult')
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true
