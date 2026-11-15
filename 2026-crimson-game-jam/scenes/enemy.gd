class_name Enemy extends Area3D

@export var max_health: int = 1000
@onready var hud: HUD = $"../../HUD"

var health: int
var vulnerable: bool = true

func damage() -> void:
	if vulnerable:
		health -= 100
		hud.update_boss_health(health)

func _ready() -> void:
	health = max_health
	hud.setup_boss(max_health, "Enemy")
