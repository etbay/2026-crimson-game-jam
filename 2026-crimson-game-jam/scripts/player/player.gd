class_name Player extends CharacterBody3D

@export var walk_speed: float = 5
@export var beast_speed: float = 10
@export var dash_length: float = 30

@onready var player_sprite: PlayerSprite = $PlayerSprite

@onready var active_speed: float = walk_speed

# State bools
var dashing: bool
var beast_mode: bool
var vulnerable: bool

# Player values
var health: int
var beast_meter: float = 10
var move_dir: Vector2
var mouse_dir: Vector2
var movement_locked: bool = false

func _physics_process(delta: float) -> void:
	_update_move_dir(delta)
	_update_mouse_dir()
	_process_input()
	player_sprite.update_sprite()

func _update_move_dir(_delta: float) -> void:
	if movement_locked:
		move_dir = Vector2.ZERO
	elif not dashing:
		move_dir = Input.get_vector("left", "right", "up", "down")
	velocity = Vector3(move_dir.x, 0, move_dir.y) * active_speed
	move_and_slide()

func _update_mouse_dir() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_viewport().get_camera_3d().unproject_position(global_position)
	mouse_dir = player_pos.direction_to(mouse_pos)

func _process_input() -> void:
	if Input.is_action_just_pressed("shoot") and not beast_mode:
		# TODO: Do shooting stuff
		pass
	
	if Input.is_action_just_pressed("parry") and not beast_mode:
		# TODO: Parry stuff
		pass
	
	if Input.is_action_just_pressed("beast_mode") and beast_meter > 1:
		beast_meter = 0
		_enter_beast_mode()
	
	if Input.is_action_just_pressed("dash") and beast_mode:
		_execute_dash()

func _enter_beast_mode() -> void:
	beast_mode = true
	vulnerable = false
	active_speed = beast_speed
	await get_tree().create_timer(3).timeout
	vulnerable = true
	active_speed = walk_speed
	beast_mode = false

func _execute_dash() -> void:
	dashing = true
	# Set speed really high for a short amount of time
	active_speed = dash_length
	await get_tree().create_timer(0.1).timeout
	if beast_mode:
		active_speed = beast_speed
	else:
		active_speed = walk_speed
	dashing = false
