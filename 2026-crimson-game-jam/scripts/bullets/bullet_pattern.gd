@abstract class_name BulletPattern extends Resource

@export var delay_time : float = 0
@export var bullet_data : BulletData
@export var fire_interval: float = 0.5        # seconds between rings
@export var volley_count: int = 3 #rings to fire
var _spawn_pos : Vector2 = Vector2.ZERO

var _active: bool = false
var _finished: bool = false

@abstract func increment_pattern(delta : float) -> void

@abstract func execute(position : Vector2) -> void
