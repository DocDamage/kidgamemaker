extends RefCounted


static func create_wind_zone(app, data: Dictionary, sidecar: Dictionary, wind_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(96, 96), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.3, 0.7, 0.9, 0.15))

	var mods: Dictionary = data.get("modifiers", {})
	var direction := str(mods.get("wind_direction", "right"))
	var force := float(mods.get("wind_force", 300.0))
	var direction_vector := direction_string_to_vector(direction)

	var particles := CPUParticles2D.new()
	particles.amount = 12
	particles.lifetime = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = size * 0.5
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(1.0, 1.0, 1.0, 0.4)
	particles.direction = direction_vector
	particles.spread = 10.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = force * 0.5
	particles.initial_velocity_max = force
	area.add_child(particles)

	area.set_script(wind_script)
	area.set("force_vector", direction_vector * force)
	return area


static func create_target_practice(app, data: Dictionary, sidecar: Dictionary, target_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.9, 0.1, 0.1, 0.95))
	area.set_script(target_script)
	return area


static func create_decoration(app, data: Dictionary, sidecar: Dictionary) -> Node2D:
	var node := Node2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_visuals(node, sidecar, size, Color(0.65, 0.35, 1.0, 0.75))
	return node


static func create_meta_static_body(app, data: Dictionary, sidecar: Dictionary, default_size: Vector2, color: Color, asset_id: String) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, default_size, data)
	app._add_box_collision(body, size)
	app._add_visuals(body, sidecar, size, color)
	body.set_meta("asset_id", asset_id)
	return body


static func create_meta_node(app, data: Dictionary, sidecar: Dictionary, default_size: Vector2, color: Color, asset_id: String) -> Node2D:
	var node := Node2D.new()
	var size: Vector2 = app._collision_size(sidecar, default_size, data)
	app._add_visuals(node, sidecar, size, color)
	node.set_meta("asset_id", asset_id)
	return node


static func create_speed_booster_block(app, data: Dictionary, sidecar: Dictionary, terrain_script: Script) -> StaticBody2D:
	var body := create_meta_static_body(app, data, sidecar, Vector2(48, 48), Color.GOLD, "speed_booster_block")
	body.set_script(terrain_script)
	body.set("block_type", "speed")
	body.set("is_speed_block", true)
	return body


static func create_clear_pipe(app, data: Dictionary, sidecar: Dictionary, clear_pipe_script: Script) -> Node2D:
	var node := create_meta_node(app, data, sidecar, Vector2(48, 48), Color(0.6, 0.8, 1.0, 0.35), "clear_pipe")
	node.set_script(clear_pipe_script)
	return node


static func create_logic_gate(app, data: Dictionary, sidecar: Dictionary, gate_type: String, logic_gate_script: Script) -> Node2D:
	var node := Node2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	var base_color := Color(0.8, 0.2, 0.2)
	if gate_type == "or":
		base_color = Color(0.2, 0.8, 0.2)
	elif gate_type == "not":
		base_color = Color(0.8, 0.8, 0.2)
	app._add_visuals(node, sidecar, size, base_color)
	node.set_meta("asset_id", "logic_" + gate_type)
	node.set_meta("gate_type", gate_type)
	node.set_meta("input_1", false)
	node.set_meta("input_2", false)
	node.set_meta("output_state", false)
	node.set_script(logic_gate_script)
	return node


static func create_trigger(app, data: Dictionary, sidecar: Dictionary, trigger_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(32, 32), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(1.0, 0.6, 0.2, 0.8))
	var modifiers: Dictionary = data.get("modifiers", {})
	area.set_script(trigger_script)
	area.set("target_id", str(modifiers.get("target_id", "")))
	return area


static func create_pressure_plate(app, data: Dictionary, sidecar: Dictionary, pressure_plate_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 16), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.9, 0.9, 0.1, 0.8))
	area.set_meta("asset_id", "trigger_pressure_plate")
	var modifiers: Dictionary = data.get("modifiers", {})
	area.set_script(pressure_plate_script)
	area.set("target_id", str(modifiers.get("target_id", "")))
	return area


static func create_gate(app, data: Dictionary, sidecar: Dictionary, gate_script: Script) -> AnimatableBody2D:
	var body := AnimatableBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(body, size)
	app._add_visuals(body, sidecar, size, Color(0.1, 0.8, 0.5, 0.95))
	body.set_script(gate_script)
	return body


static func create_jelly(app, data: Dictionary, sidecar: Dictionary, jelly_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color.YELLOW)
	var mods: Dictionary = data.get("modifiers", {})
	area.set_script(jelly_script)
	area.set("bounce_force", float(mods.get("bounce_force", 500.0)))
	area.set("scale_multiplier", float(mods.get("scale_multiplier", 1.0)))
	return area


