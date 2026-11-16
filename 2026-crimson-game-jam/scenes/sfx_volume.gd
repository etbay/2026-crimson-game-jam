extends HSlider

func _ready() -> void:
	value = MusicMan.sfx_volume
	value_changed.connect(_on_value_changed)

func _on_value_changed(val: float) -> void:
	MusicMan.sfx_volume = val
