extends RefCounted


static func create(data: Dictionary, _sidecar: Dictionary) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	var asset_id := str(data.get("asset_id", ""))
	var modifiers: Dictionary = data.get("modifiers", {})

	var config := _base_config(asset_id)
	_apply_theme(config, str(modifiers.get("particle_theme", "default")))
	_apply_intensity(config, str(modifiers.get("particle_intensity", "normal")))
	_apply_direction(config, str(modifiers.get("particle_direction", "default")))
	_apply_to_particles(particles, config)

	return particles


static func _base_config(asset_id: String) -> Dictionary:
	var config := {
		"amount": 20,
		"lifetime": 1.0,
		"gravity": Vector2(0, -90),
		"velocity_min": 20.0,
		"velocity_max": 50.0,
		"color_ramp": null,
		"scale_curve": null,
		"single_color": Color.WHITE,
		"has_single_color": false,
	}

	match asset_id:
		"effects_fire":
			config.amount = 35
			config.lifetime = 0.8
			config.gravity = Vector2(0, -180)
			config.velocity_min = 40.0
			config.velocity_max = 80.0
			config.color_ramp = _gradient([
				[0.0, Color(1.0, 0.2, 0.0, 1.0)],
				[0.5, Color(1.0, 0.8, 0.0, 1.0)],
				[1.0, Color(1.0, 0.2, 0.0, 0.0)],
			])
			config.scale_curve = _curve([
				Vector2(0, 6.0),
				Vector2(1, 1.0),
			])
		"effects_sparkles":
			config.amount = 15
			config.lifetime = 1.2
			config.gravity = Vector2.ZERO
			config.velocity_min = 10.0
			config.velocity_max = 30.0
			config.color_ramp = _gradient([
				[0.0, Color(1.0, 0.9, 0.4, 1.0)],
				[0.5, Color(0.4, 0.9, 1.0, 1.0)],
				[1.0, Color(0.4, 0.9, 1.0, 0.0)],
			])
			config.scale_curve = _curve([
				Vector2(0, 0.0),
				Vector2(0.2, 4.0),
				Vector2(0.8, 4.0),
				Vector2(1, 0.0),
			])
		"effects_snow":
			config.amount = 25
			config.lifetime = 2.0
			config.gravity = Vector2(0, 80)
			config.velocity_min = 20.0
			config.velocity_max = 40.0
			config.single_color = Color(1.0, 1.0, 1.0, 0.9)
			config.has_single_color = true
			config.color_ramp = _gradient([
				[0.0, Color(1.0, 1.0, 1.0, 0.9)],
				[1.0, Color(1.0, 1.0, 1.0, 0.0)],
			])
		"effects_hearts":
			config.amount = 10
			config.lifetime = 1.5
			config.gravity = Vector2(0, -60)
			config.velocity_min = 20.0
			config.velocity_max = 50.0
			config.color_ramp = _gradient([
				[0.0, Color(1.0, 0.4, 0.6, 1.0)],
				[0.6, Color(1.0, 0.1, 0.4, 1.0)],
				[1.0, Color(1.0, 0.1, 0.4, 0.0)],
			])
			config.scale_curve = _curve([
				Vector2(0, 1.0),
				Vector2(0.4, 5.0),
				Vector2(0.8, 5.0),
				Vector2(1, 0.0),
			])
		"effects_smoke":
			config.amount = 15
			config.lifetime = 2.0
			config.gravity = Vector2(10, -50)
			config.velocity_min = 15.0
			config.velocity_max = 30.0
			config.color_ramp = _gradient([
				[0.0, Color(0.7, 0.7, 0.7, 0.8)],
				[0.5, Color(0.8, 0.8, 0.8, 0.4)],
				[1.0, Color(0.9, 0.9, 0.9, 0.0)],
			])
			config.scale_curve = _curve([
				Vector2(0, 3.0),
				Vector2(0.5, 8.0),
				Vector2(1, 12.0),
			])
		_:
			config.amount = 10
			config.single_color = Color(1.0, 1.0, 1.0, 1.0)
			config.has_single_color = true

	return config


