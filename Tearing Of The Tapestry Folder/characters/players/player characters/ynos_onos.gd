extends PlayerBase


func _ready() -> void:
	super._ready()


func _A1() -> void:
	print('Ynos A1')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true

func _A2() -> void:
	print('Ynos A2')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true

func _ultimate() -> void:
	print('Ynos Ult')
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true
