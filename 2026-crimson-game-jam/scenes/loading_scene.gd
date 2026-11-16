extends Node3D

const MAIN = preload("uid://cdr18k5sh7365")

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(MAIN)
