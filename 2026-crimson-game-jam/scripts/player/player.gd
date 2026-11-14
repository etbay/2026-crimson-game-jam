class_name Player extends Entity

@export var walk_speed: float = 5
@export var beast_speed: float = 10

@onready var player_sprite: PlayerSprite = $PlayerSprite

enum PlayerState
{
	MOVING,
	PARRYING,
	DASHING,
	LASERING
}

var beast_mode: bool
var beast_meter: float
var move_dir: Vector2
var mouse_dir: Vector2

func _process(delta: float) -> void:
	_update_move_dir(delta)
	_update_mouse_dir()
	_process_input()
	player_sprite.update_sprite()

func _update_move_dir(delta: float) -> void:
	move_dir = Input.get_vector("left", "right", "up", "down") * delta * walk_speed
	position.z += move_dir.y
	position.x += move_dir.x

func _update_mouse_dir() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_viewport().get_camera_3d().unproject_position(global_position)
	mouse_dir = player_pos.direction_to(mouse_pos)

func _process_input() -> void:
	pass
