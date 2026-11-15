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