static func create_speed_pad(app, data: Dictionary, sidecar: Dictionary, speed_pad_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color.CYAN)
	var mods: Dictionary = data.get("modifiers", {})
	area.set_script(speed_pad_script)
	area.set("boost_direction", float(mods.get("boost_direction", 1.0)))
	area.set("boost_force", float(mods.get("boost_force", 550.0)))
	return area


static func create_hazard(app, data: Dictionary, sidecar: Dictionary, hazard_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color.RED)
	var mods: Dictionary = data.get("modifiers", {})
	area.set_script(hazard_script)
	area.set("damage_value", int(mods.get("damage_value", 15)))
	return area


static func create_mystery_box(app, data: Dictionary, sidecar: Dictionary, mystery_box_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.9, 0.7, 0.1, 0.95))
	area.set_script(mystery_box_script)
	return area


static func create_gravity_zone(app, data: Dictionary, sidecar: Dictionary, gravity_zone_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(96, 96), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.5, 0.2, 0.8, 0.4))
	area.set_script(gravity_zone_script)
	return area


static func create_speech_sign(app, data: Dictionary, sidecar: Dictionary, speech_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color.DARK_ORANGE)
	area.add_child(create_speech_bubble())
	var mods: Dictionary = data.get("modifiers", {})
	area.set_script(speech_script)
	area.set("speech_text", str(mods.get("speech_text", "Hello adventurer! 🧙‍♂️")))
	return area


static func create_speech_bubble() -> PanelContainer:
	var bubble := PanelContainer.new()
	bubble.name = "SpeechBubble"
	bubble.visible = false
	bubble.position = Vector2(-75, -70)
	bubble.custom_minimum_size = Vector2(150, 45)

	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.12, 0.2, 0.88)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.6, 0.9, 0.9)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	bubble.add_theme_stylebox_override("panel", style_box)

	var label := Label.new()
	label.name = "SpeechLabel"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var label_settings := LabelSettings.new()
	label_settings.font_size = 11
	label_settings.font_color = Color.WHITE
	label.label_settings = label_settings
	bubble.add_child(label)
	return bubble


static func create_water_block(app, data: Dictionary, sidecar: Dictionary, water_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(128, 128), data)
	app._add_box_collision(area, size)

	var mods: Dictionary = data.get("modifiers", {})
	var flavor := str(mods.get("water_flavor", "normal"))
	var tint := Color(0.2, 0.5, 0.8, 0.4)
	if flavor == "toxic":
		tint = Color(0.2, 0.8, 0.2, 0.4)
	elif flavor == "lava":
		tint = Color(0.9, 0.2, 0.1, 0.4)

	var rect := ColorRect.new()
	rect.color = tint
	rect.size = size
	rect.position = -size * 0.5
	area.add_child(rect)
	app._add_visuals(area, sidecar, size * 0.5, tint)

	area.set_script(water_script)
	area.set("buoyancy", float(mods.get("water_buoyancy", 0.5)))
	area.set("flavor", flavor)
	return area


static func create_crumbling_cloud(app, data: Dictionary, sidecar: Dictionary, cloud_script: Script) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(128, 32), data)
	app._add_box_collision(body, size)
	app._add_visuals(body, sidecar, size, Color(0.8, 0.9, 1.0, 0.8))

	var sensor := Area2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(size.x - 8, 10)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -size.y * 0.5 - 5)
	sensor.add_child(collision)
	body.add_child(sensor)

	var mods: Dictionary = data.get("modifiers", {})
	body.set_script(cloud_script)
	body.set("crumble_delay", float(mods.get("crumble_delay", 0.5)))
	body.set("respawn_time", float(mods.get("respawn_time", 3.0)))
	return body


static func create_conveyor(app, data: Dictionary, sidecar: Dictionary, conveyor_script: Script) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(128, 32), data)
	app._add_box_collision(body, size)
	var modifiers: Dictionary = data.get("modifiers", {})
	var direction := float(modifiers.get("conveyor_direction", 1.0))
	var speed := float(modifiers.get("conveyor_speed", 140.0))
	body.set_meta("is_conveyor", true)
	body.set_meta("conveyor_direction", direction)
	body.set_meta("conveyor_speed", speed)
	app._add_visuals(body, sidecar, size, Color(0.3, 0.6, 0.9, 0.9))
	body.set_script(conveyor_script)
	body.set("direction", direction)
	return body


static func create_pet(app, data: Dictionary, sidecar: Dictionary, pet_script: Script) -> Node2D:
	var node := Node2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(32, 32), data)
	app._add_visuals(node, sidecar, size, Color.MAGENTA)
	var mods: Dictionary = data.get("modifiers", {})
	var power := str(mods.get("pet_power", "magnet"))
	node.set_script(pet_script)
	node.set("pet_power", power)
	if power == "light":
		node.add_child(create_pet_light())
	return node


