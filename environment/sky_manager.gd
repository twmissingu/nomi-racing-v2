extends Node

## Sky and environment manager: HDR sky, SSAO, Bloom, SSR, reflection probes.
## Manages global visual quality settings and day/night cycle.

# Environment presets
enum SkyPreset { DAY, SUNSET, NIGHT, OVERCAST }

# Current settings
var current_preset: SkyPreset = SkyPreset.DAY
var environment: Environment

# Day/night cycle
var time_of_day: float = 0.5  # 0.0 = midnight, 0.5 = noon, 1.0 = midnight
var day_night_enabled: bool = false
var day_night_speed: float = 0.01  # Full cycle per 100 seconds

# Quality settings
var ssao_enabled: bool = true
var bloom_enabled: bool = true
var ssr_enabled: bool = true
var volumetric_fog_enabled: bool = false

func _ready() -> void:
	# Create default environment
	environment = Environment.new()
	_apply_preset(SkyPreset.DAY)

func _process(delta: float) -> void:
	if day_night_enabled:
		time_of_day = fmod(time_of_day + day_night_speed * delta, 1.0)
		_update_day_night()

func apply_to_world_env(world_env: WorldEnvironment) -> void:
	if world_env and environment:
		world_env.environment = environment

func set_preset(preset: SkyPreset) -> void:
	current_preset = preset
	_apply_preset(preset)

func _apply_preset(preset: SkyPreset) -> void:
	match preset:
		SkyPreset.DAY:
			_apply_day()
		SkyPreset.SUNSET:
			_apply_sunset()
		SkyPreset.NIGHT:
			_apply_night()
		SkyPreset.OVERCAST:
			_apply_overcast()

func _apply_day() -> void:
	# Sky
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.2, 0.4, 0.8)
	sky_mat.sky_horizon_color = Color(0.6, 0.7, 0.9)
	sky_mat.ground_bottom_color = Color(0.1, 0.08, 0.06)
	sky_mat.ground_horizon_color = Color(0.5, 0.5, 0.5)

	var sky := Sky.new()
	sky.sky_material = sky_mat
	environment.sky = sky

	# Environment
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.5
	environment.tonemap_mode = Environment.TONE_MAP_FILMIC

	# Post-processing
	environment.ssao_enabled = ssao_enabled
	environment.ssao_radius = 1.5
	environment.ssao_intensity = 2.0

	environment.glow_enabled = bloom_enabled
	environment.glow_intensity = 0.8
	environment.glow_bloom = 0.2

	environment.ssr_enabled = ssr_enabled
	environment.ssr_max_steps = 64

	environment.volumetric_fog_enabled = volumetric_fog_enabled

func _apply_sunset() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.15, 0.1, 0.3)
	sky_mat.sky_horizon_color = Color(0.9, 0.4, 0.1)
	sky_mat.ground_bottom_color = Color(0.08, 0.05, 0.03)
	sky_mat.ground_horizon_color = Color(0.6, 0.3, 0.1)

	var sky := Sky.new()
	sky.sky_material = sky_mat
	environment.sky = sky

	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.4
	environment.tonemap_mode = Environment.TONE_MAP_FILMIC

	environment.ssao_enabled = ssao_enabled
	environment.glow_enabled = bloom_enabled
	environment.glow_intensity = 1.0
	environment.glow_bloom = 0.3

func _apply_night() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.02, 0.02, 0.06)
	sky_mat.sky_horizon_color = Color(0.05, 0.05, 0.1)
	sky_mat.ground_bottom_color = Color(0.01, 0.01, 0.02)
	sky_mat.ground_horizon_color = Color(0.03, 0.03, 0.06)

	var sky := Sky.new()
	sky.sky_material = sky_mat
	environment.sky = sky

	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.08, 0.08, 0.12)
	environment.ambient_light_energy = 0.3
	environment.tonemap_mode = Environment.TONE_MAP_FILMIC

	environment.ssao_enabled = ssao_enabled
	environment.glow_enabled = bloom_enabled
	environment.glow_intensity = 1.2
	environment.glow_bloom = 0.3

func _apply_overcast() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.4, 0.42, 0.45)
	sky_mat.sky_horizon_color = Color(0.5, 0.5, 0.52)
	sky_mat.ground_bottom_color = Color(0.2, 0.2, 0.2)
	sky_mat.ground_horizon_color = Color(0.4, 0.4, 0.4)

	var sky := Sky.new()
	sky.sky_material = sky_mat
	environment.sky = sky

	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.6
	environment.tonemap_mode = Environment.TONE_MAP_FILMIC

	environment.ssao_enabled = ssao_enabled
	environment.glow_enabled = bloom_enabled
	environment.glow_intensity = 0.5

func _update_day_night() -> void:
	# Smoothly interpolate between presets based on time_of_day
	if time_of_day < 0.25:  # Night to sunrise
		_apply_night()
	elif time_of_day < 0.35:  # Sunrise
		_apply_sunset()
	elif time_of_day < 0.65:  # Day
		_apply_day()
	elif time_of_day < 0.75:  # Sunset
		_apply_sunset()
	else:  # Night
		_apply_night()

func set_quality_level(level: int) -> void:
	# 0=Low, 1=Medium, 2=High, 3=Ultra
	match level:
		0:
			ssao_enabled = false
			bloom_enabled = false
			ssr_enabled = false
			volumetric_fog_enabled = false
		1:
			ssao_enabled = true
			bloom_enabled = true
			ssr_enabled = false
			volumetric_fog_enabled = false
		2:
			ssao_enabled = true
			bloom_enabled = true
			ssr_enabled = true
			volumetric_fog_enabled = false
		3:
			ssao_enabled = true
			bloom_enabled = true
			ssr_enabled = true
			volumetric_fog_enabled = true