static func _apply_theme(config: Dictionary, theme_type: String) -> void:
	if theme_type == "default" or theme_type == "":
		return

	config.has_single_color = false
	match theme_type:
		"rainbow":
			config.color_ramp = _gradient([
				[0.0, Color(1.0, 0.0, 0.0, 1.0)],
				[0.2, Color(1.0, 1.0, 0.0, 1.0)],
				[0.4, Color(0.0, 1.0, 0.0, 1.0)],
				[0.6, Color(0.0, 1.0, 1.0, 1.0)],
				[0.8, Color(0.5, 0.0, 1.0, 1.0)],
				[1.0, Color(1.0, 0.0, 0.0, 0.0)],
			])
		"neon":
			config.color_ramp = _gradient([
				[0.0, Color(0.0, 1.0, 0.9, 1.0)],
				[0.5, Color(1.0, 0.0, 0.9, 1.0)],
				[1.0, Color(0.0, 1.0, 0.0, 0.0)],
			])
		"frost":
			config.color_ramp = _gradient([
				[0.0, Color(0.8, 0.95, 1.0, 1.0)],
				[0.5, Color(0.2, 0.7, 1.0, 1.0)],
				[1.0, Color(0.0, 0.4, 0.8, 0.0)],
			])
		"shadow":
			config.color_ramp = _gradient([
				[0.0, Color(0.4, 0.0, 0.6, 1.0)],
				[0.5, Color(0.1, 0.1, 0.15, 1.0)],
				[1.0, Color(0.0, 0.0, 0.0, 0.0)],
			])


static func _apply_intensity(config: Dictionary, intensity: String) -> void:
	if intensity == "calm":
		config.amount = int(config.amount * 0.4)
		config.lifetime = config.lifetime * 1.5
		config.velocity_min *= 0.5
		config.velocity_max *= 0.5
	elif intensity == "wild":
		config.amount = int(config.amount * 2.2)
		config.lifetime = config.lifetime * 0.7
		config.velocity_min *= 1.8
		config.velocity_max *= 1.8


static func _apply_direction(config: Dictionary, direction_type: String) -> void:
	if direction_type == "default" or direction_type == "":
		return

	var gravity_vec: Vector2 = config.gravity
	var gravity_magnitude: float = max(abs(gravity_vec.x), abs(gravity_vec.y))
	if gravity_magnitude == 0.0:
		gravity_magnitude = 120.0

	match direction_type:
		"up":
			config.gravity = Vector2(0, -gravity_magnitude)
		"down":
			config.gravity = Vector2(0, gravity_magnitude)
		"left":
			config.gravity = Vector2(-gravity_magnitude, 0)
		"right":
			config.gravity = Vector2(gravity_magnitude, 0)


static func _apply_to_particles(particles: CPUParticles2D, config: Dictionary) -> void:
	particles.amount = max(2, int(config.amount))
	particles.lifetime = float(config.lifetime)
	particles.gravity = config.gravity
	particles.initial_velocity_min = float(config.velocity_min)
	particles.initial_velocity_max = float(config.velocity_max)

	if config.color_ramp != null:
		particles.color_ramp = config.color_ramp
	if config.scale_curve != null:
		particles.scale_amount_curve = config.scale_curve
	if bool(config.has_single_color):
		particles.color = config.single_color

	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(16, 16)
	particles.randomness = 0.5
	particles.emitting = true


static func _gradient(stops: Array) -> Gradient:
	var gradient := Gradient.new()
	for i in range(stops.size()):
		var stop: Array = stops[i]
		if i == 0:
			gradient.set_color(0, stop[1])
		elif is_equal_approx(float(stop[0]), 1.0):
			gradient.set_color(1, stop[1])
		else:
			gradient.add_point(float(stop[0]), stop[1])
	return gradient


static func _curve(points: Array) -> Curve:
	var curve := Curve.new()
	for point in points:
		curve.add_point(point)
	return curve
