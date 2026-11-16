extends Node

var music_player: AudioStreamPlayer

var music_volume: float = 0.5:
	set(value):
		music_volume = value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

var sfx_volume: float = 0.25:
	set(value):
		sfx_volume = value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _process(_delta: float) -> void:
	pass

func _ready() -> void:
	music_volume = music_volume
	sfx_volume = sfx_volume

func play_looped_sound(audio: AudioStream) -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = audio
	player.bus = "SFX"
	get_tree().root.add_child(player)
	player.play()
	return player

func free_looped_sound(audio_player: AudioStreamPlayer3D) -> void:
	audio_player.stop()
	audio_player.queue_free()

func play_sound(audio: AudioStream) -> void:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = audio
	player.bus = "SFX"
	get_tree().root.add_child(player)
	player.play()
	await player.finished
	player.queue_free()
	
func play_sound_at_point(audio: AudioStream, point: Vector3) -> void:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = audio
	player.bus = "SFX"
	get_tree().root.add_child(player)
	player.global_position = point
	player.play()
	await player.finished
	player.queue_free()

func play_music(audio: AudioStream) -> void:
	if (music_player == null):
		music_player = AudioStreamPlayer.new()
		get_tree().root.add_child(music_player)
	music_player.bus = "Music"
	music_player.stream = audio
	music_player.play()
