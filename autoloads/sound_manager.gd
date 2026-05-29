extends Node

## Sound manager: procedural UI sounds, countdown, victory fanfare.

# Audio buses
var master_bus: int = 0
var sfx_bus: int = -1
var music_bus: int = -1

func _ready() -> void:
	_setup_audio_buses()
	# Auto-play UI click on any button press
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is Button:
		node.pressed.connect(play_ui_click)

func _setup_audio_buses() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	if AudioServer.get_bus_index("SFX") == -1:
		var idx: int = AudioServer.bus_count
		AudioServer.add_bus()
		sfx_bus = idx
		AudioServer.set_bus_name(sfx_bus, "SFX")
		AudioServer.set_bus_send(sfx_bus, "Master")
	else:
		sfx_bus = AudioServer.get_bus_index("SFX")

	if AudioServer.get_bus_index("Music") == -1:
		var idx: int = AudioServer.bus_count
		AudioServer.add_bus()
		music_bus = idx
		AudioServer.set_bus_name(music_bus, "Music")
		AudioServer.set_bus_send(music_bus, "Master")
	else:
		music_bus = AudioServer.get_bus_index("Music")

func set_master_volume(linear: float) -> void:
	var db: float = linear_to_db(clampf(linear, 0.001, 1.0))
	AudioServer.set_bus_volume_db(master_bus, db)

func set_sfx_volume(linear: float) -> void:
	if sfx_bus >= 0:
		var db: float = linear_to_db(clampf(linear, 0.001, 1.0))
		AudioServer.set_bus_volume_db(sfx_bus, db)

func set_music_volume(linear: float) -> void:
	if music_bus >= 0:
		var db: float = linear_to_db(clampf(linear, 0.001, 1.0))
		AudioServer.set_bus_volume_db(music_bus, db)

func play_ui_click() -> void:
	_play_tone(880.0, 0.06, 0.3)

func play_countdown_tick() -> void:
	_play_tone(660.0, 0.15, 0.5)

func play_countdown_go() -> void:
	_play_tone(880.0, 0.3, 0.6)
	_play_tone(1100.0, 0.3, 0.4, 0.05)

func play_victory_fanfare() -> void:
	var notes: Array = [523.0, 659.0, 784.0, 1047.0]
	for i in range(notes.size()):
		_play_tone(notes[i], 0.25, 0.5, float(i) * 0.12)

func play_overtake() -> void:
	_play_tone(600.0, 0.1, 0.3)
	_play_tone(800.0, 0.1, 0.3, 0.08)

func play_checkpoint() -> void:
	_play_tone(500.0, 0.08, 0.25)
	_play_tone(700.0, 0.08, 0.25, 0.05)

func play_lap_complete() -> void:
	_play_tone(440.0, 0.1, 0.35)
	_play_tone(660.0, 0.15, 0.4, 0.08)

func play_collision() -> void:
	var noise_player := AudioStreamPlayer.new()
	noise_player.bus = "SFX"
	add_child(noise_player)
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.15
	noise_player.stream = stream
	noise_player.play()
	await get_tree().create_timer(0.02).timeout
	var playback: AudioStreamGeneratorPlayback = noise_player.get_stream_playback()
	if playback:
		var frames: int = playback.get_frames_available()
		for i in range(frames):
			var t: float = float(i) / 22050.0
			var vol: float = (1.0 - t / 0.15) * 0.4
			playback.push_frame(Vector2(randf_range(-vol, vol), randf_range(-vol, vol)))
	await get_tree().create_timer(0.2).timeout
	noise_player.queue_free()

func _play_tone(freq: float, duration: float, volume: float, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	add_child(player)
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 44100
	stream.buffer_length = duration + 0.05
	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.play()
	await get_tree().create_timer(0.01).timeout
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	if not playback:
		player.queue_free()
		return
	var total_frames: int = int(44100.0 * duration)
	var written: int = 0
	while written < total_frames:
		var frames: int = playback.get_frames_available()
		if frames <= 0:
			await get_tree().process_frame
			continue
		for i in range(frames):
			if written >= total_frames:
				break
			var t: float = float(written) / 44100.0
			var envelope: float = 1.0
			var attack: float = 0.01
			var release: float = duration * 0.3
			if t < attack:
				envelope = t / attack
			elif t > duration - release:
				envelope = (duration - t) / release
			var sample: float = sin(2.0 * PI * freq * t) * envelope * volume
			# Add harmonics for richer tone
			sample += sin(2.0 * PI * freq * 2.0 * t) * envelope * volume * 0.2
			sample += sin(2.0 * PI * freq * 3.0 * t) * envelope * volume * 0.08
			playback.push_frame(Vector2(sample, sample))
			written += 1
	await get_tree().create_timer(duration + 0.1).timeout
	player.queue_free()
