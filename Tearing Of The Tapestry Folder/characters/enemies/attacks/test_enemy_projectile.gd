extends Projectile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		print('hit: ', body.name)
		print('owner: ', owner)
		body._take_damage(roundf(DAMAGE))
		
