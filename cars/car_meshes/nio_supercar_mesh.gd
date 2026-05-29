extends RefCounted

## Procedural CSG mesh builder for NIO EP9 electric supercar.

static func build(parent: Node3D, car_data: Resource, wheels: Array) -> StandardMaterial3D:
	var body_color: Color = car_data.body_color

	# --- Main body (low, wide, aggressive) ---
	var body := CSGBox3D.new()
	body.name = "Body"
	body.size = Vector3(car_data.body_width, 0.35, car_data.body_length)
	body.position = Vector3(0, 0.3, 0)
	body.use_collision = false
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.metallic = 0.7
	body_mat.roughness = 0.2
	body.material = body_mat
	parent.add_child(body)

	# --- Cabin (tiny, fighter-jet style) ---
	var cabin := CSGBox3D.new()
	cabin.name = "Cabin"
	cabin.size = Vector3(1.2, 0.4, 1.5)
	cabin.position = Vector3(0, 0.65, -0.2)
	cabin.use_collision = false
	var cabin_mat := StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.05, 0.05, 0.08)
	cabin_mat.metallic = 0.9
	cabin_mat.roughness = 0.05
	cabin_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cabin_mat.albedo_color.a = 0.6
	cabin.material = cabin_mat
	parent.add_child(cabin)

	# --- Hood (long, low, sculpted) ---
	var hood := CSGBox3D.new()
	hood.name = "Hood"
	hood.size = Vector3(car_data.body_width - 0.2, 0.08, car_data.body_length * 0.35)
	hood.position = Vector3(0, 0.42, -car_data.body_length * 0.2)
	hood.use_collision = false
	hood.material = body_mat
	parent.add_child(hood)

	# --- Rear deck (engine cover) ---
	var rear_deck := CSGBox3D.new()
	rear_deck.name = "RearDeck"
	rear_deck.size = Vector3(car_data.body_width - 0.3, 0.15, car_data.body_length * 0.2)
	rear_deck.position = Vector3(0, 0.42, car_data.body_length * 0.25)
	rear_deck.use_collision = false
	rear_deck.material = body_mat
	parent.add_child(rear_deck)

	# --- Front splitter ---
	var splitter := CSGBox3D.new()
	splitter.name = "FrontSplitter"
	splitter.size = Vector3(car_data.body_width + 0.2, 0.04, 0.4)
	splitter.position = Vector3(0, 0.15, -car_data.body_length * 0.48)
	splitter.use_collision = false
	var splitter_mat := StandardMaterial3D.new()
	splitter_mat.albedo_color = Color(0.08, 0.08, 0.08)
	splitter_mat.metallic = 0.3
	splitter_mat.roughness = 0.6
	splitter.material = splitter_mat
	parent.add_child(splitter)

	# --- Rear diffuser ---
	var diffuser := CSGBox3D.new()
	diffuser.name = "RearDiffuser"
	diffuser.size = Vector3(car_data.body_width - 0.2, 0.15, 0.5)
	diffuser.position = Vector3(0, 0.18, car_data.body_length * 0.46)
	diffuser.use_collision = false
	diffuser.material = splitter_mat
	parent.add_child(diffuser)

	# --- Massive rear wing ---
	var wing_mat := StandardMaterial3D.new()
	wing_mat.albedo_color = Color(0.1, 0.1, 0.1)
	wing_mat.metallic = 0.5
	wing_mat.roughness = 0.3

	# Wing blade
	var wing := CSGBox3D.new()
	wing.name = "WingBlade"
	wing.size = Vector3(car_data.body_width + 0.3, 0.04, 0.35)
	wing.position = Vector3(0, 1.1, car_data.body_length * 0.35)
	wing.use_collision = false
	wing.rotation_degrees.x = -8
	wing.material = wing_mat
	parent.add_child(wing)

	# Wing endplates
	for side in [-1.0, 1.0]:
		var endplate := CSGBox3D.new()
		endplate.name = "WingEndplate"
		endplate.size = Vector3(0.04, 0.3, 0.4)
		endplate.position = Vector3(side * (car_data.body_width * 0.55 + 0.15), 1.0, car_data.body_length * 0.35)
		endplate.use_collision = false
		endplate.material = wing_mat
		parent.add_child(endplate)

	# Wing supports (pylons)
	for side in [-1.0, 1.0]:
		var pylon := CSGBox3D.new()
		pylon.name = "WingPylon"
		pylon.size = Vector3(0.05, 0.5, 0.08)
		pylon.position = Vector3(side * (car_data.body_width * 0.35), 0.8, car_data.body_length * 0.35)
		pylon.use_collision = false
		pylon.material = wing_mat
		parent.add_child(pylon)

	# --- Front canards (aero) ---
	for side in [-1.0, 1.0]:
		var canard := CSGBox3D.new()
		canard.name = "Canard"
		canard.size = Vector3(0.04, 0.06, 0.25)
		canard.position = Vector3(side * (car_data.body_width * 0.45), 0.22, -car_data.body_length * 0.4)
		canard.use_collision = false
		canard.material = splitter_mat
		parent.add_child(canard)

	# --- Headlights (narrow, aggressive) ---
	for side in [-1.0, 1.0]:
		var light := CSGBox3D.new()
		light.name = "Headlight"
		light.size = Vector3(0.35, 0.06, 0.06)
		light.position = Vector3(side * (car_data.body_width * 0.35), 0.42, -car_data.body_length * 0.49)
		light.use_collision = false
		var light_mat := StandardMaterial3D.new()
		light_mat.albedo_color = Color(0.95, 0.95, 1.0)
		light_mat.emission_enabled = true
		light_mat.emission = Color(0.9, 0.95, 1.0)
		light_mat.emission_energy_multiplier = 3.0
		light.material = light_mat
		parent.add_child(light)

	# --- Taillights ---
	var taillight_mat := StandardMaterial3D.new()
	taillight_mat.albedo_color = Color(0.8, 0.05, 0.05)
	taillight_mat.emission_enabled = true
	taillight_mat.emission = Color(0.8, 0.05, 0.05)
	taillight_mat.emission_energy_multiplier = 2.0

	# Full-width LED bar
	var tail_bar := CSGBox3D.new()
	tail_bar.name = "TaillightBar"
	tail_bar.size = Vector3(car_data.body_width - 0.4, 0.04, 0.04)
	tail_bar.position = Vector3(0, 0.42, car_data.body_length * 0.49)
	tail_bar.use_collision = false
	tail_bar.material = taillight_mat
	parent.add_child(tail_bar)

	# --- NIO Blue accent on side skirts ---
	var accent_mat := StandardMaterial3D.new()
	accent_mat.albedo_color = Color(0.0, 0.63, 0.88)
	accent_mat.emission_enabled = true
	accent_mat.emission = Color(0.0, 0.63, 0.88)
	accent_mat.emission_energy_multiplier = 1.5

	for side in [-1.0, 1.0]:
		var skirt := CSGBox3D.new()
		skirt.name = "SideSkirtAccent"
		skirt.size = Vector3(0.03, 0.04, car_data.body_length * 0.5)
		skirt.position = Vector3(side * (car_data.body_width * 0.5 + 0.01), 0.15, 0)
		skirt.use_collision = false
		skirt.material = accent_mat
		parent.add_child(skirt)

	# --- Wheels ---
	_build_wheels(wheels, car_data)

	return taillight_mat

static func _build_wheels(wheels: Array, car_data: Resource) -> void:
	var wheel_mat := StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.1, 0.1, 0.1)
	wheel_mat.metallic = 0.85
	wheel_mat.roughness = 0.15

	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.7, 0.7, 0.75)
	rim_mat.metallic = 0.95
	rim_mat.roughness = 0.05

	for w in wheels:
		if not w is Node3D:
			continue
		var tire := CSGCylinder3D.new()
		tire.name = "Tire"
		tire.radius = car_data.wheel_radius
		tire.height = 0.28
		tire.rotation_degrees.x = 90
		tire.use_collision = false
		tire.material = wheel_mat
		w.add_child(tire)

		var rim := CSGCylinder3D.new()
		rim.name = "Rim"
		rim.radius = car_data.wheel_radius * 0.7
		rim.height = 0.29
		rim.rotation_degrees.x = 90
		rim.use_collision = false
		rim.material = rim_mat
		w.add_child(rim)
