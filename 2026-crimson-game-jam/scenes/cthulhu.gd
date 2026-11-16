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
	MusicMan.play_sound(AudioDict.sfx["roar"])
	await get_tree().create_timer(4).timeout
	global_position = pos
	phase = 0
	phase1.started = true

func _on_boss_dead() -> void:
	if (phase == 0):
		MusicMan.play_sound(AudioDict.sfx["cthulu_death"])
		ScreenShake.shake(1, 5)
		phase1.started = false
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_file("res://scenes/end.tscn")
	#if (phase == 0):
		#phase = 1
		#enemy.vulnerable = false
		#ScreenShake.shake(1, 5)
		#phase1.started = false
		#await get_tree().create_timer(5).timeout
		#enemy.health = 2000
		#enemy.max_health = 2000
		#phase2.started = true
	#elif (phase == 1):
		#print("dead")
		#queue_free()
