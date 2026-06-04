extends Node

const HudMinimapScript = preload("res://scripts/HudMinimap.gd")

var main_context: Node = null
var hud_canvas: CanvasLayer = null
var hud_health_label: Label = null
var hud_score_label: Label = null
var hud_helper_label: Label = null


func configure(context: Node) -> void:
	main_context = context


func clear_hud() -> void:
	if hud_canvas != null and is_instance_valid(hud_canvas):
		hud_canvas.queue_free()
	hud_canvas = null
	hud_health_label = null
	hud_score_label = null
	hud_helper_label = null


func create_hud() -> void:
	clear_hud()
	if main_context == null:
		return

	hud_canvas = CanvasLayer.new()
	hud_canvas.layer = 100
	main_context.add_child(hud_canvas)

	var control := Control.new()
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_canvas.add_child(control)

	hud_health_label = Label.new()
	hud_health_label.position = Vector2(24, 24)
	var health_settings := LabelSettings.new()
	health_settings.font_size = 28
	health_settings.outline_size = 6
	health_settings.outline_color = Color.BLACK
	hud_health_label.label_settings = health_settings
	control.add_child(hud_health_label)

	hud_score_label = Label.new()
	hud_score_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_score_label.anchor_left = 1.0
	hud_score_label.anchor_right = 1.0
	hud_score_label.offset_left = -250
	hud_score_label.offset_top = 24
	var score_settings := LabelSettings.new()
	score_settings.font_size = 28
	score_settings.outline_size = 6
	score_settings.outline_color = Color.BLACK
	hud_score_label.label_settings = score_settings
	control.add_child(hud_score_label)

	hud_helper_label = Label.new()
	hud_helper_label.position = Vector2(24, 58)
	var helper_settings := LabelSettings.new()
	helper_settings.font_size = 18
	helper_settings.font_color = Color(0.45, 0.9, 1.0)
	helper_settings.outline_size = 4
	helper_settings.outline_color = Color.BLACK
	hud_helper_label.label_settings = helper_settings
	control.add_child(hud_helper_label)

	var boss_hud := Control.new()
	boss_hud.name = "BossHUD"
	boss_hud.grow_horizontal = Control.GROW_DIRECTION_BOTH
	boss_hud.anchor_left = 0.5
	boss_hud.anchor_right = 0.5
	boss_hud.offset_left = -200
	boss_hud.offset_right = 200
	boss_hud.offset_top = 24
	boss_hud.offset_bottom = 80
	boss_hud.visible = false
	control.add_child(boss_hud)

	var bar_bg := ColorRect.new()
	bar_bg.name = "BarBg"
	bar_bg.color = Color(0.1, 0.1, 0.1, 0.85)
	bar_bg.size = Vector2(400, 16)
	bar_bg.position = Vector2(0, 28)
	boss_hud.add_child(bar_bg)

	var bar_fill := ColorRect.new()
	bar_fill.name = "BarFill"
	bar_fill.color = Color(0.85, 0.15, 0.15, 1.0)
	bar_fill.size = Vector2(400, 16)
	bar_fill.position = Vector2(0, 28)
	boss_hud.add_child(bar_fill)

	var border := ReferenceRect.new()
	border.name = "Border"
	border.border_color = Color(0.5, 0.5, 0.5)
	border.border_width = 2.0
	border.editor_only = false
	border.size = Vector2(400, 16)
	border.position = Vector2(0, 28)
	boss_hud.add_child(border)

	var boss_label := Label.new()
	boss_label.name = "BossLabel"
	boss_label.text = "BOSS"
	boss_label.size = Vector2(400, 24)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var boss_lbl_settings := LabelSettings.new()
	boss_lbl_settings.font_size = 18
	boss_lbl_settings.outline_size = 4
	boss_lbl_settings.outline_color = Color.BLACK
	boss_label.label_settings = boss_lbl_settings
	boss_hud.add_child(boss_label)

	_add_minimap(control)


func update_hud() -> void:
	if main_context == null:
		return
	if hud_health_label == null or not is_instance_valid(hud_health_label):
		return
	if hud_score_label == null or not is_instance_valid(hud_score_label):
		return

	if hud_helper_label != null and is_instance_valid(hud_helper_label):
		var report: Dictionary = main_context.get("level_balance_report")
		var predicted := str(report.get("predicted_difficulty", "cozy"))
		var warning_count := 0
		if report.has("warnings"):
			warning_count = int(report["warnings"].size())
		if warning_count > 0:
			hud_helper_label.text = "Chip: %s room, %d tip ready" % [predicted.capitalize(), warning_count]
		elif bool(main_context.get("level_balancer_enabled")):
			hud_helper_label.text = "Chip: %s room" % predicted.capitalize()
		else:
			hud_helper_label.text = ""

	var health_style: String = main_context.get("health_style") if main_context != null else "hearts"
	var active_player: Node = main_context.get("active_player")
	if health_style != "diegetic" and active_player != null and is_instance_valid(active_player):
		var hp: int = active_player.get("current_health") if "current_health" in active_player else 100
		var max_hp: int = active_player.get("max_health") if "max_health" in active_player else 100
		hud_health_label.text = "HP: " + _heart_text(hp, max_hp, str(main_context.get("difficulty")))
	else:
		hud_health_label.text = ""

	hud_score_label.text = "⭐ " + str(main_context.get("score"))
	if active_player != null and is_instance_valid(active_player) and active_player.get("has_jetpack") == true:
		hud_score_label.text = "🚀 " + str(int(active_player.get("jetpack_fuel"))) + "% | " + hud_score_label.text

	var keys_collected: Dictionary = main_context.get("keys_collected")
	var keys_str := ""
	for color in keys_collected.keys():
		var count: int = keys_collected[color]
		if count > 0:
			var emoji := "🔑"
			if color == "red":
				emoji = "🔴🔑"
			elif color == "blue":
				emoji = "🔵🔑"
			else:
				emoji = "🟡🔑"
			keys_str += " %s×%d" % [emoji, count]

	if keys_str != "":
		hud_score_label.text = keys_str + " | " + hud_score_label.text

	_update_boss_hud()


