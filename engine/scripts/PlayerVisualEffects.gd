extends RefCounted


static func create_hero_trail(parent: Node) -> CPUParticles2D:
	var trail_particles := CPUParticles2D.new()
	trail_particles.name = "HeroTrailParticles"
	trail_particles.amount = 15
	trail_particles.lifetime = 0.4
	trail_particles.speed_scale = 1.0
	trail_particles.explosiveness = 0.0
	trail_particles.randomness = 0.2
	trail_particles.direction = Vector2(-1, 0)
	trail_particles.spread = 15.0
	trail_particles.gravity = Vector2.ZERO
	trail_particles.initial_velocity_min = 20.0
	trail_particles.initial_velocity_max = 50.0

	var curve := Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	trail_particles.scale_amount_curve = curve
	trail_particles.scale_amount_min = 4.0
	trail_particles.scale_amount_max = 8.0

	trail_particles.color = Color(0.2, 0.6, 1.0, 0.6)
	trail_particles.emitting = false
	parent.add_child(trail_particles)
	return trail_particles


static func update_hero_trail(trail_particles: CPUParticles2D, velocity: Vector2, modulate_color: Color) -> void:
	if velocity.length_squared() > 100.0:
		trail_particles.emitting = true
		trail_particles.direction = -velocity.normalized()
	else:
		trail_particles.emitting = false
	trail_particles.color = modulate_color
	trail_particles.color.a = 0.6


static func show_emote(parent: Node, emoji: String) -> void:
	var old_label := parent.get_node_or_null("EmoteLabel")
	if old_label != null:
		old_label.queue_free()

	var label := Label.new()
	label.name = "EmoteLabel"
	label.text = emoji
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var settings := LabelSettings.new()
	settings.font_size = 28
	settings.outline_size = 4
	settings.outline_color = Color.BLACK
	label.label_settings = settings

	label.size = Vector2(80, 40)
	label.position = Vector2(-40, -60)
	parent.add_child(label)

	label.scale = Vector2(0.2, 0.2)
	label.pivot_offset = Vector2(40, 20)

	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", -90.0, 1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.15)

	var fade_tween := parent.create_tween()
	fade_tween.tween_interval(0.9)
	fade_tween.tween_property(label, "modulate:a", 0.0, 0.3)
	fade_tween.chain().tween_callback(label.queue_free)


static func toggle_squid_visuals(player: Node, active: bool) -> void:
	for child in player.get_children():
		if child is Polygon2D or child is Sprite2D or child is AnimatedSprite2D:
			if child.name != "SquidVisual":
				child.visible = not active

	var squid = player.get_node_or_null("SquidVisual")
	if active:
		if squid == null:
			squid = Label.new()
			squid.name = "SquidVisual"
			squid.text = "🦑"
			squid.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			squid.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var settings := LabelSettings.new()
			settings.font_size = 32
			squid.label_settings = settings
			squid.size = Vector2(48, 48)
			squid.position = -Vector2(24, 24)
			player.add_child(squid)
		squid.visible = true
		if player.has_method("set_crouch_state"):
			player.set_crouch_state(true)
	else:
		if squid != null:
			squid.visible = false
		if player.has_method("set_crouch_state"):
			player.set_crouch_state(false)


static func draw_player_overlays(player: Node2D) -> void:
	if bool(player.get("is_grappling")):
		var target_pos: Vector2 = player.get("grapple_target_pos")
		player.draw_line(Vector2.ZERO, player.to_local(target_pos), Color(0.85, 0.65, 0.15), 3.0)
	if bool(player.get("is_rope_climbing")):
		var current_rope: Node2D = player.get("current_rope")
		if current_rope != null:
			player.draw_line(Vector2.ZERO, player.to_local(current_rope.global_position), Color(0.15, 0.65, 0.15), 2.5)
	if bool(player.get("is_star_mode")):
		player.draw_arc(Vector2.ZERO, 28.0, 0, TAU, 24, Color(1.0, 0.85, 0.1, 0.5), 3.0)
		player.draw_arc(Vector2.ZERO, 32.0, 0, TAU, 24, Color(1.0, 0.6, 0.1, 0.3), 2.0)
	if bool(player.get("is_charge_jump_charging")):
		var charge_timer: float = player.get("charge_jump_timer")
		var time_per_level: float = player.get("charge_jump_time_per_level")
		var ratio = clamp(charge_timer / max(time_per_level * 3.0, 0.1), 0.0, 1.0)
		player.draw_arc(Vector2.ZERO, 30.0, -PI * 0.75, -PI * 0.75 + TAU * ratio, 24, Color(1.0, 0.85, 0.1, 0.8), 4.0)
		player.draw_arc(Vector2.ZERO, 34.0, 0, TAU, 24, Color(1.0, 0.65, 0.1, 0.25), 2.0)
