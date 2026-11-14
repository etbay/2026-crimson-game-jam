
extends Node3D
class_name TutorialBullet

signal near_player

@export var start_speed: float = 18.0
@export var end_speed: float = 1.5
@export var slowdown_distance: float = 6.0
@export var stop_distance: float = 1.5

var current_speed: float
var direction: Vector3 = Vector3.ZERO
var player: Player
var stopped: bool = false


func _ready() -> void:
	current_speed = start_speed


func _physics_process(delta: float) -> void:
	if stopped:
		return

	if player != null:
		# Calculate horizontal distance to player
		var distance = Vector2(
			global_position.x,
			global_position.z
		).distance_to(Vector2(
			player.global_position.x,
			player.global_position.z
		))

		# Stop when close enough to parry
		if distance <= stop_distance:
			stopped = true
			near_player.emit()
			return

		# Start slowing down near the player
		if distance <= slowdown_distance:
			var progress = inverse_lerp(
				stop_distance,
				slowdown_distance,
				distance
			)

			# Smooth the transition between speeds
			progress = smoothstep(0.0, 1.0, progress)

			current_speed = lerp(
				end_speed,
				start_speed,
				progress
			)
		else:
			current_speed = start_speed

		# Prevent bullet from overshooting
		var movement = min(
			current_speed * delta,
			distance - stop_distance
		)

		global_position += direction * movement

	else:
		global_position += direction * start_speed * delta
