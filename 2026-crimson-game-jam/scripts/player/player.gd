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

const RIGHT_LASER := Vector2(0.07,0.335)
const LEFT_LASER := Vector2(-0.07,0.335)

@export var walk_speed: float = 3
@export var beast_speed: float = 6
@export var dash_length: float = 18
@export var shoot_cooldown: float = 0.3
@export var laser_color_gradient: Gradient

@onready var player_sprite: PlayerSprite = $PlayerSprite
@onready var bullet_spawn: Node3D = $BulletSpawn
@onready var parry_curve: Node3D = $ParryCurve
@onready var parry_radius: Area3D = $ParryRadius
@onready var hurtbox: PlayerHurtbox = $Hurtbox
@onready var hud: HUD = $"../HUD"
@onready var laser: Area3D = $Laser
@onready var laser_particles: GPUParticles3D = $Laser/Node3D/GPUParticles3D
@onready var bullet_destroy_radius: Area3D = $BulletDestroyRadius

@onready var active_speed: float = walk_speed

var material: ShaderMaterial

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
var laser_damage: float = 0.1
var max_laser_damage: float = 100
var hovering_enemy: Enemy = null
var movement_locked: bool = false
var tutorial_movement: bool = false
var input_override_dir : Vector3 = Vector3.ZERO


var laser_sound: AudioStreamPlayer3D
var shoot_timer: Timer

func damage() -> void:
	if vulnerable:
		# Delete nearby bullets
		# Give immunity frames
		health -= 1
		GlobalStats.hits += 1
		if health == 0:
			get_tree().quit()
		hud.set_health(health)
		MusicMan.play_sound(AudioDict.sfx["player_hurt"])
		vulnerable = false
		for i in bullet_destroy_radius.get_overlapping_areas():
			if i is Bullet:
				var bullet := i as Bullet
				bullet.kill_bullet()
		await get_tree().create_timer(0.5).timeout
		vulnerable = true
	else:
		MusicMan.play_sound(AudioDict.sfx["absorb_bullet"])
		laser_damage += 0.1

func heal(amount: int) -> void:
	health += amount
	health = clampi(health, 0, 3)
	hud.set_health(health)

func _ready() -> void:
	parry_radius.area_entered.connect(_on_parry_area_entered)
	player_sprite.aim_direction_changed.connect(_on_aim_direction_changed)
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	add_child(shoot_timer)
	material = laser_particles.material_override as ShaderMaterial

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
	_update_laser(delta)
	player_sprite.update_sprite()

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
	GlobalStats.time += _delta

func _update_mouse_dir() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_viewport().get_camera_3d().unproject_position(global_position)
	mouse_dir = player_pos.direction_to(mouse_pos)

func _update_laser(delta: float) -> void:
	if beast_mode:
		material.set_shader_parameter("Color", material.get_shader_parameter("Color").lerp(_get_scale_color(laser_damage), 1.0 - exp(-8.0 * delta)))
		laser.rotation.z = mouse_dir.angle()
		for i in laser.get_overlapping_areas():
			if i is Enemy:
				var enemy := i as Enemy
				enemy.damage(laser_damage)

func _get_scale_color(value: float) -> Color:
	return laser_color_gradient.sample(inverse_lerp(1.0, max_laser_damage, value))

func _process_input() -> void:
	if (movement_locked):
		return
	if Input.is_action_pressed("shoot") and not beast_mode and not parrying and shoot_timer.is_stopped():
		# Shoot stuff
		var bullet: Bullet = BulletPool.instance.get_bullet()
		bullet.define_bullet_from_data(PLAYER_BULLET)
		bullet._initial_angle = mouse_dir.angle()
		bullet.angle = mouse_dir.angle()
		bullet.position = Vector3(bullet_spawn.global_position.x, 0, bullet_spawn.global_position.z)
		bullet.bullet_owner = "Player"
		bullet.update_sprite()
		MusicMan.play_sound(AudioDict.sfx["player_shoot"])
		shoot_timer.start(shoot_cooldown)
	
	if Input.is_action_just_pressed("parry") and not beast_mode and not parrying:
		_execute_parry()
	
	if Input.is_action_just_pressed("beast_mode") and beast_meter >= 10 and not beast_mode:
		_enter_beast_mode()
	
	if Input.is_action_just_pressed("dash") and beast_mode:
		_execute_dash()

