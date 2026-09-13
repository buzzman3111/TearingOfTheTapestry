class_name CharacterBase # For all things that are alive and can move and attack
extends CharacterBody2D

var IS_CHICKEN = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add this to a level setup function when this character is added to a level
	if self.is_in_group('player'):
		GameManager.player_list[self.name] = self
	if self.is_in_group('enemy'):
		GameManager.enemy_list[self.name] = self


func _set_effect(
effect_name: String, 
target,
effect_owner = null,
does_damage: bool = false, 
unique_duration: float = INF,
unique_stacks: int = 1
	) -> void:
	
	if effect_owner == null:
		effect_owner = target
	
	var effect = target.find_child(effect_name)
	
	if effect:
		effect._add_stacks(unique_stacks)
		if unique_duration != INF:
			effect.effect_duration += unique_duration
	else:
		var new_effect = self.effect_setters.get(effect_name).instantiate()
		
		if unique_duration != INF:
			new_effect.effect_duration = unique_duration
		
		new_effect.effect_owner = effect_owner
		new_effect.effect_name = effect_name
		
		target.add_child(new_effect)
		
		if does_damage:
			GameManager.connect('damage_tick', new_effect._damage)


func _die() -> void:
	print(self.name, ' ate shit')
	GameManager.player_list.erase(self.name)
	self.queue_free()


func _update_chicken() -> void:
	if IS_CHICKEN == false:
		IS_CHICKEN = true
	else:
		IS_CHICKEN = false
