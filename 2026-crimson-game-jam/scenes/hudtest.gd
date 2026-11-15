
extends Node

@onready var hud = $HUD

var test_health: int = 3
var test_beast: int = 0


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	# H removes one heart
	if event.keycode == KEY_H:
		test_health = maxi(0, test_health - 1)
		hud.set_health(test_health)

	# B adds 25 Beast points
	if event.keycode == KEY_B:
		test_beast += 25
		hud.set_beast(test_beast)

	# N removes 25 Beast points
	if event.keycode == KEY_N:
		test_beast = maxi(0, test_beast - 25)
		hud.set_beast(test_beast)
