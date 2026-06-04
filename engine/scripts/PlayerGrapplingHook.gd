extends RefCounted


static func process_grapple(player: CharacterBody2D, _delta: float) -> bool:
	if not bool(player.get("is_grappling")):
		return false

	var target_pos: Vector2 = player.get("grapple_target_pos")
	var dir := (target_pos - player.global_position).normalized()
	player.velocity = dir * 580.0
	player.queue_redraw()

	for i in player.get_slide_collision_count():
		var col = player.get_slide_collision(i)
		var collider = col.get_collider()
		if collider != null and (collider.has_meta("is_destructible") or collider.has_meta("is_speed_block")):
			collider.call_deferred("shatter")

	var arrived = player.global_position.distance_to(target_pos) < 25.0
	var release_held = not Input.is_physical_key_pressed(KEY_E)

	if arrived or release_held:
		player.set("is_grappling", false)
		player.velocity = player.velocity * 0.45
		player.queue_redraw()

	player.move_and_slide()
	return true


static func check_grapple_trigger(player: CharacterBody2D) -> void:
	if not Input.is_physical_key_pressed(KEY_E):
		return
	if bool(player.get("is_grappling")) or bool(player.get("is_shinesparking")) or bool(player.get("is_rope_climbing")):
		return

	var main = player.get_tree().get_root().get_node_or_null("Main")
	var closest_anchor: Node2D = null
	var min_dist: float = player.get("current_grapple_range")

	if main != null:
		for child in main.get_children():
			if child.name.contains("grapple_ring") or (child.has_meta("asset_id") and child.get_meta("asset_id") == "grapple_ring"):
				var dist = player.global_position.distance_to(child.global_position)
				if dist < min_dist:
					min_dist = dist
					closest_anchor = child

	if closest_anchor != null:
		player.set("is_grappling", true)
		player.set("grapple_target_pos", closest_anchor.global_position)
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("jump")
		player.queue_redraw()
