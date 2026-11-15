
extends Node

var camera: Camera3D


var intensity: float = 0.0
var duration: float = 0.0
var time_left: float = 0.0

var original_h_offset: float = 0.0
var original_v_offset: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func shake(strength: float = 0.3, length: float = 0.25) -> void:
	var active_camera = get_viewport().get_camera_3d()
	print("Camera found: ", active_camera)

	if active_camera == null:
		push_warning("ScreenShake: No active Camera3D found!")
		return

	# Store original camera offsets
	if camera != active_camera:
		reset_camera()
		camera = active_camera
		original_h_offset = camera.h_offset
		original_v_offset = camera.v_offset

	# Start or strengthen the shake
	intensity = max(intensity, strength)
	time_left = max(time_left, length)
	duration = max(duration, time_left)


func _process(delta: float) -> void:
	if time_left <= 0.0:
		return

	if not is_instance_valid(camera):
		camera = null
		time_left = 0.0
		intensity = 0.0
		duration = 0.0
		return

	time_left = max(0.0, time_left - delta)

	var fade = time_left / duration
	var current_strength = intensity * fade

	# Shake horizontally and vertically
	camera.h_offset = original_h_offset + randf_range(
		-current_strength, current_strength
	)

	camera.v_offset = original_v_offset + randf_range(
		-current_strength, current_strength
	)
	print("Camera shake offset: ", camera.h_offset, ", ", camera.v_offset)
	# Return camera to its original position
	if time_left <= 0.0:
		reset_camera()
		intensity = 0.0
		duration = 0.0


func reset_camera() -> void:
	if is_instance_valid(camera):
		camera.h_offset = original_h_offset
		camera.v_offset = original_v_offset

	camera = null
