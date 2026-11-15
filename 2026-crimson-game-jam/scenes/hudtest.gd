
extends Node

@onready var hud = $HUD
var test_boss_health: int = 100

var test_health: int = 3
var test_beast: int = 0

func _ready() -> void:
	hud.setup_boss(100, "THE STATUE")

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	# H removes one heart
	if event.keycode == KEY_H:
		test_health = maxi(0, test_health - 1)
		hud.set_health(test_health)

	# B adds beast points
	if event.keycode == KEY_B:
		test_beast += 10
		hud.set_beast(test_beast)

	# N removes beast points
	if event.keycode == KEY_N:
		test_beast = maxi(0, test_beast - 20)
		hud.set_beast(test_beast)
		
		# Damage boss with J
	if event.keycode == KEY_J:
		test_boss_health = maxi(test_boss_health - 10, 0)
		hud.update_boss_health(test_boss_health)
