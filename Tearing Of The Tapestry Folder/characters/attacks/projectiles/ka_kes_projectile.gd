extends Projectile

@export var damage_accumulation_rate := 4.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	DAMAGE += damage_accumulation_rate * delta
