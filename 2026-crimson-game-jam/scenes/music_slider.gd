extends HSlider

func _ready() -> void:
	value = MusicMan.music_volume
	value_changed.connect(_on_value_changed)

func _on_value_changed(val: float) -> void:
	MusicMan.music_volume = val
