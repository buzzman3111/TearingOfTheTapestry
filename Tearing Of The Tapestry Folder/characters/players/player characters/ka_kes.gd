extends PlayerBase

var move_dir: Vector2

enum KaKesMelee {A1, Ult1, Ult2, Ult3, Ult4}

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	self.move_dir = get_real_velocity().normalized()


func _A1() -> void:
	projectile_spawner._fire_melee(KaKesMelee.A1, self.move_dir.angle())
	print('Ka Kes A1')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true

func _A2() -> void:
	print('Ka Kes A2')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true

func _ultimate() -> void:
	print('Ka Kes Ult')
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true
