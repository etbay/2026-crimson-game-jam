class_name BulletData extends Resource

# --- Bullet properties ---
@export var bullet_speed: float = 150.0       # pixels/second
@export var bullet_accel: float = 0.0         # speed change per second
@export var bullet_turn_rate_deg: float = 0.0 # degrees/second (curving)
@export var bullet_turn_rate_accel: float = 0.0
@export var bullet_size: float = 4.0
@export var bullet_lifetime: float = -1.0     # -1 = until offscreen
