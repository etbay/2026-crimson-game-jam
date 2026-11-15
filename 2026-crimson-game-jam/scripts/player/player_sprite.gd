class_name PlayerSprite extends Node3D

@export var player: Player
@onready var body_sprite: AnimatedSprite3D = $BodySprite
@onready var arm_sprite: AnimatedSprite3D = $ArmSprite
@onready var legs_sprite: AnimatedSprite3D = $LegsSprite

func update_sprite() -> void:
	_update_body()
	_update_arms()
	_update_legs()

func _update_body() -> void:
	var state: String
	var facing: String
	
	if player.mouse_dir.y < 0:
		facing = "back"
	else:
		facing = "front"
	
	# Flip the sprite if looking left, unflip if right
	body_sprite.flip_h = player.mouse_dir.x < 0
	
	# Play animation
	#body_sprite.play("%s_%s" % [facing, state])

func _update_arms() -> void:
	var direction_frame: String
	
	var angle: float = int(rad_to_deg(player.mouse_dir.angle()))
	print(angle)
	# Point gun
	if player.mouse_dir.x < 0:
		if angle >= 90 and angle <= 120:
			direction_frame = "gun-90"
		elif angle >= 120 and angle <= 150:
			direction_frame = "gun-45"
		elif angle >= 150 and angle <= 180:
			direction_frame = "gun0"
	else:
		if angle >= -15 and angle <= 15:
			direction_frame = "gun0"
		elif angle >= 15 and angle <= 70:
			direction_frame = "gun-45"
		elif angle >= 70 and angle <= 90:
			direction_frame = "gun-90"
		elif angle <= -15 and angle >= -90:
			direction_frame = "gun45"
	
	# Flip the sprite if looking left, unflip if right
	arm_sprite.flip_h = player.mouse_dir.x < 0 
	
	# Play animation
	arm_sprite.play(direction_frame)

func _update_legs() -> void:
	var state: String
	
	if player.move_dir == Vector2.ZERO:
		state = "idle"
	else:
		state = "moving"
	
	# Flip the sprite if looking left, unflip if right
	legs_sprite.flip_h = player.mouse_dir.x < 0
	
	# Play animation
	legs_sprite.play(state)
