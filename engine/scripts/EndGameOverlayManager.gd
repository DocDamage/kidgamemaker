extends Node

const PANEL_CORNER_RADIUS := 24
const BUTTON_SIZE := Vector2(180, 50)

var main_context: Node = null


func configure(context: Node) -> void:
	main_context = context


func show_victory(celebration: String) -> void:
	var panel := _show_overlay("🏆 VICTORY! 🏆", Color(0.06, 0.09, 0.16, 0.85), Color(0.98, 0.75, 0.14), "Play Again 🔄")
	if celebration == "confetti":
		_add_confetti(panel)


func show_game_over() -> void:
	_show_overlay("💀 GAME OVER 💀", Color(0.18, 0.05, 0.05, 0.85), Color(0.9, 0.15, 0.15), "Try Again 🔄")


func _show_overlay(title: String, background: Color, accent: Color, replay_text: String) -> Panel:
	var overlay := CanvasLayer.new()
	overlay.layer = 200
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_target_parent().add_child(overlay)

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _panel_style(background, accent))
	overlay.add_child(panel)

	_add_title(panel, title, accent)
	_add_overlay_button(panel, replay_text, -200, -20, func() -> void:
		get_tree().paused = false
		overlay.queue_free()
		get_tree().reload_current_scene()
	)
	_add_overlay_button(panel, "Close Game ❌", 20, 200, func() -> void:
		get_tree().paused = false
		overlay.queue_free()
		if OS.has_feature("web"):
			JavaScriptBridge.eval("window.parent.postMessage('close_game', '*')")
		else:
			get_tree().quit()
	)

	get_tree().paused = true
	return panel


func _target_parent() -> Node:
	return main_context if main_context != null and is_instance_valid(main_context) else self


func _panel_style(background: Color, accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_width_left = 8
	style.border_width_top = 8
	style.border_width_right = 8
	style.border_width_bottom = 8
	style.border_color = accent
	style.corner_radius_top_left = PANEL_CORNER_RADIUS
	style.corner_radius_top_right = PANEL_CORNER_RADIUS
	style.corner_radius_bottom_left = PANEL_CORNER_RADIUS
	style.corner_radius_bottom_right = PANEL_CORNER_RADIUS
	return style


func _add_title(panel: Panel, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 48
	settings.font_color = color
	settings.outline_size = 8
	settings.outline_color = Color.BLACK
	label.label_settings = settings
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.anchor_top = 0.35
	label.anchor_bottom = 0.35
	label.offset_left = -200
	label.offset_right = 200
	label.offset_top = -30
	label.offset_bottom = 30
	label.scale = Vector2(0.2, 0.2)
	label.pivot_offset = Vector2(200, 30)
	panel.add_child(label)

	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.35).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.15)


func _add_overlay_button(panel: Panel, text: String, offset_left: float, offset_right: float, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = BUTTON_SIZE
	button.anchor_left = 0.5
	button.anchor_right = 0.5
	button.anchor_top = 0.65
	button.anchor_bottom = 0.65
	button.offset_left = offset_left
	button.offset_right = offset_right
	button.offset_top = -25
	button.offset_bottom = 25
	button.pressed.connect(callback)
	panel.add_child(button)


func _add_confetti(panel: Panel) -> void:
	var particles := CPUParticles2D.new()
	particles.amount = 120
	particles.lifetime = 4.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(800, 10)
	particles.direction = Vector2(0, 1.0)
	particles.spread = 15.0
	particles.gravity = Vector2(0, 150)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0
	particles.position = Vector2(500, -300)
	particles.process_mode = Node.PROCESS_MODE_ALWAYS

	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.2, 0.2))
	gradient.add_key(0.2, Color(1.0, 0.8, 0.2))
	gradient.add_key(0.4, Color(0.2, 1.0, 0.2))
	gradient.add_key(0.6, Color(0.2, 0.8, 1.0))
	gradient.add_key(0.8, Color(0.8, 0.2, 1.0))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	particles.color_ramp = gradient

	panel.add_child(particles)
	particles.emitting = true
