extends PlayerBase

enum FORM {FULL, NEW}
var current_form = FORM.FULL

func _dash(move_dir: Vector2):
	if current_form == FORM.FULL:
		current_form = FORM.NEW
	else:
		current_form = FORM.FULL
	print(current_form)
	dash_vel = move_dir.normalized() * STATS.DASH_SPEED
	await get_tree().create_timer(STATS.DASH_COOLDOWN).timeout
	CAN_DASH = true


func _A1() -> void:
	match current_form:
		FORM.FULL:
			print('full a1')
		FORM.NEW:
			print('new a1')
	
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true


func _A2() -> void:
	match current_form:
		FORM.FULL:
			print('full a2')
		FORM.NEW:
			print('new a2')
	
	await get_tree().create_timer(STATS.A2_COOLDOWN).timeout
	CAN_A2 = true


func _ultimate() -> void:
	match current_form:
		FORM.FULL:
			print('full ult')
		FORM.NEW:
			print('new ult')
	
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true
