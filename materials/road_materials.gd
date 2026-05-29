extends RefCounted

## PBR road material factory: wet/dry asphalt, concrete, dirt with proper roughness.

static func create_asphalt(dry: bool = true) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	if dry:
		mat.albedo_color = Color(0.06, 0.06, 0.07)
		mat.roughness = 0.85
	else:
		mat.albedo_color = Color(0.04, 0.04, 0.05)
		mat.roughness = 0.3
		mat.metallic = 0.1
	mat.metallic = 0.0
	return mat

static func create_concrete() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.4, 0.42)
	mat.roughness = 0.9
	mat.metallic = 0.0
	return mat

static func create_dirt() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.25, 0.15)
	mat.roughness = 0.95
	mat.metallic = 0.0
	return mat

static func create_sand() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.76, 0.7, 0.5)
	mat.roughness = 0.95
	mat.metallic = 0.0
	return mat

static func create_grass() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.35, 0.1)
	mat.roughness = 0.95
	mat.metallic = 0.0
	return mat

static func create_curb() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.1, 0.1)
	mat.roughness = 0.7
	mat.metallic = 0.0
	return mat

static func create_nio_accent() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 0.63, 0.88)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.63, 0.88)
	mat.emission_energy_multiplier = 1.5
	mat.roughness = 0.3
	mat.metallic = 0.5
	return mat
