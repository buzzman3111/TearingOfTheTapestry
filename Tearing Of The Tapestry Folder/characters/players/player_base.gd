class_name PlayerBase
extends CharacterBody2D

# The base code that EACH player will have. Player characters should inherit from 
# 	this class and overwrite their own functions for thier unique actions

@export var player_index = 0

@export var using_controller = true # Debug for keyboard/mouse so I can test w/out controller

@onready var projectile_spawner: ProjectileSpawner = $ProjectileSpawner

@onready var player_sprite: Sprite2D = $PlayerSprite
@export var STATS: Stats
@onready var aim_node: Node2D = $Aim

#@onready var InputMapper: Resource = ResourceLoader.load("res://input_mapper.gd")

const DEADZONE = 0.5
const DASH_DECAY = 2000

var CAN_ATTACK = true
var CAN_DASH = true
var CAN_A1 = true
var CAN_A2 = true
var CAN_ULT = true

# Changed by the movement logic
var dash_vel = Vector2.ZERO


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var move_dir = Vector2(0,0)
	var aim_dir = Vector2(0,0)
	var base_vel = Vector2(0,0)
	
	
	## Controller
	if using_controller: # Controller inputs
		# Gets the direction of the left joystick
		var move_dir_x = Input.get_joy_axis(player_index, JOY_AXIS_LEFT_X)
		var move_dir_y = Input.get_joy_axis(player_index, JOY_AXIS_LEFT_Y)
		move_dir = Vector2(move_dir_x, move_dir_y)
		if move_dir.length() < DEADZONE: # This check adds some deadzone to the joystick
			move_dir = Vector2.ZERO
		base_vel = move_dir * STATS.SPEED
		
		
		# If we can dash and we press dash, we dash
		if (Input.is_joy_button_pressed(player_index, JOY_BUTTON_A)
		or (Input.get_joy_axis(player_index, JOY_AXIS_TRIGGER_LEFT) > 0)) and CAN_DASH:
			CAN_DASH = false
			_dash(move_dir)
		
		
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
	
	## Keyboard/mouse inputs (TEMPORARY, I WANT TO GET RID OF THIS SO BAD BUT ITS SO GOOD FOR WORKING W/OUT A CONTROLLER)
	else:
		# Movement
		var move_dir_x = Input.get_axis('left', 'right')
		var move_dir_y = Input.get_axis('up', 'down')
		move_dir = Vector2(move_dir_x, move_dir_y)
		base_vel = move_dir * STATS.SPEED
		
		if Input.is_action_just_pressed('dash') and CAN_DASH:
			CAN_DASH = false
			_dash(move_dir)
		
		
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
	
	
	# The dash velocity repidly decays over time
	dash_vel = dash_vel.move_toward(Vector2.ZERO, DASH_DECAY*delta)
	velocity = base_vel + dash_vel
	move_and_slide()
	
	
	### Rudementary sprite logic
	if CAN_ATTACK:
		if move_dir.x > 0:
			player_sprite.flip_h = false
		elif move_dir.x < 0:
			player_sprite.flip_h = true
	else:
		if aim_dir.x > 0:
			player_sprite.flip_h = false
		elif aim_dir.x < 0:
			player_sprite.flip_h = true


func _dash(move_dir: Vector2):
	dash_vel = move_dir.normalized() * STATS.DASH_SPEED
	await get_tree().create_timer(STATS.DASH_COOLDOWN).timeout
	CAN_DASH = true


# Chooses melee or ranged basic attack depending on character stats
func _attack():
	var attack = STATS.ATTACK
	
	match attack:
		STATS.attack_type.RANGED:
			_basic_ranged_attack()
		STATS.attack_type.MELEE:
			_basic_melee_attack()
	
	await get_tree().create_timer(STATS.ATTACK_COOLDOWN).timeout
	CAN_ATTACK = true

func _basic_ranged_attack():
	projectile_spawner._fire_projectile(self, 0, _calc_damage(STATS.PROJECTILE_DAMAGE))

func _basic_melee_attack():
	projectile_spawner._fire_melee(self, 0, _calc_damage(STATS.PROJECTILE_DAMAGE))


### Ability base cases (overridden by child scene for full functionality) ###
# Handles ability 1 base
func _A1() -> void:
	print('yarr')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true

# Handles ability 2 base
func _A2() -> void:
	print('matey')
	await get_tree().create_timer(STATS.A2_COOLDOWN).timeout
	CAN_A2 = true

# Handles ult base
func _ultimate() -> void:
	print('RAHHH')
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_A2 = true


func _take_damage(amount: int) -> void:
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


func _die() -> void:
	print('you are dead')
	self.queue_free()


# Checks for effects that increase/decrease attack/ability damage
func _calc_damage(base_value: int) -> int:
	var final_damage = base_value
	var BI = self.find_child('BI')
	if BI:
		final_damage = BI._increase_effect(final_damage)
		BI._on_effect_duration_timeout()
	
	return final_damage
