extends CharacterBody2D
class_name CharacterBase

@export var player_index = 0

# Replace with attack object
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var attack_sprite: Sprite2D = $RayCast2D/AttackSprite
@onready var PS: Node = $PlayerStats

const DEADZONE = 0.5
const DASH_DECAY = 2000

var CAN_ATTACK = true
var CAN_DASH = true
var IS_ATTACKING = false

# Changed by the movement logic
var dash_vel = Vector2.ZERO

func _ready() -> void:
	attack_sprite.visible = false


func _physics_process(delta: float) -> void:
	# Movement
	# Gets the direction of the left joystick
	var move_dir_x = Input.get_joy_axis(player_index, 0)
	var move_dir_y = Input.get_joy_axis(player_index, 1)
	var move_dir = Vector2(move_dir_x, move_dir_y)
	if move_dir.length() < DEADZONE: # This check adds some deadzone to the joystick
		move_dir = Vector2.ZERO
	var base_vel = move_dir * PS.SPEED
	
	
	# If we can dash and we press dash, we dash
	if (Input.is_joy_button_pressed(player_index, InputMapper.dash_button)
	or (Input.get_joy_axis(player_index, InputMapper.dash_trigger) > 0)) and CAN_DASH:
		CAN_DASH = false
		_dash(move_dir)
	
	# The dash velocity repidly decays over time
	dash_vel = dash_vel.move_toward(Vector2.ZERO, DASH_DECAY*delta)
	
	velocity = base_vel + dash_vel
	
	move_and_slide()
	
	
	# Attacks
	var aim_dir_x = Input.get_joy_axis(player_index, InputMapper.aim_x)
	var aim_dir_y = Input.get_joy_axis(player_index, InputMapper.aim_y)
	var aim_dir = Vector2(aim_dir_x, aim_dir_y)
	if (aim_dir.length() > DEADZONE) and !IS_ATTACKING: # This check adds some deadzone to the joystick
		ray_cast_2d.rotation = aim_dir.angle()
	
	if (Input.get_joy_axis(player_index, InputMapper.attack)) and CAN_ATTACK:
		# CAN_ATTACK and IS_ATTACKING are separate so that we can prevent millisecond attacks
		# 		and lock the attack direction while the attack is going off
		# I'd like to get rid of IS_ATTACKING if possible cuz doing this 
		# 		for abilities will suck to keep track of
		CAN_ATTACK = false
		IS_ATTACKING = true
		_attack()


func _attack():
	_basic_attack()

func _dash(move_dir):
	_basic_dash(move_dir)


# Handles basic attacks
func _basic_attack():
	attack_sprite.visible = true
	await get_tree().create_timer(PS.ATTACK_DURATION).timeout
	
	attack_sprite.visible = false
	IS_ATTACKING = false
	await get_tree().create_timer(PS.ATTACK_COOLDOWN).timeout
	
	CAN_ATTACK = true


# Handles basic dashes
func _basic_dash(move_dir: Vector2):
	dash_vel = move_dir.normalized() * PS.DASH_SPEED
	await get_tree().create_timer(PS.DASH_COOLDOWN).timeout
	CAN_DASH = true
