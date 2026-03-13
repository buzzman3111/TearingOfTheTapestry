class_name Stats 
extends Node

# Stores player information

enum attack_type {RANGED, MELEE}

@export var ATTACK = attack_type.RANGED

@export var SPEED = 300.0
@export var DASH_SPEED = 1000.0
@export var DASH_COOLDOWN = 0.75

@export var ATTACK_COOLDOWN = 0.5
@export var PROJECTILE_RANGE = 500.0
@export var PROJECTILE_SPEED = 1000.0
@export var PROJECTILE_DAMAGE = 1.0

@export var A1_COOLDOWN = 1.0
@export var A2_COOLDOWN = 1.0

# Eventually change this from cooldown to 'charge' system or something
@export var ULT_COOLDOWN = 10.0
