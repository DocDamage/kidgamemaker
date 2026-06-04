extends RefCounted


static func update_status_effects(player: CharacterBody2D, delta: float) -> bool:
	if bool(player.get("is_shocked")):
		_tick_shock(player, delta)
		return true

	if bool(player.get("is_burning")):
		_tick_burn(player, delta)

	return false


static func set_burning(player: Node, duration: float) -> void:
	player.set("is_burning", true)
	player.set("burn_timer", max(float(player.get("burn_timer")), duration))


static func set_shocked(player: Node, duration: float) -> void:
	player.set("is_shocked", true)
	player.set("shock_timer", max(float(player.get("shock_timer")), duration))


static func _tick_shock(player: CharacterBody2D, delta: float) -> void:
	var shock_timer := float(player.get("shock_timer")) - delta
	player.set("shock_timer", shock_timer)
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	player.modulate = Color.YELLOW if Engine.get_physics_frames() % 4 < 2 else Color.WHITE
	if shock_timer <= 0.0:
		player.set("is_shocked", false)
		player.modulate = Color.WHITE


static func _tick_burn(player: CharacterBody2D, delta: float) -> void:
	var burn_timer := float(player.get("burn_timer")) - delta
	player.set("burn_timer", burn_timer)
	player.modulate = Color.ORANGE_RED if Engine.get_physics_frames() % 6 < 3 else Color.WHITE
	if int(burn_timer * 10) % 10 == 0 and player.has_method("take_damage"):
		player.call("take_damage", 2)
	if burn_timer <= 0.0:
		player.set("is_burning", false)
		player.modulate = Color.WHITE
