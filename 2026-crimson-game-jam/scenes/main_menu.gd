
extends Control

#start scene
@export var game_scene: PackedScene
@export var load_scene: PackedScene

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed() -> void:
	if game_scene == null:
		push_error("Main Menu: No game scene assigned!")
		return
	
	if GlobalStats.loaded:
		get_tree().change_scene_to_packed(game_scene)
	else:
		GlobalStats.loaded = true
		get_tree().change_scene_to_packed(load_scene)
