extends CenterContainer


@onready var player_name: Label = $VBoxContainer/Abilities/HBoxContainer/PlayerName
@onready var a_1_icon: TextureRect = $VBoxContainer/Abilities/HBoxContainer/A1Icon
@onready var a_2_icon: TextureRect = $VBoxContainer/Abilities/HBoxContainer/A2Icon
@onready var ult_icon: TextureRect = $VBoxContainer/Abilities/HBoxContainer/UltIcon

@onready var hp_bar: TextureProgressBar = $VBoxContainer/HpBar

var a1_sprites = [preload("res://assets/art/placeholders/a1_active.png"), preload("res://assets/art/placeholders/a1_cd.png")]
var a2_sprites = [preload("res://assets/art/placeholders/a2_active.png"), preload("res://assets/art/placeholders/a2_cd.png")]
var ult_sprites = [preload("res://assets/art/placeholders/ult_active.png"), preload("res://assets/art/placeholders/ult_cd.png")]

var connected_player := CharacterBody2D

func _ready() -> void:
	if connected_player:
		player_name.text = connected_player.name
		connected_player.update_a1_ui.connect(_update_a1)
		connected_player.update_a2_ui.connect(_update_a2)
		connected_player.update_ult_ui.connect(_update_ult)
		connected_player.update_hp_ui.connect(_update_health_bar)


func _update_health_bar(health: int) -> void:
	hp_bar.value = health


func _update_a1() -> void:
	if a_1_icon.texture == a1_sprites[0]:
		a_1_icon.texture = a1_sprites[1]
	else:
		a_1_icon.texture = a1_sprites[0]


func _update_a2() -> void:
	if a_2_icon.texture == a2_sprites[0]:
		a_2_icon.texture = a2_sprites[1]
	else:
		a_2_icon.texture = a2_sprites[0]


func _update_ult() -> void:
	if ult_icon.texture == ult_sprites[0]:
		ult_icon.texture = ult_sprites[1]
	else:
		ult_icon.texture = ult_sprites[0]
