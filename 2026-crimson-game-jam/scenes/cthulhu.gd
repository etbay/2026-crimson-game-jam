class_name Cthulhu extends Node3D

@onready var enemy: Enemy = $Enemy
var phase: int = 0

func _ready() -> void:
	pass

func spawn():
	ScreenShake.shake(0.8, 2)
	phase = 0
