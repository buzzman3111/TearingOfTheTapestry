extends PlayerBase


func _ready() -> void:
	super._ready()


func _A1(effect_strength: float = 1.0, effect_amount: int = 0) -> void:
	print('Ynos A1')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true

func _A2(effect_strength: float = 1.0, effect_amount: int = 0) -> void:
	print('Ynos A2')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true

func _ultimate(effect_strength: float = 1.0, effect_amount: int = 0) -> void:
	print('Ynos Ult')
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true
