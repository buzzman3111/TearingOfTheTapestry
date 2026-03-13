class_name PlayerBase
extends CharacterBody2D

# The base code that EACH player will have. Player characters should inherit from 
# 	this class and define their own functions for thier unique actions

@export var player_index = 0

@onready var projectile_spawner: ProjectileSpawner = $ProjectileSpawner
@onready var melee_spawner: MeleeSpawner = $MeleeSpawner

@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var STATS: Node = $PlayerStats
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
	# Movement
	# Gets the direction of the left joystick
	var move_dir_x = Input.get_joy_axis(player_index, JOY_AXIS_LEFT_X)
	var move_dir_y = Input.get_joy_axis(player_index, JOY_AXIS_LEFT_Y)
	var move_dir = Vector2(move_dir_x, move_dir_y)
	if move_dir.length() < DEADZONE: # This check adds some deadzone to the joystick
		move_dir = Vector2.ZERO
	var base_vel = move_dir * STATS.SPEED
	
	
	# If we can dash and we press dash, we dash
	if (Input.is_joy_button_pressed(player_index, JOY_BUTTON_A)
	or (Input.get_joy_axis(player_index, JOY_AXIS_TRIGGER_LEFT) > 0)) and CAN_DASH:
		CAN_DASH = false
		_dash(move_dir)
	
	# The dash velocity repidly decays over time
	dash_vel = dash_vel.move_toward(Vector2.ZERO, DASH_DECAY*delta)
	
	velocity = base_vel + dash_vel
	
	move_and_slide()
	
	
	# Attacks
	var aim_dir_x = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_X)
	var aim_dir_y = Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_Y)
	var aim_dir = Vector2(aim_dir_x, aim_dir_y)
	if aim_dir.length() > DEADZONE: # This check adds some deadzone to the joystick
		aim_node.rotation = aim_dir.angle()
	
	# If we click the attcak button and can attack, we attack
	if (Input.get_joy_axis(player_index, JOY_AXIS_TRIGGER_RIGHT)) and CAN_ATTACK:
		CAN_ATTACK = false
		_attack()
	
	
	# Abilities
	if Input.is_joy_button_pressed(player_index, JOY_BUTTON_X) and CAN_A1:
		CAN_A1 = false
		_A1()
	
	if Input.is_joy_button_pressed(player_index, JOY_BUTTON_B) and CAN_A2:
		CAN_A2 = false
		_A2()
	
	if Input.is_joy_button_pressed(player_index, JOY_BUTTON_Y) and CAN_ULT:
		CAN_ULT = false
		_ultimate()
	
	
	# Rudementary sprite logic
	if CAN_ATTACK:
		if move_dir_x > 0:
			player_sprite.flip_h = false
		elif move_dir_x < 0:
			player_sprite.flip_h = true
	else:
		if aim_dir_x > 0:
			player_sprite.flip_h = false
		elif aim_dir_x < 0:
			player_sprite.flip_h = true


func _dash(move_dir):
	_basic_dash(move_dir)


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
	projectile_spawner._fire(0)

func _basic_melee_attack():
	melee_spawner._slash(0)


# Handles basic dashes
func _basic_dash(move_dir: Vector2):
	dash_vel = move_dir.normalized() * STATS.DASH_SPEED
	await get_tree().create_timer(STATS.DASH_COOLDOWN).timeout
	CAN_DASH = true



# Handles ability 1 base case (overridden by child scene for full functionality)
func _A1() -> void:
	print('yarr')
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A1 = true

# Handles ability 2 base case (overridden by child scene for full functionality)
func _A2() -> void:
	print('matey')
	await get_tree().create_timer(STATS.A2_COOLDOWN).timeout
	CAN_A2 = true

func _ultimate() -> void:
	pass
