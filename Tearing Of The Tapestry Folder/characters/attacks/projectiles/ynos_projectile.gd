extends Projectile

func _on_hitbox_body_entered(body: Node2D) -> void:
	if (
		body.is_in_group('character')
		and body != OWNER
		and (
			(OWNER.get('IS_CLONE') == null) 
			or ((OWNER.get('IS_CLONE') == true) and (body.name != 'YnosOnos'))
		)
	):
		print('hit: ', body)
		print('owner: ', OWNER)
		body._take_damage(roundf(DAMAGE))
