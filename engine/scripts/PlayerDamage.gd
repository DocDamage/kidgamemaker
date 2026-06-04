extends RefCounted


static func apply_damage(player: Node2D, amount: int) -> void:
	var main_ref := _main(player)
	if main_ref != null:
		var diff = main_ref.get("difficulty")
		if diff == "creative":
			return
		elif diff == "easy":
			amount = int(max(1.0, float(amount) * 0.5))

	if bool(player.get("is_blocking")):
		if float(player.get("parry_window_timer")) > 0.0:
			_handle_parry(player, main_ref)
			return
		amount = _apply_block_reduction(player, amount, main_ref)

	if bool(player.get("_invincible")):
		return

	if bool(player.get("shield_active")):
		_absorb_with_shield(player, main_ref)
		return

	if bool(player.get("is_star_mode")):
		return

	var current_health := int(player.get("current_health")) - amount
	player.set("current_health", current_health)
	print("Player took %d damage! HP now: %d/%d" % [amount, current_health, int(player.get("max_health"))])

	if main_ref != null and main_ref.has_method("spawn_floating_text"):
		main_ref.spawn_floating_text("-%d HP" % amount, player.global_position, Color.RED)

	if main_ref != null and main_ref.has_method("play_custom_sfx"):
		main_ref.play_custom_sfx(str(player.get("asset_id")), "hit")

	if current_health <= 0:
		player.set("current_health", 0)
		print("Player has died!")
		if main_ref != null:
			if main_ref.has_method("handle_player_death"):
				main_ref.call_deferred("handle_player_death")
			elif main_ref.has_method("_respawn_player"):
				main_ref.call_deferred("_respawn_player")
		return

	player.set("_invincible", true)
	var tween := player.create_tween()
	tween.set_loops(int(float(player.get("invincibility_duration")) / 0.1))
	tween.tween_property(player, "modulate:a", 0.3, 0.05)
	tween.tween_property(player, "modulate:a", 1.0, 0.05)
	tween.chain().tween_callback(func():
		player.set("_invincible", false)
		player.modulate.a = 1.0
	)


static func _handle_parry(player: Node2D, main_ref: Node) -> void:
	if main_ref != null:
		if main_ref.has_method("play_sfx"):
			main_ref.play_sfx("coin")
		if main_ref.has_method("spawn_floating_text"):
			main_ref.spawn_floating_text("🛡️ PARRY!", player.global_position, Color.GOLD)

	if player.has_method("_stun_closest_enemy"):
		player.call("_stun_closest_enemy")

	player.set("_invincible", true)
	var tween := player.create_tween()
	tween.tween_property(player, "modulate:a", 0.5, 0.05)
	tween.tween_property(player, "modulate:a", 1.0, 0.05)
	tween.chain().tween_callback(func():
		player.set("_invincible", false)
	)


static func _apply_block_reduction(player: Node2D, amount: int, main_ref: Node) -> int:
	var reduction := 0.1 if str(player.get("hero_class")) == "warrior" else 0.3
	var reduced_amount := int(max(1.0, float(amount) * reduction))
	if main_ref != null and main_ref.has_method("spawn_floating_text"):
		main_ref.spawn_floating_text("🛡️ BLOCKED!", player.global_position, Color.CYAN)
	return reduced_amount


static func _absorb_with_shield(player: Node2D, main_ref: Node) -> void:
	player.set("shield_active", false)
	print("Shield absorbed damage!")
	if main_ref != null and main_ref.has_method("play_sfx"):
		main_ref.play_sfx("coin")
	if main_ref != null and main_ref.has_method("spawn_floating_text"):
		main_ref.spawn_floating_text("SHIELD BLOCK!", player.global_position, Color.MAGENTA)
	player.set("_invincible", true)
	var tween := player.create_tween()
	tween.tween_property(player, "modulate:a", 0.5, 0.1)
	tween.tween_property(player, "modulate:a", 1.0, 0.1)
	tween.chain().tween_callback(func():
		player.set("_invincible", false)
		player.modulate.a = 1.0
	)


static func _main(player: Node) -> Node:
	return player.get_tree().get_root().get_node_or_null("Main")
