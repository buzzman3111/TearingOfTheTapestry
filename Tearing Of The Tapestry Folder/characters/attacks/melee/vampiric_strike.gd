extends Melee

func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group('character')) and (body != OWNER):
		print('hit: ', body)
		print('owner: ', OWNER)
		body._take_damage(self.DAMAGE)
		OWNER._take_damage(-self.DAMAGE)
