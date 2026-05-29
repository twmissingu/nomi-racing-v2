extends Node

## Sound manager: EV motor sounds, UI feedback, NOMI voice hints.

# Audio buses
var master_bus: int = 0
var sfx_bus: int = -1
var music_bus: int = -1

# EV motor sound state
var motor_players: Dictionary = {}  # car -> AudioStreamPlayer3D

func _ready() -> void:
	_setup_audio_buses()

func _setup_audio_buses() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	# Create SFX bus if it doesn't exist
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		sfx_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_bus, "SFX")
		AudioServer.set_bus_send(sfx_bus, "Master")
	else:
		sfx_bus = AudioServer.get_bus_index("SFX")

	# Create Music bus if it doesn't exist
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		music_bus = AudioServer.bus_count - 1
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

func play_ui_sound() -> void:
	# Placeholder for UI click/confirm sounds
	pass

func play_countdown_tick() -> void:
	# Placeholder for countdown sound
	pass

func play_victory_fanfare() -> void:
	# Placeholder for victory sound
	pass
