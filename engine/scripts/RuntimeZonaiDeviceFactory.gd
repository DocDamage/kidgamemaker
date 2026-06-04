extends RefCounted


static func create(app, data: Dictionary, sidecar: Dictionary, type: String, spring_script: Script, beam_script: Script) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(body, size)
	app._add_visuals(body, sidecar, size, Color(0.1, 0.6, 0.4))

	body.set_meta("asset_id", type)
	body.set_meta("collision_size", size)

	var mods: Dictionary = data.get("modifiers", {})

	if type == "zonai_fan":
		_configure_fan(body, mods)
	elif type == "zonai_rocket":
		_configure_rocket(body, mods)
	elif type == "zonai_balloon":
		_configure_balloon(body, mods)
	elif type == "zonai_spring":
		_configure_spring(body, mods, size, spring_script)
	elif type == "zonai_beam":
		_configure_beam(body, mods, beam_script)
	elif type == "zonai_battery":
		_configure_battery(body, mods)

	return body


static func _configure_fan(body: StaticBody2D, mods: Dictionary) -> void:
	var direction := str(mods.get("zonai_direction", "right"))
	body.set("force_direction", direction_string_to_vector(direction))
	body.set("force_magnitude", float(mods.get("wind_force", 400.0)))
	body.set("powered", true)

	var particles := CPUParticles2D.new()
	particles.name = "WindParticles"
	particles.amount = 8
	particles.lifetime = 0.5
	particles.direction = direction_string_to_vector(direction)
	particles.spread = 15.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.color = Color(1.0, 1.0, 1.0, 0.3)
	particles.position = Vector2.ZERO
	body.add_child(particles)


static func _configure_rocket(body: StaticBody2D, mods: Dictionary) -> void:
	var direction := str(mods.get("zonai_direction", "up"))
	body.set("force_direction", direction_string_to_vector(direction))
	body.set("force_magnitude", float(mods.get("thrust_force", 1000.0)))
	body.set("active", true)
	body.set("active_time", float(mods.get("duration", 2.0)))
	body.set("powered", true)

	var particles := CPUParticles2D.new()
	particles.name = "FireParticles"
	particles.amount = 15
	particles.lifetime = 0.4
	particles.direction = -direction_string_to_vector(direction)
	particles.spread = 20.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 250.0
	particles.color = Color(1.0, 0.5, 0.1)
	particles.position = Vector2.ZERO
	body.add_child(particles)


static func _configure_balloon(body: StaticBody2D, mods: Dictionary) -> void:
	body.set("buoyancy_force", float(mods.get("lift_force", 300.0)))
	var balloon := ColorRect.new()
	balloon.color = Color(0.9, 0.2, 0.2, 0.7)
	balloon.size = Vector2(40, 40)
	balloon.position = Vector2(-20, -60)
	body.add_child(balloon)


static func _configure_spring(body: StaticBody2D, mods: Dictionary, size: Vector2, spring_script: Script) -> void:
	var direction := str(mods.get("zonai_direction", "up"))
	body.set("launch_direction", direction_string_to_vector(direction))
	body.set("launch_force", float(mods.get("spring_force", 600.0)))
	var area := Area2D.new()
	var col_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size + Vector2(8, 8)
	col_shape.shape = rect
	area.add_child(col_shape)
	body.add_child(area)
	area.set_script(spring_script)


static func _configure_beam(body: StaticBody2D, mods: Dictionary, beam_script: Script) -> void:
	var direction := str(mods.get("zonai_direction", "right"))
	var direction_vector := direction_string_to_vector(direction)
	body.set("force_direction", direction_vector)
	body.set("laser_damage", float(mods.get("damage", 15.0)))
	body.set("powered", true)
	var line := Line2D.new()
	line.name = "LaserLine"
	line.points = PackedVector2Array([Vector2.ZERO, direction_vector * float(mods.get("beam_range", 300.0))])
	line.width = 4.0
	line.default_color = Color.RED
	body.add_child(line)
	body.set_script(beam_script)


static func _configure_battery(body: StaticBody2D, mods: Dictionary) -> void:
	body.set("energy", float(mods.get("battery_capacity", 100.0)))
	body.set("max_energy", float(mods.get("battery_capacity", 100.0)))


static func direction_string_to_vector(dir: String) -> Vector2:
	match dir.to_lower():
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		"left":
			return Vector2.LEFT
		_:
			return Vector2.RIGHT
