extends Node3D

@export var bullet_scene: PackedScene
@export var player: CharacterBody3D

@onready var shot_origin: Marker3D = $ShotOrigin

func _ready() -> void:
	# Wait one second before firing
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
