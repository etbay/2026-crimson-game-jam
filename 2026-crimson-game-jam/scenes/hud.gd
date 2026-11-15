
extends CanvasLayer

# Heart textures
@export var full_heart: Texture2D
@export var empty_heart: Texture2D

# Beast Bar textures
@export var normal_frame: Texture2D
@export var broken_frame: Texture2D

# Beast Bar settings
@export var normal_capacity: int = 100
@export var full_fill_width: float = 233.0
@export var fill_duration: float = 0.5
@export var overflow_pixels_per_point: float = 10.0

@onready var hearts: HBoxContainer = $MarginContainer/VBoxContainer/Hearts
@onready var fill: ColorRect = $MarginContainer/VBoxContainer/BeastBar/Fill
@onready var frame: TextureRect = $MarginContainer/VBoxContainer/BeastBar/Frame

var fill_tween: Tween


func _ready() -> void:
	# Set initial HUD values
	set_health(3)
	set_beast(0, false)


# HEART SYSTEM
func set_health(value: int) -> void:
	var current_health = clampi(value, 0, 3)

	for i in range(hearts.get_child_count()):
		var heart = hearts.get_child(i) as TextureRect

		if heart == null:
			continue

		if i < current_health:
			heart.texture = full_heart
			heart.modulate = Color.WHITE
		else:
			if empty_heart != null:
				heart.texture = empty_heart
				heart.modulate = Color.WHITE
			else:
				heart.texture = full_heart
				heart.modulate = Color(0.3, 0.3, 0.3)


# BEAST BAR SYSTEM

func set_beast(value: int, animate: bool = true) -> void:
	var amount = maxi(value, 0)
	var target_width: float

	if amount <= normal_capacity:
		# Fill normally from 0 to 100
		target_width = full_fill_width * (
			float(amount) / float(normal_capacity)
		)
	else:
		# Grow endlessly past the broken border
		var overflow = amount - normal_capacity

		target_width = full_fill_width + (
			overflow * overflow_pixels_per_point
		)

	# Stop the previous animation
	if fill_tween != null and fill_tween.is_valid():
		fill_tween.kill()

	if not animate:
		_set_fill_width(target_width)
		return

	# Smoothly animate the bar
	fill_tween = create_tween()

	fill_tween.tween_method(
		_set_fill_width,
		fill.size.x,
		target_width,
		fill_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _set_fill_width(width: float) -> void:
	fill.size.x = maxf(0.0, width)

	# Switch the border when the fill exceeds capacity
	if width > full_fill_width:
		if frame.texture != broken_frame:
			frame.texture = broken_frame
	else:
		if frame.texture != normal_frame:
			frame.texture = normal_frame
