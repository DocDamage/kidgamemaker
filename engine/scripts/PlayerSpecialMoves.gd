extends RefCounted


static func process_shinespark(player: CharacterBody2D, delta: float) -> bool:
	if not bool(player.get("is_shinesparking")):
		return false

	var shinespark_dir: Vector2 = player.get("shinespark_direction")
	player.velocity = shinespark_dir * 800.0

	var shinespark_flight_timer: float = player.get("shinespark_flight_timer")
	shinespark_flight_timer -= delta
	player.set("shinespark_flight_timer", shinespark_flight_timer)

	var main = player.get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text") and randf() < delta * 15.0:
		main.spawn_floating_text("✨", player.global_position + Vector2(randf_range(-12, 12), randf_range(-12, 12)), Color.YELLOW)

	player.modulate = Color.YELLOW if Engine.get_physics_frames() % 4 < 2 else Color.ORANGE

	var hit_something := false
	if player.is_on_wall() or player.is_on_ceiling() or player.is_on_floor() or shinespark_flight_timer <= 0.0:
		hit_something = true

	for i in player.get_slide_collision_count():
		var col = player.get_slide_collision(i)
		var collider = col.get_collider()
		if collider != null and collider.has_method("take_damage") and not collider.name.begins_with("Player"):
			collider.take_damage(60)
			hit_something = true
		if collider != null and (collider.has_meta("is_speed_block") or collider.has_meta("is_destructible")):
			collider.call_deferred("shatter")

	if hit_something:
		player.set("is_shinesparking", false)
		player.velocity = Vector2.ZERO
		if main != null:
			if main.has_method("trigger_screen_shake"):
				main.trigger_screen_shake(15.0, 0.4)
			if main.has_method("play_sfx"):
				main.play_sfx("hit")
			if main.has_method("spawn_floating_text"):
				main.spawn_floating_text("💥 SHOCKWAVE!", player.global_position, Color.RED)
			if player.has_method("_execute_ground_pound_damage"):
				player._execute_ground_pound_damage()

	player.move_and_slide()
	return true


static func process_spindash(player: CharacterBody2D, delta: float) -> bool:
	if not bool(player.get("is_spindashing")):
		return false

	player.velocity = Vector2.ZERO
	var spindash_charge: float = player.get("spindash_charge")
	spindash_charge = min(spindash_charge + delta * 2.5, 3.0)
	player.set("spindash_charge", spindash_charge)

	player.position.x += randf_range(-1.2, 1.2)
	player.scale = Vector2(1.1, 0.7)

	var main = player.get_tree().get_root().get_node_or_null("Main")
	var down_held = Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)
	if not down_held:
		player.set("is_spindashing", false)
		player.set("is_spindash_rolling", true)
		player.set("spindash_roll_timer", 1.2)
		player.scale = Vector2(1.0, 1.0)
		var face_dir: float = player.get("facing_direction")
		var speed: float = player.get("movement_speed")
		player.velocity.x = face_dir * speed * (1.8 + spindash_charge * 0.7)
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("jump")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("🌀 SPIN DASH!", player.global_position, Color.CYAN)
	else:
		player.move_and_slide()

	return true


static func process_spindash_roll(player: CharacterBody2D, delta: float) -> bool:
	if not bool(player.get("is_spindash_rolling")):
		return false

	var main = player.get_tree().get_root().get_node_or_null("Main")
	var spindash_roll_timer: float = player.get("spindash_roll_timer")
	spindash_roll_timer -= delta
	player.set("spindash_roll_timer", spindash_roll_timer)

	var face_dir: float = player.get("facing_direction")
	var speed: float = player.get("movement_speed")
	var spindash_charge: float = player.get("spindash_charge")
	player.velocity.x = face_dir * speed * (1.8 + spindash_charge * 0.7)
	player.rotation += face_dir * 25.0 * delta
	player.velocity.y += player.get("gravity") * delta

	for i in player.get_slide_collision_count():
		var col = player.get_slide_collision(i)
		var collider = col.get_collider()
		if collider != null and collider.has_method("take_damage") and not collider.name.begins_with("Player"):
			collider.take_damage(25)
		if collider != null and (collider.has_meta("is_destructible") or collider.has_meta("is_speed_block")):
			collider.call_deferred("shatter")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("hit")

	if spindash_roll_timer <= 0.0 or player.is_on_wall():
		player.set("is_spindash_rolling", false)
		player.rotation = 0.0

	player.move_and_slide()
	return true


static func update_speed_booster(player: CharacterBody2D, input_dir: float, down_input_pressed: bool, delta: float) -> void:
	var main = player.get_tree().get_root().get_node_or_null("Main")

	# Speed Booster running charge
	var speed_booster_active: bool = player.get("speed_booster_active")
	var run_timer: float = player.get("run_timer")
	var speed: float = player.get("movement_speed")
	var is_crouching: bool = player.get("is_crouching")

	if player.is_on_floor() and abs(player.velocity.x) > speed * 0.85 and input_dir != 0.0 and not is_crouching:
		run_timer += delta
		if run_timer >= 2.0 and not speed_booster_active:
			speed_booster_active = true
			player.set("speed_booster_active", true)
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("⚡ SPEED BOOSTER ACTIVE! ⚡", player.global_position, Color.GOLD)
	else:
		if not player.is_on_floor() or input_dir == 0.0 or is_crouching:
			run_timer = 0.0
			if not bool(player.get("shinespark_stored")):
				speed_booster_active = false
				player.set("speed_booster_active", false)
	player.set("run_timer", run_timer)

	# Shinespark store
	var shinespark_stored: bool = player.get("shinespark_stored")
	if speed_booster_active and down_input_pressed and player.is_on_floor():
		shinespark_stored = true
		player.set("shinespark_stored", true)
		player.set("shinespark_store_timer", 4.0)
		player.set("speed_booster_active", false)
		player.set("run_timer", 0.0)
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("✨ SHINESPARK STORED! ✨", player.global_position, Color.GOLD)

	if shinespark_stored:
		var shinespark_store_timer: float = player.get("shinespark_store_timer")
		shinespark_store_timer -= delta
		player.set("shinespark_store_timer", shinespark_store_timer)
		if shinespark_store_timer <= 0.0:
			player.set("shinespark_stored", false)

		var jump_pressed := Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")
		if jump_pressed:
			player.set("shinespark_stored", false)
			player.set("is_shinesparking", true)
			player.set("shinespark_flight_timer", 1.5)
			var vertical_in := Input.get_axis("ui_up", "ui_down")
			var horizontal_in := Input.get_axis("ui_left", "ui_right")
			var shinespark_direction := Vector2(horizontal_in, -1.0 if vertical_in == 0.0 else vertical_in).normalized()
			if shinespark_direction.length_squared() < 0.1:
				shinespark_direction = Vector2.UP
			player.set("shinespark_direction", shinespark_direction)
			player.velocity = shinespark_direction * 800.0
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("🚀 SHINESPARK!!!", player.global_position, Color.GOLD)
