extends RefCounted

const PlayerVisualEffects = preload("res://scripts/PlayerVisualEffects.gd")

static func update_crouch_slide(player: CharacterBody2D, delta: float) -> void:
	var main = player.get_tree().get_root().get_node_or_null("Main")
	var down_input_pressed := Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)
	var has_paint_gun: bool = player.get("has_paint_gun")
	var is_squid_form: bool = player.get("is_squid_form")
	var is_crouching: bool = player.get("is_crouching")
	var is_sliding: bool = player.get("is_sliding")
	var slide_boost_timer: float = player.get("slide_boost_timer")
	var movement_speed: float = player.get("movement_speed")

	var on_paint := false
	if has_paint_gun:
		for i in player.get_slide_collision_count():
			var col = player.get_slide_collision(i)
			var collider = col.get_collider()
			if collider != null and collider.has_meta("paint_color") and collider.get_meta("paint_color") == "green":
				on_paint = true
				break

	if has_paint_gun and on_paint and down_input_pressed:
		if not is_squid_form:
			is_squid_form = true
			player.set("is_squid_form", true)
			is_crouching = true
			player.set("is_crouching", true)
			PlayerVisualEffects.toggle_squid_visuals(player, true)
	elif is_squid_form and (not down_input_pressed or not on_paint):
		if set_crouch_state(player, false):
			is_squid_form = false
			player.set("is_squid_form", false)
			is_crouching = false
			player.set("is_crouching", false)
			PlayerVisualEffects.toggle_squid_visuals(player, false)

	if not is_squid_form:
		if player.is_on_floor() and down_input_pressed:
			if not is_crouching:
				is_crouching = true
				player.set("is_crouching", true)
				set_crouch_state(player, true)
				if abs(player.velocity.x) > movement_speed * 0.8:
					is_sliding = true
					player.set("is_sliding", true)
					slide_boost_timer = 0.6
					player.set("slide_boost_timer", 0.6)
					if main != null and main.has_method("spawn_floating_text"):
						main.spawn_floating_text("💨 SLIDE!", player.global_position, Color.AQUAMARINE)
		elif not down_input_pressed:
			if is_crouching:
				if set_crouch_state(player, false):
					is_crouching = false
					player.set("is_crouching", false)
					is_sliding = false
					player.set("is_sliding", false)

	if is_sliding:
		slide_boost_timer -= delta
		player.set("slide_boost_timer", slide_boost_timer)
		if slide_boost_timer <= 0.0:
			player.set("is_sliding", false)

static func set_crouch_state(player: CharacterBody2D, crouch: bool) -> bool:
	var collision_shape: CollisionShape2D = player.get("collision_shape")
	var original_collision_height: float = player.get("original_collision_height")
	var original_collision_y: float = player.get("original_collision_y")

	if collision_shape == null or not collision_shape.shape is RectangleShape2D:
		return true

	if crouch:
		collision_shape.shape.size.y = original_collision_height * 0.5
		collision_shape.position.y = original_collision_y + original_collision_height * 0.25
		for child in player.get_children():
			if child is CollisionShape2D or child.name.contains("Particles") or child.name.contains("Emote") or child.name.contains("Light"):
				continue
			child.scale.y = 0.5
			if "position" in child:
				child.position.y = original_collision_height * 0.25
		return true
	else:
		var space_state := player.get_world_2d().direct_space_state
		var query := PhysicsShapeQueryParameters2D.new()
		var test_shape := RectangleShape2D.new()
		test_shape.size = Vector2(24, original_collision_height)
		query.shape = test_shape
		query.transform = Transform2D(0, player.global_position + Vector2(0, original_collision_y - original_collision_height * 0.25))
		query.collision_mask = 1 # solid layers
		query.exclude = [player]

		var results = space_state.intersect_shape(query, 1)
		if results.is_empty():
			collision_shape.shape.size.y = original_collision_height
			collision_shape.position.y = original_collision_y
			for child in player.get_children():
				if child is CollisionShape2D or child.name.contains("Particles") or child.name.contains("Emote") or child.name.contains("Light"):
					continue
				child.scale.y = 1.0
				if "position" in child:
					child.position.y = 0.0
			return true
		else:
			return false
