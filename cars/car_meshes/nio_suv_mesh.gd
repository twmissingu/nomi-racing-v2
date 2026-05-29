extends RefCounted

## Procedural CSG mesh builder for NIO ES7 SUV shape.

static func build(parent: Node3D, car_data: Resource, wheels: Array) -> StandardMaterial3D:
	var body_color: Color = car_data.body_color
	var secondary_color: Color = car_data.secondary_color

	# --- Main body (SUV shape: taller, boxier) ---
	var body := CSGBox3D.new()
	body.name = "Body"
	body.size = Vector3(car_data.body_width, 0.7, car_data.body_length)
	body.position = Vector3(0, 0.55, 0)
	body.use_collision = false
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.metallic = 0.6
	body_mat.roughness = 0.3
	body.material = body_mat
	parent.add_child(body)

	# --- Cabin (taller for SUV) ---
	var cabin := CSGBox3D.new()
	cabin.name = "Cabin"
	cabin.size = Vector3(car_data.body_width - 0.2, 0.65, car_data.body_length * 0.55)
	cabin.position = Vector3(0, 1.15, -0.2)
	cabin.use_collision = false
	var cabin_mat := StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.1, 0.12, 0.15)
	cabin_mat.metallic = 0.8
	cabin_mat.roughness = 0.1
	cabin_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cabin_mat.albedo_color.a = 0.7
	cabin.material = cabin_mat
	parent.add_child(cabin)

	# --- Hood ---
	var hood := CSGBox3D.new()
	hood.name = "Hood"
	hood.size = Vector3(car_data.body_width - 0.1, 0.12, car_data.body_length * 0.3)
	hood.position = Vector3(0, 0.85, -car_data.body_length * 0.25)
	hood.use_collision = false
	hood.material = body_mat
	parent.add_child(hood)

	# --- Rear section ---
	var rear := CSGBox3D.new()
	rear.name = "Rear"
	rear.size = Vector3(car_data.body_width - 0.1, 0.5, car_data.body_length * 0.15)
	rear.position = Vector3(0, 0.7, car_data.body_length * 0.35)
	rear.use_collision = false
	rear.material = body_mat
	parent.add_child(rear)

	# --- Front bumper ---
	var front_bumper := CSGBox3D.new()
	front_bumper.name = "FrontBumper"
	front_bumper.size = Vector3(car_data.body_width + 0.1, 0.35, 0.3)
	front_bumper.position = Vector3(0, 0.35, -car_data.body_length * 0.48)
	front_bumper.use_collision = false
	front_bumper.material = body_mat
	parent.add_child(front_bumper)

	# --- Rear bumper ---
	var rear_bumper := CSGBox3D.new()
	rear_bumper.name = "RearBumper"
	rear_bumper.size = Vector3(car_data.body_width + 0.1, 0.35, 0.3)
	rear_bumper.position = Vector3(0, 0.35, car_data.body_length * 0.48)
	rear_bumper.use_collision = false
	rear_bumper.material = body_mat
	parent.add_child(rear_bumper)

	# --- Headlights ---
	for side in [-1.0, 1.0]:
		var light := CSGBox3D.new()
		light.name = "Headlight"
		light.size = Vector3(0.35, 0.12, 0.08)
		light.position = Vector3(side * (car_data.body_width * 0.38), 0.75, -car_data.body_length * 0.49)
		light.use_collision = false
		var light_mat := StandardMaterial3D.new()
		light_mat.albedo_color = Color(0.95, 0.95, 1.0)
		light_mat.emission_enabled = true
		light_mat.emission = Color(0.9, 0.95, 1.0)
		light_mat.emission_energy_multiplier = 2.0
		light.material = light_mat
		parent.add_child(light)

	# --- Taillights ---
	var taillight_mat := StandardMaterial3D.new()
	taillight_mat.albedo_color = Color(0.8, 0.05, 0.05)
	taillight_mat.emission_enabled = true
	taillight_mat.emission = Color(0.8, 0.05, 0.05)
	taillight_mat.emission_energy_multiplier = 1.5

	# Full-width LED taillight bar (NIO signature)
	var tail_bar := CSGBox3D.new()
	tail_bar.name = "TaillightBar"
	tail_bar.size = Vector3(car_data.body_width - 0.3, 0.08, 0.06)
	tail_bar.position = Vector3(0, 0.75, car_data.body_length * 0.49)
	tail_bar.use_collision = false
	tail_bar.material = taillight_mat
	parent.add_child(tail_bar)

	# --- NIO Blue accent strip ---
	var accent_mat := StandardMaterial3D.new()
	accent_mat.albedo_color = Color(0.0, 0.63, 0.88)
	accent_mat.emission_enabled = true
	accent_mat.emission = Color(0.0, 0.63, 0.88)
	accent_mat.emission_energy_multiplier = 1.5

	var accent_strip := CSGBox3D.new()
	accent_strip.name = "NIOAccent"
	accent_strip.size = Vector3(car_data.body_width - 0.4, 0.03, 0.15)
	accent_strip.position = Vector3(0, 0.88, -car_data.body_length * 0.15)
	accent_strip.use_collision = false
	accent_strip.material = accent_mat
	parent.add_child(accent_strip)

	# --- Wheels (visual only — VehicleWheel3D handles physics) ---
	_build_wheels(wheels, car_data)

	return taillight_mat

static func _build_wheels(wheels: Array, car_data: Resource) -> void:
	var wheel_mat := StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.15, 0.15, 0.15)
	wheel_mat.metallic = 0.8
	wheel_mat.roughness = 0.2

	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.6, 0.6, 0.65)
	rim_mat.metallic = 0.9
	rim_mat.roughness = 0.1

	for w in wheels:
		if not w is Node3D:
			continue
		# Tire
		var tire := CSGCylinder3D.new()
		tire.name = "Tire"
		tire.radius = car_data.wheel_radius
		tire.height = 0.25
		tire.rotation_degrees.x = 90
		tire.use_collision = false
		tire.material = wheel_mat
		w.add_child(tire)

		# Rim
		var rim := CSGCylinder3D.new()
		rim.name = "Rim"
		rim.radius = car_data.wheel_radius * 0.65
		rim.height = 0.26
		rim.rotation_degrees.x = 90
		rim.use_collision = false
		rim.material = rim_mat
		w.add_child(rim)
