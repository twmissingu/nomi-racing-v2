extends Node

## Procedural texture generator for NOMI Racing
## Creates all required textures at runtime

static func generate_road_texture() -> ImageTexture:
	var img := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for x in range(512):
		for y in range(512):
			# Dark asphalt with subtle noise
			var noise_val: float = randf_range(0.03, 0.07)
			var base: float = 0.06 + noise_val
			# Lane markings
			if abs(x - 256) < 2 and y % 64 < 32:
				base = 0.9
			img.set_pixel(x, y, Color(base, base, base + 0.01))
	return ImageTexture.create_from_image(img)

static func generate_grass_texture() -> ImageTexture:
	var img := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	for x in range(256):
		for y in range(256):
			var noise_val: float = randf_range(-0.05, 0.05)
			var g: float = 0.3 + noise_val
			img.set_pixel(x, y, Color(0.1 + noise_val * 0.5, g, 0.08))
	return ImageTexture.create_from_image(img)

static func generate_concrete_texture() -> ImageTexture:
	var img := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	for x in range(256):
		for y in range(256):
			var noise_val: float = randf_range(-0.03, 0.03)
			var base: float = 0.4 + noise_val
			img.set_pixel(x, y, Color(base, base, base + 0.02))
	return ImageTexture.create_from_image(img)

static func generate_tire_mark_texture() -> ImageTexture:
	var img := Image.create(64, 128, false, Image.FORMAT_RGBA8)
	for x in range(64):
		for y in range(128):
			# Dark mark with fade at edges
			var edge_fade: float = 1.0 - abs(float(x) / 32.0 - 1.0)
			var alpha: float = edge_fade * 0.6
			img.set_pixel(x, y, Color(0.05, 0.05, 0.05, alpha))
	return ImageTexture.create_from_image(img)

static func generate_nio_logo_texture() -> ImageTexture:
	var img := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	# NIO Blue background
	for x in range(128):
		for y in range(128):
			var dist: float = Vector2(x - 64, y - 64).length()
			if dist < 60:
				img.set_pixel(x, y, Color(0.0, 0.63, 0.88, 1.0))
			else:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	# NIO text (simplified)
	for x in range(30, 98):
		for y in range(45, 83):
			if x > 35 and x < 45:
				img.set_pixel(x, y, Color.WHITE)
			elif x > 55 and x < 65:
				img.set_pixel(x, y, Color.WHITE)
			elif x > 75 and x < 85:
				img.set_pixel(x, y, Color.WHITE)
	return ImageTexture.create_from_image(img)
