extends Effect

@onready var collision_area: Area2D = $CollisionArea

@export var healing_per_second: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	damage = -healing_per_second


# Override from base class
func _damage() -> void:
	var victims = collision_area.get_overlapping_bodies()
	#print(victims)
	for victim in victims:
		if victim.has_method('_take_damage') and victim.is_in_group('character'):
			victim._take_damage(self.damage)
