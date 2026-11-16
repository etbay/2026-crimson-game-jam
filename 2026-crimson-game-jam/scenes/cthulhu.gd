class_name Cthulhu extends Node3D

@onready var enemy: Enemy = $Enemy
@onready var phase1: Boss = $Phase1
@onready var phase2: Boss = $Phase2
var phase: int = 0

func _ready() -> void:
	phase1.started = false
	phase2.started = false
	enemy.dead.connect(_on_boss_dead)

func spawn(pos: Vector3):
	ScreenShake.shake(0.8, 2)
	await get_tree().create_timer(4).timeout
	global_position = pos
	phase = 0
	phase1.started = true

func _on_boss_dead() -> void:
	if (phase == 0):
		phase += 1
		enemy.health = 2000
		enemy.max_health = 2000
		phase1.started = false
		phase2.started = true
	if (phase == 1):
		print("dead")
		queue_free()
