extends Node

## Tire mark system using Decal pooling for performance.
## Creates persistent tire marks on the road surface.

var decal_pool: Array[Decal3D] = []
var pool_size: int = 100
var next_index: int = 0
var mark_lifetime: float = 30.0

# Tire mark texture (created procedurally)
var mark_texture: ImageTexture

func _ready() -> void:
	_create_mark_texture()
	_init_pool()

func _create_mark_texture() -> void:
	# Create a simple dark rectangle texture for tire marks
	var img := Image.create(32, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.05, 0.05, 0.05, 0.6))
	mark_texture = ImageTexture.create_from_image(img)

func _init_pool() -> void:
	for i in range(pool_size):
		var decal := Decal3D.new()
		decal.name = "TireMark%d" % i
		decal.size = Vector3(0.3, 0.01, 0.5)
		decal.texture_albedo = mark_texture
		decal.albedo_mix = 1.0
		decal.modulate = Color(0.1, 0.1, 0.1, 0.5)
		decal.visible = false
		add_child(decal)
		decal_pool.append(decal)

func add_tire_mark(position: Vector3, rotation: Basis, intensity: float) -> void:
	if intensity < 0.3:
		return

	var decal: Decal3D = decal_pool[next_index]
	next_index = (next_index + 1) % pool_size

	decal.global_position = position + Vector3.UP * 0.02
	decal.global_transform.basis = rotation
	decal.modulate.a = clampf(intensity * 0.5, 0.1, 0.5)
	decal.visible = true

	# Fade out over time
	var tween := create_tween()
	tween.tween_property(decal, "modulate:a", 0.0, mark_lifetime)
	tween.tween_callback(func(): decal.visible = false)

func clear_all() -> void:
	for decal in decal_pool:
		decal.visible = false
	next_index = 0
