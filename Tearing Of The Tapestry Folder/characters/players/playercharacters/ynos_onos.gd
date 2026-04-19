extends PlayerBase

@export var BI_setter: PackedScene 		# Change to preload() for performance ?
@export var HA_setter: PackedScene 		# Change to preload() for performance ?

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
	
	super._ready()


func _physics_process(delta: float) -> void:
	if IS_CLONE:
		var aim_dir = Vector2(0,0)
		
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
		super._physics_process(delta)



func _update_clone_pos(delta: float, move_dir: Vector2) -> void:
	if move_dir.length() > DEADZONE:
		last_move_dir = move_dir
		move_dir = move_dir.normalized()
	else:
		move_dir = last_move_dir.normalized()
	
	var pos = (Vector2(move_dir.x, move_dir.y) if clone_ind == 1 
		else Vector2(-move_dir.x, -move_dir.y))
	
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
	var level_children = get_tree().current_scene.get_children()
	
	var nearest_player_pos: Vector2 = Vector2.INF
	var nearest_player: CharacterBody2D = null
	
	for child in level_children: 	# For each child in the level, (should def find a way to optimize this)
		if _is_valid_A1_target(child): 	  # If that is a player characer and isnt Ynos,
			var child_rel_pos = self.global_position - child.global_position 	# Note the distance from Ynos to that player
			if child_rel_pos.length() < nearest_player_pos.length(): 	# Then if that distance is less than the current marked nearst player,
				nearest_player_pos = child_rel_pos 	  # Note this child's position and
				nearest_player = child 	  # Mark this child as the new nearest player
	
	if nearest_player == null:
		print('no valid Ynos A1 target found')
		return
	
	# Then give that nearest player a BI stack
	var BI = nearest_player.find_child('BI')
	# I would like to eventually change this into a function that sets any effect
	if BI:
		BI._add_stacks(nearest_player)
	else:
		var new_BI = BI_setter.instantiate()
		new_BI.name = 'BI'
		nearest_player.add_child(new_BI)
		new_BI.owner = nearest_player
	
	print('gave 1 BI to: ', nearest_player.name)
	
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true



## Give self 1 Healing Aura stack
func _A2() -> void:
	print('Ynos A2')
	
	var HA = self.find_child('HA')
	if HA:
		if IS_CLONE:
			HA._add_stacks(self.owner)
		else:
			HA._add_stacks(self)
	else:
		var new_HA = HA_setter.instantiate()
		new_HA.name = 'HA'
		GameManager.damage_tick.connect(new_HA._damage)
		self.add_child(new_HA)
		if IS_CLONE:
			new_HA.owner = self.owner
		else:
			new_HA.owner = self
	
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true


## Create 2 clones of self with same control inputs as self
func _ultimate() -> void:
	print("Ynos Ult")
	if not IS_CLONE:
		var new_ynos_close_1 = ynos_scene.instantiate()
		var new_ynos_close_2 = ynos_scene.instantiate()
		new_ynos_close_1.position = Vector2(150, 0)
		new_ynos_close_2.position = Vector2(-150, 0)
		new_ynos_close_1.IS_CLONE = true
		new_ynos_close_2.IS_CLONE = true
		new_ynos_close_1.player_index = self.player_index
		new_ynos_close_2.player_index = self.player_index
		new_ynos_close_1.using_controller = self.using_controller
		new_ynos_close_2.using_controller = self.using_controller
		new_ynos_close_1.clone_ind = 0
		new_ynos_close_2.clone_ind = 1
		new_ynos_close_1.name = 'YnosClone1'
		new_ynos_close_2.name = 'YnosClone2'
		self.add_child(new_ynos_close_1)
		self.add_child(new_ynos_close_2)
		new_ynos_close_1.owner = self
		new_ynos_close_2.owner = self
	
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true


func _on_clone_timer_timeout() -> void:
	self.queue_free()


func _take_damage(amount: int) -> void:
	if !IS_CLONE:
		var barrier = self.find_child('Barrier')
		if barrier:
			print('nuh uh')
			barrier.queue_free()
		else:
			STATS.HP -= amount
			if STATS.HP > STATS.MAX_HP:
				STATS.HP = STATS.MAX_HP
			print('took ', amount, ' damage. HP=', STATS.HP)
			if STATS.HP <= 0:
				self._die()
