extends Node

var music_player: AudioStreamPlayer

func _process(_delta: float) -> void:
	pass

func play_looped_sound(audio: AudioStream) -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = audio
	get_tree().root.add_child(player)
	player.play()
	return player

func free_looped_sound(audio_player: AudioStreamPlayer3D) -> void:
	audio_player.stop()
	audio_player.queue_free()

func play_sound(audio: AudioStream) -> void:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = audio
	get_tree().root.add_child(player)
	player.play()
	await player.finished
	player.queue_free()
	
func play_sound_at_point(audio: AudioStream, point: Vector3) -> void:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = audio
	get_tree().root.add_child(player)
	player.global_position = point
	player.play()
	await player.finished
	player.queue_free()

func play_music(audio: AudioStream) -> void:
	if (music_player == null):
		music_player = AudioStreamPlayer.new()
		get_tree().root.add_child(music_player)
	music_player.stream = audio
	music_player.play()
