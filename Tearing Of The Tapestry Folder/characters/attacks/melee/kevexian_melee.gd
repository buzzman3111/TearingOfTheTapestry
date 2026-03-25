extends Melee

# General-use melee attack object

#var DURATION: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('kevin swoosh!')
	_expire()


#func _expire() -> void:
	#await get_tree().create_timer(self.DURATION).timeout
	#self.queue_free()
