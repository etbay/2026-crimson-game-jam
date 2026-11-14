extends Label

func _process(delta: float) -> void:
	text = "FPS: %.2f" % (1.0 / delta)
