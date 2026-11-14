
extends Node3D
class_name TutorialBullet

signal near_player

@export var speed: float = 5.0
@export var stop_distance: float = 1.5

var direction: Vector3 = Vector3.ZERO
var player: CharacterBody3D
var stopped: bool = false

func _physics_process(delta: float) -> void:
	if stopped:
		return

	if player != null:
		# Measure horizontal distance to the player
		var distance = Vector2(
			global_position.x,
			global_position.z
		).distance_to(Vector2(
			player.global_position.x,
			player.global_position.z
		))

		if distance <= stop_distance:
			stopped = true
			near_player.emit()
			return

	global_position += direction * speed * delta
