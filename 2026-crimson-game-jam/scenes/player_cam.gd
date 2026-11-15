class_name PlayerCam extends Camera3D

@onready var player: Player = $"../CharacterBody3D"
@onready var tutorial_trigger: Area3D = $"../TutorialTrigger"
@export var target_cam_position : Vector3
@export var lerp_speed : float = 4.0 # higher = faster

enum Mode { FOLLOW, STATIC, TRANSITION }
var mode : Mode = Mode.FOLLOW

func _ready() -> void:
	tutorial_trigger.area_entered.connect(_on_tutorial_trigger)

func _process(delta: float) -> void:
	# Frame-rate independent lerp weight
	var weight := 1.0 - exp(-lerp_speed * delta)

	match mode:
		Mode.FOLLOW:
			position = player.position + Vector3(0, 3.6, 0.0)
		Mode.TRANSITION:
			#player.position = player.position.lerp(target_player_position, weight)
			position = position.lerp(target_cam_position, weight)

			# Snap and finish once close enough
			if position.distance_to(target_cam_position) < 0.01:
				#player.position = target_player_position
				position = target_cam_position
				player.set_physics_process(true)
				mode = Mode.STATIC

func _on_tutorial_trigger(area: Area3D) -> void:
	if mode == Mode.FOLLOW and area == player.hurtbox:
		# Stop the player's own movement so it doesn't fight the lerp
		player.movement_locked = true
		mode = Mode.TRANSITION

func _exit_tree() -> void:
	tutorial_trigger.area_entered.disconnect(_on_tutorial_trigger)
