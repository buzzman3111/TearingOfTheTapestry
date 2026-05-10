extends PlayerBase

@export var SLOW_setter: PackedScene # Change to preload() for performance ?

enum FORM {FULL, NEW}
var current_form = FORM.FULL

const DASH_WINDUP_DURATION: float = 0.25 

@export var A1_DAMAGE: int = 20

func _dash(move_dir: Vector2):
	if current_form == FORM.FULL:
		current_form = FORM.NEW
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
	
	self.global_position += move_dir.normalized() * (STATS.DASH_SPEED/4)
	
	await get_tree().create_timer(STATS.DASH_COOLDOWN - DASH_WINDUP_DURATION).timeout
	CAN_DASH = true


func _A1() -> void:
	match current_form:
		FORM.FULL:
			print('full a1')
			projectile_spawner._fire_melee(self, 0, _calc_damage(A1_DAMAGE), aim_node.rotation + PI/2)
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
