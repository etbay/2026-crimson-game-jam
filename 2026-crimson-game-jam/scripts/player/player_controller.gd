extends CharacterBody3D

@export var walk_speed: float = 5

var walk_dir: Vector2

func _process(delta: float) -> void:
	walk_dir = Input.get_vector("left", "right", "up", "down") * delta * walk_speed
	position.z += walk_dir.y
	position.x += walk_dir.x
