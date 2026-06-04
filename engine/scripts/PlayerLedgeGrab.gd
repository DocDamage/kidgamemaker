extends RefCounted


static func process_ledge_grab(player: CharacterBody2D, _delta: float) -> bool:
	if not bool(player.get("is_ledge_hanging")):
		return false

	player.velocity = Vector2.ZERO
	player.global_position = player.get("ledge_pos") as Vector2

	var main = player.get_tree().get_root().get_node_or_null("Main")
	var jump_pressed := Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")
	var down_pressed := Input.is_action_just_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)

	if jump_pressed:
		player.set("is_ledge_hanging", false)
		var jump_f: float = player.get("jump_force")
		var face_dir: float = player.get("facing_direction")
		player.velocity = Vector2(face_dir * 150.0, jump_f * 0.8)
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("jump")
	elif down_pressed:
		player.set("is_ledge_hanging", false)

	player.move_and_slide()
	return true


static func check_ledge_grab(player: CharacterBody2D) -> void:
	if player.is_on_floor():
		return
	if bool(player.get("is_ledge_hanging")) or bool(player.get("is_rope_climbing")) or bool(player.get("is_grappling")) or bool(player.get("is_shinesparking")):
		return

	var gravity_inverted: bool = player.get("gravity_inverted")
	var is_falling_y = player.velocity.y > 0.0 if not gravity_inverted else player.velocity.y < 0.0
	if not is_falling_y:
		return

	var space_state := player.get_world_2d().direct_space_state
	var face_dir: float = player.get("facing_direction")
	var chest_query = PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + Vector2(face_dir * 22, 0))
	chest_query.collision_mask = 1
	chest_query.exclude = [player]
	var chest_hit = space_state.intersect_ray(chest_query)

	var head_y_offset = -32 if not gravity_inverted else 32
	var head_query = PhysicsRayQueryParameters2D.create(player.global_position + Vector2(0, head_y_offset), player.global_position + Vector2(face_dir * 22, head_y_offset))
	head_query.collision_mask = 1
	head_query.exclude = [player]
	var head_hit = space_state.intersect_ray(head_query)

	if not chest_hit.is_empty() and head_hit.is_empty():
		player.set("is_ledge_hanging", true)
		var ledge_pos = Vector2(chest_hit.position.x - face_dir * 14.0, chest_hit.position.y + 12.0)
		player.set("ledge_pos", ledge_pos)
		player.global_position = ledge_pos
		player.velocity = Vector2.ZERO

		var main = player.get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("🧗 LEDGE GRAB!", player.global_position, Color.CHARTREUSE)
