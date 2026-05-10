extends Projectile

func _ready() -> void:
	super._ready()
	IS_PIERCING = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if (
		body.is_in_group('character')
		and body != OWNER
		and (
			((OWNER.get('IS_CLONE') == true) and (body.name != 'YnosOnos'))
			or ((OWNER.get('IS_CLONE') != true))
		)
	):
		print('hit: ', body.name)
		print('owner: ', OWNER)
		body._take_damage(roundf(DAMAGE))
