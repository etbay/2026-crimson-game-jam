class_name Enemy extends Area3D

signal dead

@export var max_health: int = 1000
@onready var hud: HUD = HUD.instance

var health: float
var vulnerable: bool = true

func damage(value: float) -> void:
	if vulnerable:
		health -= value
		ScreenShake.shake(0.05, .1)
		hud.update_boss_health(health)
		if (health <= 0):
			dead.emit()

func _ready() -> void:
	health = max_health
	hud.setup_boss(max_health, "Enemy")
