class_name RingPattern extends BulletPattern

# --- Ring shape ---
@export var bullet_count: int = 16            # bullets per ring
@export var start_angle_deg: float = 0.0      # where the first bullet points
@export var arc_deg: float = 360.0            # 360 = full ring, less = fan/arc
@export var spawn_radius: float = 0.0         # offset from emitter center
@export var angle_step_deg: float = 0.0       # rotate each ring by this much to spiral out, keep going
@export var heading_offset_deg: float = 0.0    # tilts each bullet's heading away from straight outward (+/- swirl)
@export_range(0.0, 180.0) var max_inward_deg: float = 90.0
