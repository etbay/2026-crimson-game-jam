extends Node3D
class_name TutorialBullet

@export var speed: float = 5.0

var direction: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
