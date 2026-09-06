extends Melee

func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group('player')) and (body != owner):
		print('hit: ', body)
		print('owner: ', owner)
		body._take_damage(self.DAMAGE)
		owner._take_damage(-self.DAMAGE) # Track down owner vs OWNER issue
