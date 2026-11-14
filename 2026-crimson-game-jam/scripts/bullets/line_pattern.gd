class_name LinePattern extends BulletPattern

# --- Line shape ---
@export var bullet_count: int = 20
@export var spacing: float = 24.0             # pixels between bullets along the line
@export var centered: bool = true             # true = line centered on spawn point, false = starts at it

# --- Direction ---
@export var travel_angle_deg: float = 90.0    # direction the wall moves (90 = down)
@export var tilt_deg: float = 0.0             # rotates the line itself without changing travel direction (diagonal wall)
@export var spread_deg: float = 0.0           # total angle fanned across the line (0 = parallel bullets)

# --- Placement ---
@export var spawn_distance: float = 0.0       # offset along the travel direction (spawn ahead/behind origin)
@export var sideways_offset: float = 0.0      # offset along the line axis

# --- Speed across the line ---
@export var end_speed_multiplier: float = 1.0 # speed of the last bullet relative to the first (1 = uniform)
@export var center_end_speed_mult: bool = true

# --- Gap (makes the wall dodgeable) ---
@export var gap_enabled: bool = false
@export var gap_size: int = 3                 # bullets omitted
@export var gap_start_index: int = 8          # first omitted bullet on shot 0
@export var gap_step: int = 0                 # gap shifts this many bullets per shot (sweeping gap)
@export var random_gap: bool = false          # pick gap position randomly per shot
@export var random_seed: int = 0              # keeps random gaps repeatable

# --- Per-shot change (walls that sweep or rotate) ---
@export var angle_step_deg: float = 0.0       # rotate travel direction each shot
@export var random_angle_change: bool = false
@export var offset_step: float = 0.0          # slide the line sideways each shot

var _bullets_spawned: int = 0

func increment_pattern(delta : float) -> void:
	if not _active or _finished:
		return
	_timer += delta
	if _timer > fire_interval:
		_fire_burst()
		_timer = 0
		if volley_count >= 0 and _volleys_fired >= volley_count:
			_active = false
			_finished = true

func _fire_burst():
	_volleys_fired += 1
	var travel := deg_to_rad(travel_angle_deg + angle_step_deg * _volleys_fired)
	var forward := Vector2.from_angle(travel)
	var axis := Vector2.from_angle(travel + PI / 2.0 + deg_to_rad(tilt_deg))

	var line_origin := _spawn_pos + forward * spawn_distance \
			+ axis * (sideways_offset + offset_step * _volleys_fired)

	var total_length := spacing * (bullet_count - 1)
	var start := line_origin - axis * (total_length * 0.5) if centered else line_origin

	var gap_from := _gap_start()

	for i in bullet_count:
		if gap_enabled and _in_gap(i, gap_from):
			continue

		var t : float = float(i) / max(bullet_count - 1, 1)          # 0..1 across the line
		var pos := start + axis * (spacing * i)
		var angle := travel + deg_to_rad(spread_deg * (t - 0.5))
		var pos2d := Vector2.from_angle(angle)
		var b := BulletPool.instance.get_bullet()
		b.define_bullet_from_data(bullet_data)
		b.position = Vector3(pos.x, 0.5, pos.y)
		b.angle = angle
		if (not center_end_speed_mult):
			b.speed = ((end_speed_multiplier * (float(i) / bullet_count)) + 1) * b.speed
		else:
			b.speed = (end_speed_multiplier * (abs((bullet_count / 2.0) - float(i)) / (bullet_count / 2)) + 1) * b.speed
		_bullets_spawned += 1
		if (_bullets_spawned % parryable_frequeuncy == 0):
			b.parryable = true
		b.update_sprite()


func _gap_start() -> int:
	if random_gap:
		var rng := RandomNumberGenerator.new()
		rng.seed = random_seed + _volleys_fired                    # deterministic per shot
		return rng.randi_range(0, max(bullet_count - gap_size, 0))
	return gap_start_index + gap_step * _volleys_fired


func _in_gap(i: int, gap_from: int) -> bool:
	# Wrap so a sweeping gap loops around the line instead of vanishing off the end
	var wrapped := posmod(i - gap_from, bullet_count)
	return wrapped < gap_size
