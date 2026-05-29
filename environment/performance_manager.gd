extends Node

## Performance manager: quality presets, FPS monitoring, dynamic quality adjustment.

enum QualityLevel { LOW, MEDIUM, HIGH, ULTRA }

signal quality_changed(level: QualityLevel)

var current_level: QualityLevel = QualityLevel.MEDIUM
var target_fps: int = 60
var auto_adjust: bool = true

# Performance counters
var fps_history: Array[float] = []
var fps_sample_interval: float = 1.0
var fps_sample_timer: float = 0.0

# Quality settings per level
const QUALITY_SETTINGS := {
	QualityLevel.LOW: {
		"msaa": 0,
		"ssao": false,
		"bloom": false,
		"ssr": false,
		"volumetric_fog": false,
		"shadow_resolution": 512,
		"draw_distance": 500.0,
		"particle_count": 0.5,
	},
	QualityLevel.MEDIUM: {
		"msaa": 1,
		"ssao": true,
		"bloom": true,
		"ssr": false,
		"volumetric_fog": false,
		"shadow_resolution": 1024,
		"draw_distance": 800.0,
		"particle_count": 0.75,
	},
	QualityLevel.HIGH: {
		"msaa": 2,
		"ssao": true,
		"bloom": true,
		"ssr": true,
		"volumetric_fog": false,
		"shadow_resolution": 2048,
		"draw_distance": 1000.0,
		"particle_count": 1.0,
	},
	QualityLevel.ULTRA: {
		"msaa": 4,
		"ssao": true,
		"bloom": true,
		"ssr": true,
		"volumetric_fog": true,
		"shadow_resolution": 4096,
		"draw_distance": 1500.0,
		"particle_count": 1.0,
	},
}

func _ready() -> void:
	_apply_quality(current_level)

func _process(delta: float) -> void:
	fps_sample_timer += delta
	if fps_sample_timer >= fps_sample_interval:
		fps_sample_timer = 0.0
		var current_fps: float = Engine.get_frames_per_second()
		fps_history.append(current_fps)
		if fps_history.size() > 10:
			fps_history.pop_front()

		if auto_adjust:
			_check_performance()

func _check_performance() -> void:
	if fps_history.size() < 5:
		return

	var avg_fps: float = 0.0
	for fps in fps_history:
		avg_fps += fps
	avg_fps /= fps_history.size()

	# Downgrade if FPS is too low
	if avg_fps < target_fps * 0.85 and current_level > QualityLevel.LOW:
		set_quality(current_level - 1)
	# Upgrade if FPS has headroom
	elif avg_fps > target_fps * 1.15 and current_level < QualityLevel.ULTRA:
		set_quality(current_level + 1)

func set_quality(level: QualityLevel) -> void:
	if level == current_level:
		return
	current_level = level
	_apply_quality(level)
	quality_changed.emit(level)

func _apply_quality(level: QualityLevel) -> void:
	var settings: Dictionary = QUALITY_SETTINGS[level]

	# MSAA
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", settings.msaa)

	# Shadow resolution
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", settings.shadow_resolution)

	# Viewport settings
	var viewport := get_viewport()
	if viewport:
		viewport.msaa_3d = settings.msaa as Viewport.MSAA

func get_particle_scale() -> float:
	return QUALITY_SETTINGS[current_level].particle_count

func get_draw_distance() -> float:
	return QUALITY_SETTINGS[current_level].draw_distance
