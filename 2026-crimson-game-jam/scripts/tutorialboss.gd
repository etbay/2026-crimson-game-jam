extends Node3D

@export var bullet_scene: PackedScene
@export var player: Player

@onready var shot_origin: Marker3D = $ShotOrigin

@export var parry_prompt: Label3D
@export var wasd_prompt: Label3D

var entrance_start: Vector3
@export var entrance_end: Marker3D
@export var entrance_duration: float = 2.0
@export var shoot_delay: float = 2.0
@export var wasd_delay: float = 2.0
@export var wasd_duration: float = 3.0

@onready var bullet_emitter: Boss = $Boss
@onready var tutorial_trigger: Area3D = $"../TutorialTrigger"

var current_bullet: TutorialBullet
var waiting_for_parry: bool = false
var tutorial_started := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	parry_prompt.hide()
	wasd_prompt.hide()
	
	# Prevent the emitter from shooting during the tutorial
	bullet_emitter.process_mode = Node.PROCESS_MODE_PAUSABLE
	bullet_emitter.set_process(false)
	
	# connect signal
	tutorial_trigger.area_entered.connect(_on_tutorial_trigger)

func _on_tutorial_trigger(_area: Area3D) -> void:
	if (!tutorial_started):
		tutorial_started = true
		player.movement_locked = true
		start_tutorial()

func start_tutorial() -> void:
# Move player to the entrance starting position
	entrance_start = player.global_position
	
	# Move the player into the arena
	var tween = create_tween()
	tween.tween_property(
		player,
		"global_position",
		entrance_end.global_position,
		entrance_duration
	).set_trans(Tween.TRANS_LINEAR)

	# Wait for entrance to finish
	await tween.finished

# Check whether the player moves after the Tween
	await get_tree().create_timer(1.0).timeout
	#print("Player position 1 second later: ", player.global_position)

	# Wait before the boss shoots
	await get_tree().create_timer(shoot_delay).timeout
	shoot()

func shoot() -> void:
	#if player == null:
		#push_error("Player has not been assigned to the Boss!")
		#return
	#if shot_origin == null:
		#push_error("ShotOrigin was not found!")
		#return
	# Create the bullet
	var bullet: TutorialBullet = bullet_scene.instantiate()
	current_bullet = bullet
	bullet.player = player
	bullet.near_player.connect(_on_bullet_near_player)
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shot_origin.global_position

	# Calculate direction toward player
	var target_position = player.global_position
	target_position.y = shot_origin.global_position.y
	var direction = (
		target_position - shot_origin.global_position
	).normalized()

	# Tell bullet which direction to travel
	bullet.direction = direction

func _on_bullet_near_player() -> void:
	waiting_for_parry = true
	parry_prompt.show()
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if not waiting_for_parry:
		return
	if event.is_action_pressed("parry"):
		#print("Right click detected!")
		parry_successful()
		get_viewport().set_input_as_handled()

func parry_successful() -> void:
	waiting_for_parry = false
	player.tutorial_parry(current_bullet)
	# Delete the bullet
	if is_instance_valid(current_bullet):
		current_bullet.queue_free()
		current_bullet = null

	# Hide the prompt
	parry_prompt.hide()

	# Resume the game
	get_tree().paused = false
	player.movement_locked = false
	#print("ScreenShake triggered!")
	ScreenShake.shake(.2, 0.3)
	show_wasd_tutorial()
	#print("Successful Parry!")

func show_wasd_tutorial() -> void:
	# Wait before showing the WASD prompt
	await get_tree().create_timer(wasd_delay).timeout

	# Show the movement instructions
	wasd_prompt.show()
	bullet_emitter.set_process(true)

	# Keep them visible for a few seconds
	await get_tree().create_timer(wasd_duration).timeout
	# Hide the instructions
	wasd_prompt.hide()
