extends Melee


# General-use melee attack object
const effect_setters := {
	"HOLY BURN": preload("res://effects/holy_burn.tscn")
}

@export var MELEE_DAMAGE: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('kevin swoosh!')
	self.DAMAGE = MELEE_DAMAGE
	_expire()


func _on_hitbox_body_entered(body: Node2D) -> void:
	# This will need to change to enemy eventually
	if (body.is_in_group('enemy')) and (body != owner):
		print('hit: ', body)
		print('owner: ', owner)
		body._take_damage(self.DAMAGE, owner.global_position)
		
		var holy_burn = body.find_child('HOLY BURN')
		if holy_burn:
			holy_burn._add_stacks(1)
		else:
			var new_holy_burn = effect_setters.get('HOLY BURN').instantiate()
			new_holy_burn.name = 'HOLY BURN'
			_apply_holy_burn.call_deferred(body, new_holy_burn)


func _apply_holy_burn(body: Node2D, new_holy_burn: Node) -> void:
	body.add_child(new_holy_burn)
	new_holy_burn.owner = body
