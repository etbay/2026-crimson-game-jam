class_name Enemy extends Area3D

signal dead

@export var max_health: int = 1000
@onready var hud: HUD = HUD.instance

var health: float
var vulnerable: bool = true

func damage(value: float) -> void:
	if vulnerable:
		if (max_health > 150):
			if (randi() % 2 == 0):
				MusicMan.play_sound(AudioDict.sfx["cthulu_hurt1"])
			else:
				MusicMan.play_sound(AudioDict.sfx["cthulu_hurt2"])
		else:
			MusicMan.play_sound(AudioDict.sfx["statue_hurt"])
		health -= value
		ScreenShake.shake(0.05, .1)
		hud.update_boss_health(health)
		if (health <= 0):
			dead.emit()
	else:
		MusicMan.play_sound(AudioDict.sfx["statue_hurt"])

func _ready() -> void:
	health = max_health
	hud.setup_boss(max_health, "Enemy")
