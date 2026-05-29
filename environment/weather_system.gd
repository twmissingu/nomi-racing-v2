extends Node

## Weather system: rain, fog, wind effects with physics impact.

enum Weather { CLEAR, CLOUDY, RAIN, STORM }

signal weather_changed(new_weather: Weather)

var current_weather: Weather = Weather.CLEAR
var transition_speed: float = 0.5
var weather_timer: float = 0.0
var weather_duration: float = 60.0  # seconds per weather state

# Rain particles
var rain_particles: GPUParticles3D
var rain_intensity: float = 0.0  # 0.0 = no rain, 1.0 = heavy rain

# Fog
var fog_density: float = 0.0
var fog_target: float = 0.0

# Wind
var wind_direction: Vector3 = Vector3.FORWARD
var wind_strength: float = 0.0

# Physics impact
var surface_grip_multiplier: float = 1.0  # Rain reduces grip
var visibility_range: float = 1000.0

func _ready() -> void:
	_setup_rain_particles()

func _process(delta: float) -> void:
	weather_timer += delta

	# Auto weather transitions (optional)
	if weather_duration > 0.0 and weather_timer >= weather_duration:
		weather_timer = 0.0
		_random_weather_change()

	# Smooth rain intensity transition
	var target_intensity: float = 1.0 if current_weather == Weather.RAIN or current_weather == Weather.STORM else 0.0
	rain_intensity = lerpf(rain_intensity, target_intensity, transition_speed * delta)

	# Update rain particles
	if rain_particles:
		rain_particles.emitting = rain_intensity > 0.05
		rain_particles.amount = int(rain_intensity * 200)

	# Update surface grip based on rain
	surface_grip_multiplier = lerpf(1.0, 0.7, rain_intensity)

func _setup_rain_particles() -> void:
	rain_particles = GPUParticles3D.new()
	rain_particles.name = "RainParticles"
	rain_particles.amount = 0
	rain_particles.lifetime = 1.0
	rain_particles.emitting = false

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 10.0
	mat.initial_velocity_min = 15.0
	mat.initial_velocity_max = 20.0
	mat.gravity = Vector3(0, -9.8, 0)
	mat.scale_min = 0.02
	mat.scale_max = 0.04
	mat.color = Color(0.7, 0.8, 0.9, 0.4)
	rain_particles.process_material = mat

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.01, 0.1)
	rain_particles.draw_pass_1 = mesh

func set_weather(weather: Weather) -> void:
	if weather == current_weather:
		return
	current_weather = weather
	weather_changed.emit(weather)

	match weather:
		Weather.CLEAR:
			fog_target = 0.0
			wind_strength = 0.0
		Weather.CLOUDY:
			fog_target = 0.1
			wind_strength = 0.2
		Weather.RAIN:
			fog_target = 0.2
			wind_strength = 0.4
		Weather.STORM:
			fog_target = 0.4
			wind_strength = 0.8

func _random_weather_change() -> void:
	var weathers: Array[Weather] = [Weather.CLEAR, Weather.CLOUDY, Weather.RAIN, Weather.STORM]
	var weights: Array[float] = [0.4, 0.3, 0.2, 0.1]

	var roll: float = randf()
	var cumulative: float = 0.0
	for i in range(weathers.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			set_weather(weathers[i])
			return

func get_rain_intensity() -> float:
	return rain_intensity

func get_surface_grip() -> float:
	return surface_grip_multiplier
