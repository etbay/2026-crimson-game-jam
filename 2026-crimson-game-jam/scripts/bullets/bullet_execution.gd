class_name BulletExecution extends Node

var pat: BulletPattern = null
var _spawn_pos: Vector2 = Vector2.ZERO

var _active: bool = false
var _finished: bool = false
var _volleys_fired: int = 0
var _timer: float = 0.0
var _bullets_spawned: int = 0
var _started: bool = false

func _init(pattern: BulletPattern = null, spawn: Vector2 = Vector2.ZERO):
	pat = pattern
	_spawn_pos = spawn
	_timer = 0

func execute() -> void:
	if (not _active):
		_active = true

func _ready() -> void:
	pass

func increment_pattern(delta : float, center: Vector2) -> void:
	if not _active or _finished:
		return
	_timer += delta
	if _timer < pat.delay_time and !_started:
		return
	if _timer > pat.fire_interval or !_started:
		_started = true
		if (pat.volley_count <= 0):
			_active = false
			_finished = true
			return
		_volleys_fired += 1
		_fire_burst(center)
		_timer = 0
		if pat.volley_count >= 0 and _volleys_fired >= pat.volley_count:
			_active = false
			_finished = true

func _fire_burst(center: Vector2):
	if (pat is RingPattern):
		_ring_burst(center)
	if (pat is LinePattern):
		_line_burst(center)

func _line_burst(_center: Vector2):
	var linepat = pat as LinePattern
	var travel: float = deg_to_rad(linepat.travel_angle_deg + linepat.angle_step_deg * _volleys_fired)
	var forward := Vector2.from_angle(travel)
	var axis := Vector2.from_angle(travel + PI / 2.0 + deg_to_rad(linepat.tilt_deg))

	var line_origin: Vector2 = _spawn_pos + forward * linepat.spawn_distance \
			+ axis * (linepat.sideways_offset + linepat.offset_step * _volleys_fired)

	var total_length: float = linepat.spacing * (linepat.bullet_count - 1)
	var start: Vector2 = line_origin - axis * (total_length * 0.5) if linepat.centered else line_origin

	var gap_from = _gap_start(_volleys_fired)

	for i in linepat.bullet_count:
		if linepat.gap_enabled and _in_gap(i, gap_from):
			continue

		var t : float = float(i) / max(linepat.bullet_count - 1, 1)          # 0..1 across the line
		var pos: Vector2 = start + axis * (linepat.spacing * i)
		var angle: float = travel + deg_to_rad(linepat.spread_deg * (t - 0.5))
		#var pos2d := Vector2.from_angle(angle)
		var b := BulletPool.instance.get_bullet()
		b.define_bullet_from_data(linepat.bullet_data)
		b.position = Vector3(pos.x, 0.5, pos.y)
		b.angle = angle
		b._initial_angle = b.angle
		b.bullet_owner = "Enemy"
		b.max_angle_deg = linepat.max_angle_deg
		if (not linepat.center_end_speed_mult):
			b.speed = ((linepat.end_speed_multiplier * (float(i) / linepat.bullet_count)) + 1) * b.speed
		else:
			b.speed = (linepat.end_speed_multiplier * (abs((linepat.bullet_count / 2.0) - float(i)) / (linepat.bullet_count / 2)) + 1) * b.speed
		_bullets_spawned += 1
		if (linepat.deterministic and (_bullets_spawned + linepat.offset_frequency) % linepat.parryable_frequeuncy == 0):
			b.parryable = true
		elif (not linepat.deterministic and randi_range(0, linepat.parryable_frequeuncy) == 0):
			b.parryable = true
		b.update_sprite()


func _gap_start(_v_fired: int) -> int:
	var linepat = pat as LinePattern
	if linepat.random_gap:
		var rng := RandomNumberGenerator.new()
		rng.seed = linepat.random_seed + _v_fired                    # deterministic per shot
		return rng.randi_range(0, max(linepat.bullet_count - linepat.gap_size, 0))
	return linepat.gap_start_index + linepat.gap_step * _v_fired


func _in_gap(i: int, gap_from: int) -> bool:
	# Wrap so a sweeping gap loops around the line instead of vanishing off the end
	var linepat = pat as LinePattern
	var wrapped := posmod(i - gap_from, linepat.bullet_count)
	return wrapped < linepat.gap_size
	
func _ring_burst(_center: Vector2):
	var ringpat = pat as RingPattern
	var start := deg_to_rad(ringpat.start_angle_deg + (ringpat.angle_step_deg * _volleys_fired))
	var arc := deg_to_rad(ringpat.arc_deg)
	var is_full := is_equal_approx(ringpat.arc_deg, 360.0)
	var divisions: int = ringpat.bullet_count if (is_full or ringpat.bullet_count < 2) else ringpat.bullet_count - 1
	var step := arc / divisions

	# Clamp the heading tilt so bullets can't point further inward than allowed
	var offset_deg := clampf(ringpat.heading_offset_deg, -ringpat.max_inward_deg, ringpat.max_inward_deg)
	var heading_offset := deg_to_rad(offset_deg)

	for i in ringpat.bullet_count:
		var angle : float = start + step * i                 # where the bullet spawns on the ring
		var pos2d := Vector2.from_angle(angle)
		var pos: Vector3 = Vector3(_spawn_pos.x, 0.5, _spawn_pos.y) + Vector3(pos2d.x, 0, pos2d.y) * ringpat.spawn_radius
		var b := BulletPool.instance.get_bullet()
		b.define_bullet_from_data(ringpat.bullet_data)
		b.position = pos
		b.angle = angle + heading_offset                     # where it travels
		b._initial_angle = b.angle
		b.bullet_owner = "Enemy"
		b.max_angle_deg = ringpat.max_inward_deg
		_bullets_spawned += 1
		if (ringpat.deterministic and (_bullets_spawned + ringpat.offset_frequency) % ringpat.parryable_frequeuncy == 0):
			b.parryable = true
		elif (not ringpat.deterministic and randi_range(0, ringpat.parryable_frequeuncy) == 0):
			b.parryable = true
		b.update_sprite()
