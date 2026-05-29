extends RefCounted

## World-space UV terrain material for consistent texture scale regardless of mesh size.

static func create_terrain(color: Color = Color(0.15, 0.35, 0.1)) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	mat.metallic = 0.0
	# World-space UV would require a shader; for now use standard material
	return mat

static func create_rock() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.28, 0.25)
	mat.roughness = 0.9
	mat.metallic = 0.0
	return mat

static func create_snow() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.92, 0.95)
	mat.roughness = 0.7
	mat.metallic = 0.0
	return mat
