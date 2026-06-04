extends RefCounted


static func placement_bucket(sidecar: Dictionary) -> String:
	var placement: Dictionary = sidecar.get("placement_logic", {})
	return str(placement.get("parallax_bucket", "play_layer"))


static func z_index_for_bucket(bucket: String) -> int:
	match bucket:
		"deep_background":
			return -300
		"midground":
			return -100
		"play_layer":
			return 0
		"foreground":
			return 100
		_:
			return 0


static func apply_world_settings(parent: Node, settings: Dictionary) -> Dictionary:
	var time_of_day := str(settings.get("time_of_day", "day"))
	var weather := str(settings.get("weather", "clear"))
	var difficulty := str(settings.get("difficulty", "normal"))
	var calm_mode := bool(settings.get("calm_mode", false))
	var autoscroll_enabled := bool(settings.get("camera_autoscroll", false))
	var age_mode := str(settings.get("age_mode", "growing"))
	# game_speed_multiplier is set by the Three-Age mode selector in the editor.
	# 1.0 = full speed (Creator), 0.9 = Growing, 0.75 = Mellow.
	var game_speed_mult := clampf(float(settings.get("game_speed_multiplier", 1.0)), 0.5, 1.0)
	print("World settings: time=", time_of_day, " weather=", weather, " difficulty=", difficulty,
		" calm=", calm_mode, " autoscroll=", autoscroll_enabled, " age_mode=", age_mode,
		" game_speed=", game_speed_mult)

	# Apply age-mode speed immediately (Engine.time_scale was reset to 1.0 at level load)
	Engine.time_scale = game_speed_mult

	var modulate_node := CanvasModulate.new()
	modulate_node.name = "CanvasModulateDayNight"
	parent.add_child(modulate_node)
	modulate_node.color = _time_of_day_color(time_of_day)

	return {
		"difficulty": difficulty,
		"calm_mode": calm_mode,
		"camera_autoscroll_enabled": autoscroll_enabled,
		"camera_autoscroll_direction": str(settings.get("camera_autoscroll_direction", "right")),
		"camera_autoscroll_speed": float(settings.get("camera_autoscroll_speed", 40.0)),
		"audio_debug": bool(settings.get("audio_debug", false)),
		"level_balancer_enabled": bool(settings.get("level_balancer_enabled", true)),
		"tutorial_whisperer_enabled": bool(settings.get("tutorial_whisperer_enabled", true)),
		"current_weather": weather,
		"room_rules": settings.get("room_rules", []),
		"victory_rules": settings.get("victory_rules", {"win_condition": "all_enemies", "celebration": "confetti"}),
		"loss_rules": settings.get("loss_rules", {"lose_condition": "health_0", "action": "game_over"}),
		"theme": str(settings.get("theme", "default")),
		"bgm_sequence": settings.get("custom_bgm_sequence", []),
		"age_mode": age_mode,
		"game_speed_multiplier": game_speed_mult,
		"spawned_nodes": [modulate_node]
	}


static func apply_lighting_if_needed(node: Node2D, sidecar: Dictionary) -> void:
	var lighting: Dictionary = sidecar.get("lighting_logic", {})
	if not bool(lighting.get("emits_light", false)):
		return

	var light := PointLight2D.new()
	light.color = Color(str(lighting.get("light_color", "#ffae34")))
	light.energy = float(lighting.get("light_energy", 1.2))
	light.texture_scale = float(lighting.get("light_radius", 150.0)) / 128.0
	light.texture = _radial_light_texture()
	node.add_child(light)
	node.set_meta("emits_light", true)
	node.set_meta("light_energy", light.energy)


static func apply_weather_particles(parent: Node, active_player: Node2D, current_weather: String) -> Array:
	if current_weather == "clear" or current_weather == "":
		return []

	var particles := CPUParticles2D.new()
	particles.name = "WeatherParticles"
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(1000, 10)
	particles.amount = 150
	particles.lifetime = 3.0
	particles.preprocess = 3.0
	_configure_weather(particles, current_weather)

	if active_player != null:
		particles.position = Vector2(0, -400)
		active_player.add_child(particles)
		return []

	particles.position = Vector2(500, 0)
	parent.add_child(particles)
	return [particles]


static func apply_audio_if_needed(node: Node2D, sidecar: Dictionary, asset_root: String) -> void:
	var audio: Dictionary = sidecar.get("audio_logic", {})
	var stream_file := str(audio.get("stream_file", ""))
	if stream_file == "":
		return

	var resolved_audio_path := _resolve_asset_path(stream_file, str(sidecar.get("sidecar_path", "")), asset_root)
	var fs_path := ProjectSettings.globalize_path(resolved_audio_path)
	if not FileAccess.file_exists(fs_path):
		return

	var stream := AudioStreamOggVorbis.load_from_file(fs_path)
	if stream == null:
		stream = load(resolved_audio_path)
	if stream == null:
		return

	var loop := bool(audio.get("loop", true))
	if stream is AudioStreamOggVorbis:
		stream.loop = loop

	if bool(audio.get("global_bgm", true)):
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = float(audio.get("volume_db", 0.0))
		player.autoplay = true
		node.add_child(player)
		print("Global BGM spawned for ", node.name, " playing ", resolved_audio_path)
	else:
		var player_2d := AudioStreamPlayer2D.new()
		player_2d.stream = stream
		player_2d.volume_db = float(audio.get("volume_db", 0.0))
		player_2d.autoplay = true
		player_2d.max_distance = float(audio.get("max_distance", 500.0))
		node.add_child(player_2d)
		print("Spatial SFX spawned for ", node.name, " playing ", resolved_audio_path)


static func _time_of_day_color(time_of_day: String) -> Color:
	match time_of_day:
		"night":
			return Color(0.12, 0.12, 0.28)
		"sunset":
			return Color(0.85, 0.58, 0.45)
		"morning":
			return Color(0.88, 0.94, 1.0)
		_:
			return Color.WHITE


static func _radial_light_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE, Color(1.0, 1.0, 1.0, 0.0)])

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 128
	texture.height = 128
	return texture


static func _configure_weather(particles: CPUParticles2D, current_weather: String) -> void:
	match current_weather:
		"rain":
			particles.color = Color(0.6, 0.7, 0.9, 0.55)
			particles.direction = Vector2(0.1, 1.0)
			particles.spread = 4.0
			particles.gravity = Vector2(50, 700)
			particles.initial_velocity_min = 350.0
			particles.initial_velocity_max = 500.0
		"snow":
			particles.color = Color(0.9, 0.95, 1.0, 0.8)
			particles.direction = Vector2(0.0, 1.0)
			particles.spread = 15.0
			particles.gravity = Vector2(0, 80)
			particles.initial_velocity_min = 40.0
			particles.initial_velocity_max = 80.0
			particles.tangential_accel_min = -10.0
			particles.tangential_accel_max = 10.0
			particles.scale_amount_min = 2.0
			particles.scale_amount_max = 5.0


static func _resolve_asset_path(path: String, sidecar_file_path: String, asset_root: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://") or path.is_absolute_path():
		return path
	if sidecar_file_path != "":
		return sidecar_file_path.get_base_dir().path_join(path)
	return asset_root.path_join(path)
