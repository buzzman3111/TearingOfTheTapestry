class_name Stats 
extends Node

### Stores player information

enum attack_type {RANGED, MELEE, NONE}

@export var ATTACK = attack_type.NONE

# Basics
@export var HP = 100
@export var mana = 100 # ?

# Stacking effects tracker
@export var burn = 0
@export var holy_burn = 0
@export var bleed = 0
@export var healing_aura = 0
@export var barrier = 0
@export var chicken = false

# Player stats tracker
@export var SPEED = 300.0
@export var DASH_SPEED = 1000.0
@export var DASH_COOLDOWN = 0.75

@export var ATTACK_COOLDOWN = 0.5
@export var PROJECTILE_RANGE = 500.0
@export var PROJECTILE_SPEED = 1000.0
@export var PROJECTILE_DAMAGE = 1.0

@export var A1_COOLDOWN = 1.0
@export var A2_COOLDOWN = 1.0
@export var ULT_COOLDOWN = 10.0 # Eventually change this to 'charge' system or something