func _enter_beast_mode() -> void:
	MusicMan.play_sound(AudioDict.sfx["activate_beast_mode"])
	laser_sound = MusicMan.play_looped_sound(AudioDict.sfx["laser"])
	var heal_amount = int(beast_meter) % 30
	heal(heal_amount)
	beast_mode = true
	laser.visible = true
	vulnerable = false
	active_speed = beast_speed
	await beast_mode_finished
	active_speed = walk_speed
	beast_mode = false
	laser.visible = false
	beast_meter = 0
	laser_damage = 1
	MusicMan.free_looped_sound(laser_sound)
	laser_sound = null
	await get_tree().create_timer(0.5).timeout
	vulnerable = true

func _execute_dash() -> void:
	dashing = true
	# Set speed really high for a short amount of time
	active_speed = dash_length
	MusicMan.play_sound(AudioDict.sfx["dash"])
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
	beast_meter += 5
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
	parry_curve.visible = true
	MusicMan.play_sound(AudioDict.sfx["parry"])
	Engine.time_scale = 0
	# Set parry curve sprite to direction
	var dir = Vector2(global_position.x, -global_position.z).direction_to(Vector2(bullet.global_position.x, -bullet.global_position.z))
	parry_curve.rotation.z = dir.angle()
	await get_tree().create_timer(0.1, true, false, true).timeout
	bullet.kill_bullet()
	ScreenShake.shake(.15, 0.3)
	beast_meter += 5
	Engine.time_scale = 1
	parry_curve.visible = false

func _on_parry_area_entered(area: Area3D) -> void:
	if parrying and area is Bullet and (area as Bullet)._active and (area as Bullet).parryable:
		_parry_bullet(area as Bullet)

func _on_aim_direction_changed(direction: String) -> void:
	match(direction):
		"gun-90_false":
			laser.position.x = RIGHT_LASER.x
			laser.position.y = RIGHT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_280.x
			bullet_spawn.position.y = BULLET_SPAWN_280.y
		"gun-45_false":
			laser.position.x = RIGHT_LASER.x
			laser.position.y = RIGHT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_315.x
			bullet_spawn.position.y = BULLET_SPAWN_315.y
		"gun0_false":
			laser.position.x = RIGHT_LASER.x
			laser.position.y = RIGHT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_0.x
			bullet_spawn.position.y = BULLET_SPAWN_0.y
		"gun45_false":
			laser.position.x = RIGHT_LASER.x
			laser.position.y = RIGHT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_45.x
			bullet_spawn.position.y = BULLET_SPAWN_45.y
		"gun90_false":
			laser.position.x = RIGHT_LASER.x
			laser.position.y = RIGHT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_80.x
			bullet_spawn.position.y = BULLET_SPAWN_80.y
		"gun-90_true":
			laser.position.x = LEFT_LASER.x
			laser.position.y = LEFT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_260.x
			bullet_spawn.position.y = BULLET_SPAWN_260.y
		"gun-45_true":
			laser.position.x = LEFT_LASER.x
			laser.position.y = LEFT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_225.x
			bullet_spawn.position.y = BULLET_SPAWN_225.y
		"gun0_true":
			laser.position.x = LEFT_LASER.x
			laser.position.y = LEFT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_180.x
			bullet_spawn.position.y = BULLET_SPAWN_180.y
		"gun45_true":
			laser.position.x = LEFT_LASER.x
			laser.position.y = LEFT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_135.x
			bullet_spawn.position.y = BULLET_SPAWN_135.y
		"gun90_true":
			laser.position.x = LEFT_LASER.x
			laser.position.y = LEFT_LASER.y
			bullet_spawn.position.x = BULLET_SPAWN_100.x
			bullet_spawn.position.y = BULLET_SPAWN_100.y
