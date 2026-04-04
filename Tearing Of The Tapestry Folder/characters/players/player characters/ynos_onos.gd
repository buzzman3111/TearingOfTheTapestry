extends PlayerBase

@export var BI_setter: PackedScene 		# Change to preload() for performance ?
@export var clone_setter: PackedScene	# Change to preload() for performance ?

var IS_CLONE: bool = false

@onready var clone_timer: Timer = $CloneTimer


func _ready() -> void:
	if self.IS_CLONE == true:
		clone_timer.start()
	
	super._ready()


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



## Find nearest player and give them a BI stack
func _A1() -> void:
	print('Ynos A1')
	var level_children = self.get_parent().get_children()
	
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
	
	if BI:
		BI._add_stacks()
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
	await get_tree().create_timer(STATS.A1_COOLDOWN).timeout
	CAN_A2 = true


## Create 2 clones of self with same control inputs as self
func _ultimate() -> void:
	print('Ynos Ult')
	
	var new_ynos_close_1 = clone_setter.instantiate()
	var new_ynos_close_2 = clone_setter.instantiate()
	new_ynos_close_1.position += self.global_position + Vector2(100, 0)
	new_ynos_close_2.position += self.global_position - Vector2(100, 0)
	new_ynos_close_1.IS_CLONE = true
	new_ynos_close_2.IS_CLONE = true
	new_ynos_close_1.player_index = self.player_index
	new_ynos_close_2.player_index = self.player_index
	new_ynos_close_1.using_controller = self.using_controller
	new_ynos_close_2.using_controller = self.using_controller
	new_ynos_close_1.name = 'YnosClone1'
	new_ynos_close_2.name = 'YnosClone2'
	self.get_parent().add_child(new_ynos_close_1)
	self.get_parent().add_child(new_ynos_close_2)
	
	await get_tree().create_timer(STATS.ULT_COOLDOWN).timeout
	CAN_ULT = true


func _on_clone_timer_timeout() -> void:
	self.queue_free()
	#pass


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
