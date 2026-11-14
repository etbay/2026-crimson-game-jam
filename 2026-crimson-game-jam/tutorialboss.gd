extends Node3D

@export var bullet_scene: PackedScene
@export var player: CharacterBody3D

@onready var shot_origin: Marker3D = $ShotOrigin

@export var parry_prompt: Label3D

var current_bullet: TutorialBullet
var waiting_for_parry: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide the prompt when the game starts
	parry_prompt.hide()

	await get_tree().create_timer(1.0).timeout
	shoot()



func shoot() -> void:
	
	if player == null:
		push_error("Player has not been assigned to the Boss!")
		return

	if shot_origin == null:
		push_error("ShotOrigin was not found!")
		return
	# Create the bullet
	var bullet: TutorialBullet = bullet_scene.instantiate()
	current_bullet = bullet
	bullet.player = player
	bullet.near_player.connect(_on_bullet_near_player)

	# Add it to the main scene
	get_tree().current_scene.add_child(bullet)

	# Spawn at the statue's ShotOrigin
	bullet.global_position = shot_origin.global_position

	# Calculate direction toward player
	var target_position = player.global_position

	# Keep bullet at the same height
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
		print("Right click detected!")

		parry_successful()
		get_viewport().set_input_as_handled()

func parry_successful() -> void:
	waiting_for_parry = false

	# Delete the bullet
	if is_instance_valid(current_bullet):
		current_bullet.queue_free()
		current_bullet = null

	# Hide the prompt
	parry_prompt.hide()

	# Resume the game
	get_tree().paused = false

	print("Successful Parry!")

	
