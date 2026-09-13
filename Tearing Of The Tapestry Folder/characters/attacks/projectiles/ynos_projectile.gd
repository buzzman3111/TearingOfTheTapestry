extends Projectile

const effect_setters := {
	"SLOW": preload("res://effects/speed.tscn")
}

func _ready() -> void:
	super._ready()
	IS_PIERCING = true


func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group('player')) and (body.name != 'YnosOnos'):
		print('hit: ', body.name)
		print('owner: ', owner)
		body._take_damage(roundf(DAMAGE))
		
		var slow = body.find_child('SLOW')
		if slow:
			slow._add_stacks(1)
		else:
			var new_SLOW = effect_setters.get('SLOW').instantiate()
			new_SLOW.name = 'SLOW'
			body.add_child(new_SLOW)
			new_SLOW.owner = body
