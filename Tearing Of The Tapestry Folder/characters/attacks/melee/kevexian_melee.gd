class_name Melee
extends Node2D

# General-use melee attack object

var DURATION: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('kevin swoosh!')
	_expire()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	### Check for collision ###
	
	pass


func _expire() -> void:
	await get_tree().create_timer(self.DURATION).timeout
	self.queue_free()
