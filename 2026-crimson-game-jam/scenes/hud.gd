class_name HUD extends CanvasLayer

# Heart textures
@export var full_heart: Texture2D
@export var empty_heart: Texture2D

# Beast Bar textures
@export var normal_frame: Texture2D
@export var broken_frame: Texture2D

# Beast Bar settings
@export var normal_capacity: int = 100
@export var full_fill_width: float = 280.0
@export var fill_duration: float = 0.5
@export var overflow_pixels_per_point: float = 10.0


@onready var hearts: HBoxContainer = $Control/MarginContainer/VBoxContainer/HeartArea/Hearts
@onready var fill: ColorRect = $Control/MarginContainer/VBoxContainer/BeastBar/Fill
@onready var frame: TextureRect = $Control/MarginContainer/VBoxContainer/BeastBar/Frame
@onready var glow: ColorRect = $Control/MarginContainer/VBoxContainer/BeastBar/Glow

@export var glow_padding: float = 18.0

# boss bar
@onready var boss_health_bar: TextureProgressBar = $Control/BossBarArea/BossHealthBar
@onready var boss_name: Label = $Control/BossBarArea/BossName

@export var boss_normal_color: Color = Color(0.7, 0.7, 0.7, 1.0)
@export var boss_damage_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var boss_health_tween: Tween
var fill_tween: Tween

static var instance : HUD = null

func _ready() -> void:
	# Set initial HUD values
	set_health(3)
	set_beast(0, false)
	
	if (instance == null):
		instance = self
	else:
		queue_free()


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

func set_beast(value: float, animate: bool = true) -> void:
	var amount = maxf(value, 0)
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

	# Update the outer glow
	var padding = glow_padding

	glow.position = fill.position - Vector2(padding, padding)

	glow.size = fill.size + Vector2(
		padding * 2.0,
		padding * 2.0
	)

	# Hide the glow when the bar is empty
	glow.visible = fill.size.x > 0.0

	# Update glow shader dimensions
	var glow_mat = glow.material as ShaderMaterial

	if glow_mat != null:
		glow_mat.set_shader_parameter("rect_size", glow.size)
		glow_mat.set_shader_parameter("padding", padding)

	# Check if bar is broken
	var broken = width > full_fill_width

	# Change border texture
	if broken:
		frame.texture = broken_frame
	else:
		frame.texture = normal_frame

	# Update existing animated fill shader
	var mat = fill.material as ShaderMaterial

	if mat != null:
		mat.set_shader_parameter("overflowing", broken)


func setup_boss(max_health: float, name_boss: String = "BOSS") -> void:
	boss_health_bar.min_value = 0
	boss_health_bar.max_value = max_health
	boss_health_bar.value = max_health
	boss_health_bar.step = 0
	boss_health_bar.tint_progress = boss_normal_color

	boss_name.text = name_boss



func update_boss_health(new_health: float) -> void:
	
	if boss_health_tween != null and boss_health_tween.is_valid():
		boss_health_tween.kill()

	var target_health = clampf(
		float(new_health),
		boss_health_bar.min_value,
		boss_health_bar.max_value
	)

	# Lighten the bar when taking damage
	if target_health < boss_health_bar.value:
		boss_health_bar.tint_progress = boss_damage_color
	else:
		boss_health_bar.tint_progress = boss_normal_color

	# Animate the health change
	boss_health_tween = create_tween()

	boss_health_tween.tween_property(
		boss_health_bar,
		"value",
		target_health,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Return to normal color once animation finishes
	boss_health_tween.finished.connect(
		func():
			boss_health_bar.tint_progress = boss_normal_color
	)
