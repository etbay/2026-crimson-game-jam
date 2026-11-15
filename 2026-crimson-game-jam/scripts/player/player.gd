class_name Player extends CharacterBody3D

signal beast_mode_finished

const PLAYER_BULLET = preload("uid://cgs6fx8lp6hdl")
const BULLET_SPAWN_0 := Vector2(0.3,0.03)
const BULLET_SPAWN_45 := Vector2(0.17,0.23)
const BULLET_SPAWN_80 := Vector2(0.015,0.45)
const BULLET_SPAWN_100 := Vector2(-0.015,0.45)
const BULLET_SPAWN_135 := Vector2(-0.17,0.23)
const BULLET_SPAWN_180 := Vector2(-0.3,0.03)

const BULLET_SPAWN_225 := Vector2(-0.15,-0.22)
const BULLET_SPAWN_260 := Vector2(-0.014,-0.31)
const BULLET_SPAWN_280 := Vector2(0.014,-0.31)
const BULLET_SPAWN_315 := Vector2(0.15,-0.22)

@export var walk_speed: float = 3
@export var beast_speed: float = 6
@export var dash_length: float = 18
@export var shoot_cooldown: float = 0.5

@onready var player_sprite: PlayerSprite = $PlayerSprite
@onready var bullet_spawn: Node3D = $BulletSpawn
@onready var parry_curve: Node3D = $ParryCurve
@onready var parry_radius: Area3D = $ParryRadius
@onready var hurtbox: PlayerHurtbox = $Hurtbox
@onready var hud: HUD = $"../HUD"

@onready var active_speed: float = walk_speed

# State bools
var dashing: bool = false
var beast_mode: bool = false
var vulnerable: bool = true
var parrying: bool = false

# Player values
var health: int = 3
var beast_meter: float = 0:
	set(value):
		beast_meter = value
		hud.set_beast(beast_meter)
var move_dir: Vector2
var mouse_dir: Vector2
var laser_damage: float
var movement_locked: bool = false
var tutorial_movement: bool = false
var input_override_dir : Vector3 = Vector3.ZERO

var shoot_timer: Timer

func damage() -> void:
	if vulnerable:
		# Delete nearby bullets
		# Give immunity frames
		health -= 1
		if health == 0:
			get_tree().quit()
		hud.set_health(health)
	else:
		laser_damage += 1

func _ready() -> void:
	parry_radius.area_entered.connect(_on_parry_area_entered)
	player_sprite.aim_direction_changed.connect(_on_aim_direction_changed)
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	add_child(shoot_timer)

func _process(delta: float) -> void:
	if beast_mode:
		beast_meter -= 5 * delta
		if beast_meter <= 0:
			beast_mode = false
			beast_mode_finished.emit()

func _physics_process(delta: float) -> void:
	_update_move_dir(delta)
	_update_mouse_dir()
	_process_input()
	player_sprite.update_sprite()

func _on_aim_direction_changed(direction: String) -> void:
	match(direction):
		"gun-90_false":
			bullet_spawn.position.x = BULLET_SPAWN_280.x
			bullet_spawn.position.y = BULLET_SPAWN_280.y
		"gun-45_false":
			bullet_spawn.position.x = BULLET_SPAWN_315.x
			bullet_spawn.position.y = BULLET_SPAWN_315.y
		"gun0_false":
			bullet_spawn.position.x = BULLET_SPAWN_0.x
			bullet_spawn.position.y = BULLET_SPAWN_0.y
		"gun45_false":
			bullet_spawn.position.x = BULLET_SPAWN_45.x
			bullet_spawn.position.y = BULLET_SPAWN_45.y
		"gun90_false":
			bullet_spawn.position.x = BULLET_SPAWN_80.x
			bullet_spawn.position.y = BULLET_SPAWN_80.y
		"gun-90_true":
			bullet_spawn.position.x = BULLET_SPAWN_260.x
			bullet_spawn.position.y = BULLET_SPAWN_260.y
		"gun-45_true":
			bullet_spawn.position.x = BULLET_SPAWN_225.x
			bullet_spawn.position.y = BULLET_SPAWN_225.y
		"gun0_true":
			bullet_spawn.position.x = BULLET_SPAWN_180.x
			bullet_spawn.position.y = BULLET_SPAWN_180.y
		"gun45_true":
			bullet_spawn.position.x = BULLET_SPAWN_135.x
			bullet_spawn.position.y = BULLET_SPAWN_135.y
		"gun90_true":
			bullet_spawn.position.x = BULLET_SPAWN_100.x
			bullet_spawn.position.y = BULLET_SPAWN_100.y