static func create_pet_light() -> PointLight2D:
	var light := PointLight2D.new()
	light.color = Color(1.0, 0.9, 0.6)
	light.energy = 1.3
	light.texture_scale = 200.0 / 128.0
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE, Color(1.0, 1.0, 1.0, 0.0)])
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(1.0, 0.5)
	gradient_texture.width = 128
	gradient_texture.height = 128
	light.texture = gradient_texture
	return light


static func create_shopkeeper(app, data: Dictionary, sidecar: Dictionary, shopkeeper_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.1, 0.8, 0.3, 0.9))
	area.add_child(create_station_marker("🛍️ SHOP"))
	area.set_script(shopkeeper_script)
	return area


static func create_destructible_terrain(app, data: Dictionary, sidecar: Dictionary, terrain_script: Script) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(128, 32), data)
	app._add_box_collision(body, size)
	var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
	var block_type := str(gameplay.get("block_type", "brick"))
	var tint := Color(0.7, 0.35, 0.25)
	if block_type == "ice":
		tint = Color(0.6, 0.85, 1.0)
	app._add_visuals(body, sidecar, size, tint)
	body.set_script(terrain_script)
	body.set("block_type", block_type)
	return body


static func create_chemistry_block(app, data: Dictionary, sidecar: Dictionary, type: String) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(body, size)

	var color := Color(0.6, 0.4, 0.2)
	if type == "grass":
		color = Color(0.2, 0.7, 0.2)
	elif type == "metal":
		color = Color(0.7, 0.7, 0.8)
	app._add_visuals(body, sidecar, size, color)

	body.set_meta("chemistry_material", type)
	body.set_meta("collision_size", size)
	if type in ["wood", "grass"]:
		body.set_meta("is_flammable", true)
		body.set_meta("burn_timer", 4.0)
		body.set_meta("is_burning", false)
	elif type == "metal":
		body.set_meta("is_conductive", true)
		body.set_meta("shock_timer", 0.0)
		body.set_meta("is_shocked", false)
	return body


static func create_pikmin(app, data: Dictionary, sidecar: Dictionary, pikmin_script: Script) -> CharacterBody2D:
	var node := CharacterBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(32, 32), data)
	app._add_box_collision(node, size)
	app._add_visuals(node, sidecar, size, Color.RED)
	node.set_meta("asset_id", "companion_pikmin")
	node.set_meta("collision_size", size)
	var mods: Dictionary = data.get("modifiers", {})
	node.set_script(pikmin_script)
	node.set("pikmin_color", str(mods.get("pikmin_color", "red")))
	return node


static func create_ghost(app, data: Dictionary, sidecar: Dictionary, ghost_script: Script) -> Node2D:
	var node := Node2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(32, 32), data)
	app._add_visuals(node, sidecar, size, Color.PLUM)
	node.set_meta("asset_id", "companion_ghost")
	node.set_meta("collision_size", size)
	var mods: Dictionary = data.get("modifiers", {})
	node.set_script(ghost_script)
	node.set("drain_rate", float(mods.get("drain_rate", 10.0)))
	return node


static func create_palico(app, data: Dictionary, sidecar: Dictionary, palico_script: Script) -> CharacterBody2D:
	var node := CharacterBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(32, 32), data)
	app._add_box_collision(node, size)
	app._add_visuals(node, sidecar, size, Color.ORANGE)
	node.set_meta("asset_id", "companion_palico")
	node.set_meta("collision_size", size)
	var mods: Dictionary = data.get("modifiers", {})
	node.set_script(palico_script)
	node.set("palico_color", str(mods.get("palico_color", "calico")))
	return node


static func create_rush_adapter(app, data: Dictionary, sidecar: Dictionary, rush_script: Script) -> CharacterBody2D:
	var node := CharacterBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(36, 32), data)
	app._add_box_collision(node, size)
	app._add_visuals(node, sidecar, size, Color.CRIMSON)
	node.set_meta("asset_id", "companion_rush")
	node.set_meta("collision_size", size)
	var mods: Dictionary = data.get("modifiers", {})
	node.set_script(rush_script)
	node.set("rush_color", str(mods.get("rush_color", "red")))
	return node


static func create_interaction_station(app, data: Dictionary, sidecar: Dictionary, color: Color, label_text: String, action_method: String, station_script: Script) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 48), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, color)
	area.add_child(create_station_marker(label_text))
	area.set_script(station_script)
	area.set("action_method", action_method)
	return area


static func create_station_marker(text: String) -> Label:
	var marker := Label.new()
	marker.text = text
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 14
	settings.outline_size = 3
	settings.outline_color = Color.BLACK
	marker.label_settings = settings
	marker.size = Vector2(100, 20)
	marker.position = Vector2(-50, -45)
	return marker


static func direction_string_to_vector(direction: String) -> Vector2:
	match direction.to_lower():
		"left":
			return Vector2.LEFT
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		_:
			return Vector2.RIGHT
