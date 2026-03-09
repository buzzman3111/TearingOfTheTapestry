extends CharacterBody2D

# Replace with attack object
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var attack_sprite: Sprite2D = $RayCast2D/AttackSprite


# Add to character stats page
@export var SPEED = 300.0
@export var ATTACK_COOLDOWN = 0.2
@export var DASH_COOLDOWN = 0.75
@export var DASH_SPEED = 1000.0

const ATTACK_DURATION = 0.1
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
	# Gets the direction of the left joystick as a Vecctor2
	var move_dir = Input.get_vector('left', 'right', 'up', 'down')
	var base_vel = move_dir * SPEED
	
	# If we can dash and we press dash, we dash
	if Input.is_action_just_pressed('dash') and CAN_DASH:
		CAN_DASH = false
		_dash(move_dir)
	
	# The dash velocity repidly decays over time
	dash_vel = dash_vel.move_toward(Vector2.ZERO, DASH_DECAY*delta)
	
	velocity = base_vel + dash_vel
	
	move_and_slide()
	
	
	# Attacks
	# Gets direction of right joystick as Vector2
	var aim_dir = Input.get_vector('aim_left', 'aim_right', 'aim_up', 'aim_down')
	# This check adds some deadzone to the joystick to prevent unwanted turnarounds
	if (aim_dir.length() > 0.3) and !IS_ATTACKING:
		ray_cast_2d.rotation = aim_dir.angle()
	
	if Input.is_action_just_pressed('attack') and CAN_ATTACK:
		# CAN_ATTACK and IS_ATTACKING are separate so that we can prevent millisecond attacks
		# and lock the attack direction while the attack is going off
		# I'd like to get rid of IS_ATTACKING if possible cuz doing this for abilities will suck
		CAN_ATTACK = false
		IS_ATTACKING = true
		_attack()


# Handles basic attacks
func _attack():
	attack_sprite.visible = true
	await get_tree().create_timer(ATTACK_DURATION).timeout
	
	attack_sprite.visible = false
	IS_ATTACKING = false
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	
	CAN_ATTACK = true


# Handles dashes
func _dash(move_dir: Vector2):
	dash_vel = move_dir * DASH_SPEED
	await get_tree().create_timer(DASH_COOLDOWN).timeout
	CAN_DASH = true