func _update_move_dir(_delta: float) -> void:
	if tutorial_movement:
		move_dir = Vector2(input_override_dir.x, input_override_dir.z)
		velocity = input_override_dir * walk_speed
		move_and_slide()
		return
	elif movement_locked:
		move_dir = Vector2.ZERO
		move_and_slide()
		return
	elif not dashing:
		move_dir = Input.get_vector("left", "right", "up", "down")
	velocity = Vector3(move_dir.x, 0, move_dir.y) * active_speed
	move_and_slide()

func _update_mouse_dir() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_viewport().get_camera_3d().unproject_position(global_position)
	mouse_dir = player_pos.direction_to(mouse_pos)

func _process_input() -> void:
	if (movement_locked):
		return
	if Input.is_action_just_pressed("shoot") and not beast_mode and not parrying and shoot_timer.is_stopped():
		# Shoot stuff
		var bullet: Bullet = BulletPool.instance.get_bullet()
		bullet.define_bullet_from_data(PLAYER_BULLET)
		bullet._initial_angle = mouse_dir.angle()
		bullet.angle = mouse_dir.angle()
		bullet.position = Vector3(bullet_spawn.global_position.x, 0, bullet_spawn.global_position.z)
		bullet.update_sprite()
		bullet.bullet_owner = self
		shoot_timer.start(shoot_cooldown)
	
	if Input.is_action_just_pressed("parry") and not beast_mode and not parrying:
		_execute_parry()
	
	if Input.is_action_just_pressed("beast_mode") and beast_meter > 1:
		_enter_beast_mode()
	
	if Input.is_action_just_pressed("dash") and beast_mode:
		_execute_dash()

func _enter_beast_mode() -> void:
	beast_mode = true
	vulnerable = false
	active_speed = beast_speed
	await beast_mode_finished
	vulnerable = true
	active_speed = walk_speed
	beast_mode = false
	laser_damage = 1

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

func tutorial_parry(b: TutorialBullet) -> void:
	parry_curve.visible = true
	Engine.time_scale = 0
	# Set parry curve sprite to direction
	var dir = Vector2(global_position.x, -global_position.z).direction_to(Vector2(b.global_position.x, -b.global_position.z))
	parry_curve.rotation.z = dir.angle()
	await get_tree().create_timer(0.1, true, false, true).timeout
	ScreenShake.shake(.15, 0.3)
	beast_meter += 10
	Engine.time_scale = 1
	parry_curve.visible = false

func _execute_parry() -> void:
	# Enter parry state
	parrying = true
	# TODO: Set parry sprite
	# If there's bullets in range, kill them
	for i in parry_radius.get_overlapping_areas():
		if i is Bullet:
			var bullet: Bullet = i as Bullet
			if bullet._active and bullet.parryable:
				_parry_bullet(bullet)
	# Play the parry for a short time
	await get_tree().create_timer(0.3).timeout
	# TODO: Reset to normal sprite
	parrying = false

func _parry_bullet(bullet: Bullet) -> void:
	# TODO: Play parry sfx
	parry_curve.visible = true
	Engine.time_scale = 0
	# Set parry curve sprite to direction
	var dir = Vector2(global_position.x, -global_position.z).direction_to(Vector2(bullet.global_position.x, -bullet.global_position.z))
	parry_curve.rotation.z = dir.angle()
	await get_tree().create_timer(0.1, true, false, true).timeout
	bullet.kill_bullet()
	ScreenShake.shake(.15, 0.3)
	beast_meter += 10
	Engine.time_scale = 1
	parry_curve.visible = false

func _on_parry_area_entered(area: Area3D) -> void:
	if parrying and area is Bullet and (area as Bullet)._active and (area as Bullet).parryable:
		_parry_bullet(area as Bullet)
