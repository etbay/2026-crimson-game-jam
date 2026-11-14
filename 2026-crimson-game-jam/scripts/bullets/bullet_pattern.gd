@abstract class_name BulletPattern extends Resource

@export var delay_time : float = 0
@export var bullet_data : BulletData
@export var fire_interval: float = 0.5        # seconds between rings
@export var volley_count: int = 3 #repetitions to fire
@export var parryable_frequeuncy: int = 1

var _spawn_pos : Vector2 = Vector2.ZERO
var _active: bool = false
var _finished: bool = false
var _volleys_fired: int = 0
var _timer: float = 0.0


@abstract func increment_pattern(delta : float) -> void

func execute(position : Vector2) -> void:
	if (not _active):
		_active = true
		_spawn_pos = position
