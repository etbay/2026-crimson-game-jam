class_name RingPattern extends BulletPattern

# --- Ring shape ---
@export var bullet_count: int = 16            # bullets per ring
@export var start_angle_deg: float = 0.0      # where the first bullet points
@export var arc_deg: float = 360.0            # 360 = full ring, less = fan/arc
@export var spawn_radius: float = 0.0         # offset from emitter center
@export var angle_step_deg: float = 0.0       # rotate each ring by this much to spiral out, keep going

var _timer: float = 0.0
var _rings_fired: int = 0
var _current_offset: float = 0.0

func increment_pattern(delta : float) -> void:
	if not _active or _finished:
		return
	_timer += delta
	if _timer > fire_interval:
		_fire_burst()
		_timer = 0
		if volley_count >= 0 and _rings_fired >= volley_count:
			_active = false
			_finished = true

func _fire_burst():
	_rings_fired += 1
	var start := deg_to_rad(start_angle_deg + _current_offset)
	var arc := deg_to_rad(arc_deg)
	# Full circle: divide by count so the last bullet doesn't overlap the first.
	# Partial arc: divide by count - 1 so both ends get a bullet.
	var is_full := is_equal_approx(arc_deg, 360.0)
	var divisions := bullet_count if (is_full or bullet_count < 2) else bullet_count - 1
	var step := arc / divisions

	for i in bullet_count:
		var angle := start + step * i
		var pos2d := Vector2.from_angle(angle)
		var pos := Vector3(_spawn_pos.x, 0.5, _spawn_pos.y) + Vector3(pos2d.x, 0, pos2d.y) * spawn_radius
		var b := BulletPool.instance.get_bullet()
		b.define_bullet_from_data(bullet_data)
		b.position = pos
		b.angle = angle

	_current_offset += angle_step_deg

func execute(position : Vector2):
	if (not _active):
		_active = true
		_spawn_pos = position
