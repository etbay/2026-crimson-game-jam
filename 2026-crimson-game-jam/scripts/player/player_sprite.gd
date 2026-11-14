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
	var facing: String
	var direction_frame: String
	
	if player.mouse_dir.y < 0:
		facing = "back"
	else:
		facing = "front"
	
	var angle: float = abs(int(rad_to_deg(player.mouse_dir.angle())))
	# TODO: Point gun
	if player.mouse_dir.x < 0:
		if angle >= 90 and angle <= 120:
			direction_frame = "frame3"
		elif angle >= 120 and angle <= 150:
			direction_frame = "frame2"
		elif angle >= 150 and angle <= 180:
			direction_frame = "frame1"
	else:
		if angle >= 0 and angle <= 30:
			direction_frame = "frame1"
		elif angle >= 30 and angle <= 60:
			direction_frame = "frame2"
		elif angle >= 60 and angle <= 90:
			direction_frame = "frame3"
	
	# Flip the sprite if looking left, unflip if right
	arm_sprite.flip_h = player.mouse_dir.x < 0 
	
	# Play animation
	arm_sprite.play("%s_%s" % [facing, direction_frame])

func _update_legs() -> void:
	var state: String
	var facing: String
	
	if player.mouse_dir.y < 0:
		facing = "back"
	else:
		facing = "front"
	
	if player.move_dir == Vector2.ZERO:
		state = "idle"
	else:
		state = "moving"
	
	# Flip the sprite if looking left, unflip if right
	legs_sprite.flip_h = player.mouse_dir.x < 0
	
	# Play animation
	legs_sprite.play("%s_%s" % [facing, state])
