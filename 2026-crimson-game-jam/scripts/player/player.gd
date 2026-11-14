class_name Player extends Entity

@export var walk_speed: float = 5
@export var beast_speed: float = 10

@onready var player_sprite: PlayerSprite = $PlayerSprite

enum PlayerState
{
	PARRYING,
	DASHING,
	LASERING
}

@onready var active_speed: float = walk_speed
var beast_mode: bool
var beast_meter: float = 10
var move_dir: Vector2
var mouse_dir: Vector2

func _process(delta: float) -> void:
	_update_move_dir(delta)
	_update_mouse_dir()
	_process_input()
	player_sprite.update_sprite()

func _update_move_dir(delta: float) -> void:
	move_dir = Input.get_vector("left", "right", "up", "down") * delta * active_speed
	position.z += move_dir.y
	position.x += move_dir.x

func _update_mouse_dir() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_viewport().get_camera_3d().unproject_position(global_position)
	mouse_dir = player_pos.direction_to(mouse_pos)

func _process_input() -> void:
	if Input.is_action_just_pressed("shoot") and not beast_mode:
		# TODO: Do shooting stuff
		pass
	
	if Input.is_action_just_pressed("beast_mode") and beast_meter > 1:
		beast_meter = 0
		_enter_beast_mode()
	
	if Input.is_action_just_pressed("dash") and beast_mode:
		# TODO: Do dashing stuff
		pass

func _enter_beast_mode() -> void:
	vulnerable = false
	active_speed = beast_speed
	await get_tree().create_timer(3).timeout
	vulnerable = true
	active_speed = walk_speed
