extends Effect

@onready var collision_area: Area2D = $CollisionArea

@export var healing_per_second: int

var victims: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	damage = -healing_per_second


# Override from base class
func _damage() -> void:
	#print(victims)
	for victim in victims:
		if victim.has_method('_take_damage') and victim.is_in_group('character'):
			victim._take_damage(self.damage)


func _on_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('character'):
		victims.append(body)

func _on_collision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group('character') and victims.has(body):
		victims.erase(body)
