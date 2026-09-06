extends Effect

signal update_chicken

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.update_chicken.connect(owner._update_chicken)
	self.update_chicken.emit()


func _on_effect_duration_timeout() -> void:
	self.update_chicken.emit()
	super._on_effect_duration_timeout()
