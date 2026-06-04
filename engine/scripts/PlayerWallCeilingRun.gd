extends RefCounted

static func process_wall_run(player: CharacterBody2D, delta: float, input_dir: float) -> bool:
	var main = player.get_tree().get_root().get_node_or_null("Main")
	var is_wall_running: bool = player.get("is_wall_running")
	var is_ceiling_running: bool = player.get("is_ceiling_running")
	var magnet_meter: float = player.get("magnet_meter")
	var movement_speed: float = player.get("movement_speed")
	var jump_force: float = player.get("jump_force")

	if player.is_on_wall() and player.velocity.y > -100.0 and input_dir != 0.0 and not player.is_on_floor() and not is_wall_running and not is_ceiling_running:
		var on_wall_run_tile := false
		if main != null:
			for child in main.get_children():
				if child.name.contains("wall_run_surface") or (child.has_meta("asset_id") and child.get_meta("asset_id") == "wall_run_surface"):
					if player.global_position.distance_to(child.global_position) < 48.0:
						on_wall_run_tile = true
						break
		if on_wall_run_tile:
			is_wall_running = true
			player.set("is_wall_running", true)
			magnet_meter = 3.0
			player.set("magnet_meter", 3.0)
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("⚡ WALL RUN!", player.global_position, Color.CHARTREUSE)

	if is_wall_running:
		magnet_meter -= delta
		player.set("magnet_meter", magnet_meter)
		player.velocity.y = -movement_speed * 1.3
		player.velocity.x = 0.0
		player.modulate = Color.CHARTREUSE if Engine.get_physics_frames() % 4 < 2 else Color.WHITE
		if magnet_meter <= 0.0 or not player.is_on_wall() or Input.get_axis("ui_left", "ui_right") * player.get_wall_normal().x > 0.0:
			is_wall_running = false
			player.set("is_wall_running", false)
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
			is_wall_running = false
			player.set("is_wall_running", false)
			player.velocity = Vector2(player.get_wall_normal().x * 250.0, jump_force * 0.9)
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("jump")
		player.move_and_slide()
		return true

	return false

static func process_ceiling_run(player: CharacterBody2D, delta: float, input_dir: float) -> bool:
	var main = player.get_tree().get_root().get_node_or_null("Main")
	var is_wall_running: bool = player.get("is_wall_running")
	var is_ceiling_running: bool = player.get("is_ceiling_running")
	var magnet_meter: float = player.get("magnet_meter")
	var movement_speed: float = player.get("movement_speed")

	if player.is_on_ceiling() and player.velocity.x != 0.0 and not is_ceiling_running and not is_wall_running:
		var on_ceiling_run_tile := false
		if main != null:
			for child in main.get_children():
				if child.name.contains("ceiling_run_surface") or (child.has_meta("asset_id") and child.get_meta("asset_id") == "ceiling_run_surface"):
					if player.global_position.distance_to(child.global_position) < 48.0:
						on_ceiling_run_tile = true
						break
		if on_ceiling_run_tile:
			is_ceiling_running = true
			player.set("is_ceiling_running", true)
			magnet_meter = 3.0
			player.set("magnet_meter", 3.0)
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("🌀 CEILING RUN!", player.global_position, Color.CYAN)

	if is_ceiling_running:
		magnet_meter -= delta
		player.set("magnet_meter", magnet_meter)
		player.velocity.y = -30.0
		player.velocity.x = input_dir * movement_speed * 1.2
		player.modulate = Color.CYAN if Engine.get_physics_frames() % 4 < 2 else Color.WHITE
		if magnet_meter <= 0.0 or not player.is_on_ceiling() or input_dir == 0.0:
			is_ceiling_running = false
			player.set("is_ceiling_running", false)
		player.move_and_slide()
		return true

	return false
