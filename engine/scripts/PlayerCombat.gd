extends RefCounted

static func execute_melee_strike(player: CharacterBody2D, step: int) -> void:
	var main = player.get_tree().get_root().get_node_or_null("Main")
	var text = "⚔️ SWING!"
	var dmg = 15
	var kback = 200.0
	if step == 2:
		text = "⚔️ SLASH!"
		dmg = 15
		kback = 220.0
	elif step == 3:
		text = "🔥 FINISHER!"
		dmg = 30
		kback = 450.0

	var hero_class: String = player.get("hero_class")
	if hero_class == "warrior":
		dmg = int(dmg * 1.2)

	if main != null and main.has_method("play_sfx"):
		main.play_sfx("hit")
	
	var facing_direction: float = player.get("facing_direction")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text(text, player.global_position + Vector2(facing_direction * 24, -20), Color.RED if step == 3 else Color.WHITE)

	# Visual Slash effect: create a small ColorRect arc in front of player
	var slash := ColorRect.new()
	slash.color = Color(1.0, 1.0, 1.0, 0.7) if step < 3 else Color(1.0, 0.3, 0.1, 0.8)
	slash.size = Vector2(36, 12) if step < 3 else Vector2(48, 20)
	slash.position = Vector2(facing_direction * 16 - slash.size.x * 0.5, -12)
	player.add_child(slash)

	var tween = player.create_tween()
	tween.tween_property(slash, "scale:y", 0.0, 0.15)
	tween.chain().tween_callback(slash.queue_free)

	# Check collision with enemies on common layer (layer 1)
	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(48, 36) if step < 3 else Vector2(64, 48)
	query.shape = rect
	query.transform = Transform2D(0, player.global_position + Vector2(facing_direction * 28, 0))
	query.collision_mask = 1 # hits enemies

	var hits = space_state.intersect_shape(query)
	for hit in hits:
		var node = hit.get("collider")
		if node != null and node != player and node.has_method("take_damage"):
			var element = "fire" if step == 3 else ""
			node.take_damage(dmg, element, player)
			if "velocity" in node:
				node.velocity += Vector2(facing_direction * kback, -100.0)

static func execute_ground_pound_damage(player: CharacterBody2D) -> void:
	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(96, 32)
	query.shape = rect
	query.transform = Transform2D(0, player.global_position + Vector2(0, 10))
	query.collision_mask = 1 # hits enemies

	var hits = space_state.intersect_shape(query)
	for hit in hits:
		var node = hit.get("collider")
		if node != null and node != player and node.has_method("take_damage"):
			node.take_damage(30, "", player)
			if "velocity" in node:
				node.velocity += Vector2(sign(node.global_position.x - player.global_position.x) * 300.0, -150.0)
