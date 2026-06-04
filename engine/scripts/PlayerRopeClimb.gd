extends RefCounted


static func process_climb(player: CharacterBody2D, delta: float) -> bool:
	if not bool(player.get("is_rope_climbing")):
		return false

	var current_rope = player.get("current_rope") as Node2D
	if not is_instance_valid(current_rope):
		player.set("is_rope_climbing", false)
		return false

	player.velocity = Vector2.ZERO
	player.queue_redraw()

	var rope_anchor = current_rope.global_position
	var rope_length: float = player.get("rope_length")
	if Input.is_action_pressed("ui_up"):
		rope_length = max(30.0, rope_length - 120.0 * delta)
	elif Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		rope_length = min(300.0, rope_length + 120.0 * delta)
	player.set("rope_length", rope_length)

	var h_input := Input.get_axis("ui_left", "ui_right")
	var swing_speed: float = player.get("swing_speed")
	swing_speed += h_input * delta * 5.0
	swing_speed = lerp(swing_speed, 0.0, delta * 0.3)
	player.set("swing_speed", swing_speed)

	var swing_angle: float = player.get("swing_angle")
	swing_angle += swing_speed * delta
	swing_angle = clamp(swing_angle, -deg_to_rad(65), deg_to_rad(65))
	player.set("swing_angle", swing_angle)

	player.global_position = rope_anchor + Vector2(sin(swing_angle), cos(swing_angle)) * rope_length

	var main = player.get_tree().get_root().get_node_or_null("Main")
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		player.set("is_rope_climbing", false)
		player.velocity = Vector2(sin(swing_angle) * 350.0 + h_input * 120.0, -320.0)
		player.set("current_rope", null)
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("jump")

	player.move_and_slide()
	return true


static func check_climb_trigger(player: CharacterBody2D) -> void:
	var climb_input = Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)
	if not climb_input:
		return
	if bool(player.get("is_rope_climbing")) or bool(player.get("is_ledge_hanging")) or bool(player.get("is_grappling")):
		return

	var main = player.get_tree().get_root().get_node_or_null("Main")
	var near_rope: Node2D = null
	if main != null:
		for child in main.get_children():
			if child.name.contains("climbable_vine") or child.name.contains("climbable_rope") or (child.has_meta("asset_id") and (child.get_meta("asset_id") == "climbable_vine" or child.get_meta("asset_id") == "climbable_rope")):
				if player.global_position.distance_to(child.global_position) < 32.0:
					near_rope = child
					break

	if near_rope != null:
		player.set("is_rope_climbing", true)
		player.set("current_rope", near_rope)
		player.set("swing_angle", 0.0)
		player.set("swing_speed", 0.0)
		var length = clamp(player.global_position.distance_to(near_rope.global_position), 30.0, 300.0)
		player.set("rope_length", length)
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("🧗 CLIMB!", player.global_position, Color.GREEN)
