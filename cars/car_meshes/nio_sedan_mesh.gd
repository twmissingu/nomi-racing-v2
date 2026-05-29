extends RefCounted

## Procedural CSG mesh builder for NIO ET5/ET7 sedan shape.

static func build(parent: Node3D, car_data: Resource, wheels: Array) -> StandardMaterial3D:
	# Clear any existing mesh children
	for child in parent.get_children():
		child.queue_free()
	var body_color: Color = car_data.body_color
	var secondary_color: Color = car_data.secondary_color

	# Determine if this is ET7 (longer, more premium) based on body length
	var is_et7: bool = car_data.body_length > 5.0
	var body_len: float = car_data.body_length

	# --- Main body (sleek sedan profile) ---
	var body := CSGBox3D.new()
	body.name = "Body"
	body.size = Vector3(car_data.body_width, 0.55, body_len)
	body.position = Vector3(0, 0.45, 0)
	body.use_collision = false
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.metallic = 0.6
	body_mat.roughness = 0.25
	body.material = body_mat
	parent.add_child(body)

	# --- Cabin (sloped roofline) ---
	var cabin := CSGBox3D.new()
	cabin.name = "Cabin"
	cabin.size = Vector3(car_data.body_width - 0.25, 0.55, body_len * 0.5)
	cabin.position = Vector3(0, 0.95, -0.1)
	cabin.use_collision = false
	var cabin_mat := StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.08, 0.1, 0.12)
	cabin_mat.metallic = 0.85
	cabin_mat.roughness = 0.08
	cabin_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cabin_mat.albedo_color.a = 0.65
	cabin.material = cabin_mat
	parent.add_child(cabin)

	# --- Hood (longer for sedan) ---
	var hood := CSGBox3D.new()
	hood.name = "Hood"
	hood.size = Vector3(car_data.body_width - 0.1, 0.1, body_len * 0.32)
	hood.position = Vector3(0, 0.72, -body_len * 0.22)
	hood.use_collision = false
	hood.material = body_mat
	parent.add_child(hood)

	# --- Trunk ---
	var trunk := CSGBox3D.new()
	trunk.name = "Trunk"
	trunk.size = Vector3(car_data.body_width - 0.15, 0.35, body_len * 0.18)
	trunk.position = Vector3(0, 0.6, body_len * 0.33)
	trunk.use_collision = false
	trunk.material = body_mat
	parent.add_child(trunk)

	# --- Front bumper with air intake ---
	var front_bumper := CSGBox3D.new()
	front_bumper.name = "FrontBumper"
	front_bumper.size = Vector3(car_data.body_width + 0.08, 0.3, 0.25)
	front_bumper.position = Vector3(0, 0.3, -body_len * 0.47)
	front_bumper.use_collision = false
	front_bumper.material = body_mat
	parent.add_child(front_bumper)

	# --- Rear bumper ---
	var rear_bumper := CSGBox3D.new()
	rear_bumper.name = "RearBumper"
	rear_bumper.size = Vector3(car_data.body_width + 0.08, 0.3, 0.25)
	rear_bumper.position = Vector3(0, 0.3, body_len * 0.47)
	rear_bumper.use_collision = false
	rear_bumper.material = body_mat
	parent.add_child(rear_bumper)

	# --- Headlights (NIO split headlight design) ---
	for side in [-1.0, 1.0]:
		# Upper DRL strip
		var drl := CSGBox3D.new()
		drl.name = "DRL"
		drl.size = Vector3(0.3, 0.05, 0.06)
		drl.position = Vector3(side * (car_data.body_width * 0.36), 0.72, -body_len * 0.48)
		drl.use_collision = false
		var drl_mat := StandardMaterial3D.new()
		drl_mat.albedo_color = Color(0.95, 0.95, 1.0)
		drl_mat.emission_enabled = true
		drl_mat.emission = Color(0.9, 0.95, 1.0)
		drl_mat.emission_energy_multiplier = 2.5
		drl.material = drl_mat
		parent.add_child(drl)

		# Main headlight
		var hl := CSGBox3D.new()
		hl.name = "Headlight"
		hl.size = Vector3(0.3, 0.15, 0.08)
		hl.position = Vector3(side * (car_data.body_width * 0.36), 0.6, -body_len * 0.48)
		hl.use_collision = false
		var hl_mat := StandardMaterial3D.new()
		hl_mat.albedo_color = Color(0.9, 0.92, 1.0)
		hl_mat.emission_enabled = true
		hl_mat.emission = Color(0.85, 0.9, 1.0)
		hl_mat.emission_energy_multiplier = 2.0
		hl.material = hl_mat
		parent.add_child(hl)

	# --- Taillights ---
	var taillight_mat := StandardMaterial3D.new()
	taillight_mat.albedo_color = Color(0.8, 0.05, 0.05)
	taillight_mat.emission_enabled = true
	taillight_mat.emission = Color(0.8, 0.05, 0.05)
	taillight_mat.emission_energy_multiplier = 1.5

	# NIO signature full-width taillight
	var tail_bar := CSGBox3D.new()
	tail_bar.name = "TaillightBar"
	tail_bar.size = Vector3(car_data.body_width - 0.3, 0.06, 0.05)
	tail_bar.position = Vector3(0, 0.68, body_len * 0.49)
	tail_bar.use_collision = false
	tail_bar.material = taillight_mat
	parent.add_child(tail_bar)

	# --- NIO Blue accent strip on hood ---
	var accent_mat := StandardMaterial3D.new()
	accent_mat.albedo_color = Color(0.0, 0.63, 0.88)
	accent_mat.emission_enabled = true
	accent_mat.emission = Color(0.0, 0.63, 0.88)
	accent_mat.emission_energy_multiplier = 1.5

	var accent := CSGBox3D.new()
	accent.name = "NIOAccent"
	accent.size = Vector3(car_data.body_width - 0.5, 0.025, 0.12)
	accent.position = Vector3(0, 0.73, -body_len * 0.1)
	accent.use_collision = false
	accent.material = accent_mat
	parent.add_child(accent)

	# --- Rear spoiler for ET5 ---
	if car_data.rear_spoiler:
		var spoiler := CSGBox3D.new()
		spoiler.name = "Spoiler"
		spoiler.size = Vector3(car_data.body_width * 0.6, 0.04, 0.2)
		spoiler.position = Vector3(0, 0.85, body_len * 0.4)
		spoiler.use_collision = false
		spoiler.material = body_mat
		parent.add_child(spoiler)

		var spoiler_stand_l := CSGBox3D.new()
		spoiler_stand_l.name = "SpoilerStandL"
		spoiler_stand_l.size = Vector3(0.04, 0.15, 0.08)
		spoiler_stand_l.position = Vector3(-car_data.body_width * 0.25, 0.78, body_len * 0.4)
		spoiler_stand_l.use_collision = false
		spoiler_stand_l.material = body_mat
		parent.add_child(spoiler_stand_l)

		var spoiler_stand_r := CSGBox3D.new()
		spoiler_stand_r.name = "SpoilerStandR"
		spoiler_stand_r.size = Vector3(0.04, 0.15, 0.08)
		spoiler_stand_r.position = Vector3(car_data.body_width * 0.25, 0.78, body_len * 0.4)
		spoiler_stand_r.use_collision = false
		spoiler_stand_r.material = body_mat
		parent.add_child(spoiler_stand_r)

	# --- Wheels ---
	_build_wheels(wheels, car_data)

	return taillight_mat

static func _build_wheels(wheels: Array, car_data: Resource) -> void:
	var wheel_mat := StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.12, 0.12, 0.12)
	wheel_mat.metallic = 0.8
	wheel_mat.roughness = 0.2

	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.55, 0.55, 0.6)
	rim_mat.metallic = 0.9
	rim_mat.roughness = 0.08

	for w in wheels:
		if not w is Node3D:
			continue
		var tire := CSGCylinder3D.new()
		tire.name = "Tire"
		tire.radius = car_data.wheel_radius
		tire.height = 0.22
		tire.rotation_degrees.x = 90
		tire.use_collision = false
		tire.material = wheel_mat
		w.add_child(tire)

		var rim := CSGCylinder3D.new()
		rim.name = "Rim"
		rim.radius = car_data.wheel_radius * 0.65
		rim.height = 0.23
		rim.rotation_degrees.x = 90
		rim.use_collision = false
		rim.material = rim_mat
		w.add_child(rim)
