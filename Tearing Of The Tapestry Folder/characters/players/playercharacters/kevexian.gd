extends PlayerBase

var move_dir: Vector2

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	self.move_dir = get_real_velocity().normalized()

func _A1() -> void:
	print('Kevexian A1')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true

func _A2() -> void:
	print('Kevexian A2')
	await get_tree().create_timer(STATS.A2_COOLDOWN).timeout
	CAN_A2 = true

func _ultimate() -> void:
	print('Kevexian Ult')
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true