func show_boss_banner(boss: Node2D) -> void:
	if hud_canvas == null or not is_instance_valid(hud_canvas):
		return
	if hud_canvas.get_child_count() == 0:
		return

	var banner = ColorRect.new()
	banner.name = "BossBanner"
	banner.color = Color(0, 0, 0, 0.75)
	banner.size = Vector2(800, 120)
	banner.anchors_preset = Control.PRESET_CENTER_TOP
	banner.position = Vector2(-400, 100)

	var label = Label.new()
	label.text = "🚨 WARNING: BOSS ENCOUNTER! 🚨"
	if boss.has_meta("asset_id"):
		label.text += "\n" + str(boss.get_meta("asset_id")).replace("_", " ").to_upper()
	else:
		label.text += "\nMEGA MONSTER"

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_font_size_override("font_size", 28)
	label.size = banner.size
	banner.add_child(label)

	banner.modulate.a = 0
	hud_canvas.get_child(0).add_child(banner)

	var label_tween = create_tween()
	label_tween.tween_property(banner, "modulate:a", 1.0, 0.4)
	label_tween.tween_interval(1.8)
	label_tween.tween_property(banner, "modulate:a", 0.0, 0.4)
	label_tween.tween_callback(banner.queue_free)


func _heart_text(hp: int, max_hp: int, difficulty: String) -> String:
	if difficulty == "creative":
		return "👑👑👑👑👑"

	var hearts_str := ""
	var total_hearts := 5
	var hp_per_heart := float(max_hp) / float(total_hearts)
	for i in range(total_hearts):
		var threshold := (i + 1) * hp_per_heart
		if float(hp) >= threshold:
			hearts_str += "❤️"
		elif float(hp) >= threshold - (hp_per_heart * 0.5):
			hearts_str += "💔"
		else:
			hearts_str += "🖤"
	return hearts_str


func _update_boss_hud() -> void:
	if hud_canvas == null or not is_instance_valid(hud_canvas) or hud_canvas.get_child_count() == 0:
		return
	var hud_control = hud_canvas.get_child(0)
	if hud_control == null or not hud_control.has_node("BossHUD"):
		return

	var boss_hud = hud_control.get_node("BossHUD")
	var current_boss_node: Node = main_context.get("current_boss_node")
	if current_boss_node != null and is_instance_valid(current_boss_node) and current_boss_node.get("current_health") > 0:
		boss_hud.visible = true
		var hp: int = current_boss_node.get("current_health")
		var max_hp: int = current_boss_node.get("max_health")
		var ratio := float(hp) / float(max_hp)
		var raw_name = str(current_boss_node.get_meta("asset_id")).replace("_", " ").to_upper() if current_boss_node.has_meta("asset_id") else "BOSS"
		var style: String = current_boss_node.get("boss_hud_style") if "boss_hud_style" in current_boss_node else "retro"
		var phase: int = current_boss_node.get("current_phase") if "current_phase" in current_boss_node else 1
		var label_text := ""
		var fill_color := Color.RED

		match style:
			"royal":
				label_text = "👑 " + raw_name + " 👑"
				fill_color = Color(1.0, 0.85, 0.0)
			"spooky":
				label_text = "💀 " + raw_name + " 💀"
				fill_color = Color(0.6, 0.1, 0.95)
			_:
				label_text = "👾 " + raw_name + " 👾"
				fill_color = Color(0.85, 0.15, 0.15)

		if phase > 1:
			label_text += " [PHASE %d]" % phase
			if phase == 2:
				fill_color = fill_color.lerp(Color.ORANGE, 0.5)
			elif phase == 3:
				var t = Time.get_ticks_msec() / 100.0
				var flash_factor = sin(t) * 0.4 + 0.6
				fill_color = Color(1.0, 0.1, 0.1).lerp(Color(1.0, 0.8, 0.8), flash_factor)
				label_text += " (⚡ENRAGED⚡)"

		boss_hud.get_node("BossLabel").text = label_text
		boss_hud.get_node("BarFill").size.x = 400.0 * clamp(ratio, 0.0, 1.0)
		boss_hud.get_node("BarFill").color = fill_color
	else:
		boss_hud.visible = false


func _add_minimap(control: Control) -> void:
	var minimap := Control.new()
	minimap.name = "Minimap"
	minimap.custom_minimum_size = Vector2(160, 100)
	minimap.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	minimap.anchor_left = 1.0
	minimap.anchor_right = 1.0
	minimap.anchor_top = 1.0
	minimap.anchor_bottom = 1.0
	minimap.offset_left = -180
	minimap.offset_right = -20
	minimap.offset_top = -120
	minimap.offset_bottom = -20

	minimap.set_script(HudMinimapScript)
	control.add_child(minimap)
