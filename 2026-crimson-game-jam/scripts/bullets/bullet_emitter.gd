class_name BulletEmitter extends Node3D

@export var pattern : BulletPattern
var _timer : float = 0

func set_pattern(pat : BulletPattern):
	pattern = pat
	_timer = 0

func _process(delta: float) -> void:
	_timer += delta
	if (not pattern._active and not pattern._finished and _timer >= pattern.delay_time):
		pattern.execute(Vector2(global_position.x, global_position.z))
	if (pattern._active):
		pattern.increment_pattern(delta)
