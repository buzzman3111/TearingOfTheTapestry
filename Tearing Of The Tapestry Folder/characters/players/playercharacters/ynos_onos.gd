extends PlayerBase

const effect_setters := {
	"BI": preload("res://effects/bardic_inspiration.tscn"),
	"HA": preload("res://effects/healing_aura.tscn")
}

const ynos_scene = preload('res://characters/players/playercharacters/ynos_onos.tscn')

var IS_CLONE: bool = false
var clone_ind: int = 0
var last_move_dir: Vector2 = Vector2.RIGHT

const CLONE_RADIUS: float = 250.0
const CLONE_FOLLOW_LERP: float = 5.0

@onready var clone_timer: Timer = $CloneTimer


func _ready() -> void:
	if self.IS_CLONE == true:
		clone_timer.start()
		if self.is_in_group('player'):
			self.remove_from_group('player')
	
	super._ready()


func _process(delta: float) -> void:
	# I hate this section of code since it's mostly redundant especially with the controller/keyboard distinction 
	# 	Would be nice to change this if possible
	if IS_CLONE:
		
		if using_controller:
			### Attacks
			var aim_dir_x = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_X)
			var aim_dir_y = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_Y)
			aim_dir = Vector2(aim_dir_x, aim_dir_y)
			if aim_dir.length() > DEADZONE: # This check adds some deadzone to the joystick
				aim_node.rotation = aim_dir.angle()
			
			# If we click the attcak button and can attack, we attack
			if (Input.get_joy_axis(player_index, JOY_AXIS_TRIGGER_RIGHT)) and CAN_ATTACK:
				CAN_ATTACK = false
				_attack()
			
			
			### Abilities
			if (Input.is_joy_button_pressed(player_index, JOY_BUTTON_X) or Input.is_joy_button_pressed(player_index, JOY_BUTTON_LEFT_SHOULDER)) and CAN_A1:
				CAN_A1 = false
				_A1()
			
			if (Input.is_joy_button_pressed(player_index, JOY_BUTTON_B) or Input.is_joy_button_pressed(player_index, JOY_BUTTON_RIGHT_SHOULDER)) and CAN_A2:
				CAN_A2 = false
				_A2()
			
			if Input.is_joy_button_pressed(player_index, JOY_BUTTON_Y) and CAN_ULT:
				CAN_ULT = false
				_ultimate()
		else:
			### Attacks
			aim_dir = get_local_mouse_position()
			aim_node.rotation = aim_dir.angle()
			
			if Input.is_action_just_pressed('attack') and CAN_ATTACK:
				CAN_ATTACK = false
				_attack()
			
			if Input.is_action_just_pressed("ability 1") and CAN_A1:
				CAN_A1 = false
				_A1()
			
			if Input.is_action_just_pressed("ability 2") and CAN_A2:
				CAN_A2 = false
				_A2()
			
			if Input.is_action_just_pressed('ultimate') and CAN_ULT:
				CAN_ULT = false
				_ultimate()
		
		_update_clone_pos(delta, aim_dir)
		
			### Rudementary sprite logic
		if CAN_ATTACK:
			if get_parent().velocity.normalized().x > 0:
				player_sprite.flip_h = false
			elif get_parent().velocity.normalized().x < 0:
				player_sprite.flip_h = true
		else:
			if aim_dir.x > 0:
				player_sprite.flip_h = false
			elif aim_dir.x < 0:
				player_sprite.flip_h = true
		
	else:
		super._process(delta)


# Only works well for controller
func _update_clone_pos(delta: float, movement_dir: Vector2) -> void:
	if movement_dir.length() > DEADZONE:
		last_move_dir = movement_dir
		movement_dir = movement_dir.normalized()
	else:
		movement_dir = last_move_dir.normalized()
	
	var pos = (Vector2(movement_dir.x, movement_dir.y) if clone_ind == 1 
		else Vector2(-movement_dir.x, -movement_dir.y))
	
	position = position.lerp(CLONE_RADIUS * pos, CLONE_FOLLOW_LERP * delta)



func _is_valid_A1_target(character_node) -> bool:
	if (
		character_node.is_in_group('character') 	# If the character is a player character,
		and character_node != self  	# if the character is not the source of the BI,
		and character_node.get_script() != self.get_script() 	 # if the character doesn't use the same script as Ynos (clones can't target Ynos and Ynos can't target clones)
		and ((character_node.get('IS_CLONE') == null) or (character_node.get('IS_CLONE') == false)) 	# if the character isn't a clone
	):
		return true # Valid target
	else:
		return false # Invalid target



### Find nearest player and give them a BI stack
func _A1() -> void:
	print('Ynos A1')
	var nearest_player = _find_nearest_player()
	
	if nearest_player == null:
		print('no valid Ynos A1 target found')
		return
	
	# Then give that nearest player a BI stack
	_set_effect('BI', nearest_player, nearest_player)
	
	print('gave 1 BI to: ', nearest_player.name)
	
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true


func _find_nearest_player():
	var possible_targets = GameManager.player_list
	
	var nearest_target = self
	var nearest_target_pos = Vector2(INF, INF)
	
	for obj_targeting in possible_targets:
		var target = possible_targets[obj_targeting]
		if (target != self) and (target.name != 'YnosOnos'):
			if (self.global_position - target.global_position).length_squared() < nearest_target_pos.length_squared():
				nearest_target_pos = self.global_position - target.global_position
				nearest_target = target
	
	return nearest_target



## Give self 1 Healing Aura stack
func _A2() -> void:
	print('Ynos A2')
	
	if IS_CLONE:
		_set_effect('HA', self, self.owner, true)
	else:
		_set_effect('HA', self, self, true)
	
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true


## Create 2 clones of self with same control inputs as self
func _ultimate() -> void:
	print("Ynos Ult")
	if not IS_CLONE:
		_instantiate_clone(0)
		_instantiate_clone(1)
	
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true


func _instantiate_clone(clone_index: int) -> void:
	var new_ynos_close = ynos_scene.instantiate()
	var clone_pos = Vector2(150, 0) if clone_index == 1 else Vector2(-150, 0)
	new_ynos_close.clone_ind = clone_index
	new_ynos_close.position = clone_pos
	new_ynos_close.IS_CLONE = true
	new_ynos_close.player_index = self.player_index
	new_ynos_close.using_controller = self.using_controller
	new_ynos_close.name = 'YnosClone' + str(clone_ind)
	self.add_child(new_ynos_close)
	new_ynos_close.owner = self


func _on_clone_timer_timeout() -> void:
	self.queue_free()


func _take_damage(amount: int) -> void:
	if !IS_CLONE:
		super._take_damage(amount)
