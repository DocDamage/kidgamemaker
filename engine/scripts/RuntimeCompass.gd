extends Node2D
## RuntimeCompass
##
## A physical in-world compass stamp the child places in their level.
## Each frame it rotates to point toward the nearest entity that has
## is_goal = true in its metadata, OR toward the exit portal, OR
## toward an enemy when no explicit goal exists.
##
## Visual: a glowing arrow emoji that wobbles gently and pulses.
## No UI overlay — the child has to *find and read the compass* in-world.

var _needle: Label = null
var _target_pos: Vector2 = Vector2.ZERO
var _wobble_timer: float = 0.0
var _pulse_tween: Tween = null


func _ready() -> void:
	_build_visual()
	_start_idle_pulse()


func _build_visual() -> void:
	# Background circle
	var circle := Label.new()
	circle.text = "🧭"
	circle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	circle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var bg_settings := LabelSettings.new()
	bg_settings.font_size = 38
	bg_settings.outline_size = 3
	bg_settings.outline_color = Color(0.0, 0.0, 0.0, 0.6)
	circle.label_settings = bg_settings
	circle.size = Vector2(48, 48)
	circle.position = Vector2(-24, -24)
	add_child(circle)

	# Rotating needle — an arrow that points to the goal
	_needle = Label.new()
	_needle.name = "CompassNeedle"
	_needle.text = "▲"
	_needle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_needle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var needle_settings := LabelSettings.new()
	needle_settings.font_size = 22
	needle_settings.font_color = Color(1.0, 0.92, 0.2, 0.95)   # bright gold
	needle_settings.outline_size = 2
	needle_settings.outline_color = Color(0.5, 0.3, 0.0, 0.8)
	_needle.label_settings = needle_settings
	_needle.size = Vector2(24, 24)
	_needle.position = Vector2(-12, -14)
	_needle.pivot_offset = Vector2(12, 12)
	add_child(_needle)


func _start_idle_pulse() -> void:
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(self, "scale",
		Vector2(1.08, 1.08), 0.8).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(self, "scale",
		Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	_wobble_timer += delta
	var goal_pos := _find_goal_position()
	if goal_pos == Vector2.ZERO:
		# No goal found — spin slowly
		if _needle != null:
			_needle.rotation += delta * 0.8
		return

	_target_pos = goal_pos
	var dir := (_target_pos - global_position).normalized()
	var target_angle := dir.angle() + (PI * 0.5)  # ▲ points up by default

	# Smooth rotation toward target with a gentle wobble
	if _needle != null:
		var wobble := sin(_wobble_timer * 3.0) * 0.05
		_needle.rotation = lerp_angle(_needle.rotation, target_angle + wobble, delta * 6.0)

	# Distance-based color: close = green, far = gold
	var dist := global_position.distance_to(_target_pos)
	if _needle != null and _needle.label_settings != null:
		var t := clampf(dist / 600.0, 0.0, 1.0)
		_needle.label_settings.font_color = Color(
			lerp(0.3, 1.0, t),   # R: green→gold
			lerp(1.0, 0.9, t),   # G
			lerp(0.3, 0.2, t),   # B
			0.95
		)


func _find_goal_position() -> Vector2:
	var main := get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return Vector2.ZERO

	var entities: Array = main.get("spawned_entities") if "spawned_entities" in main else []
	var best_pos := Vector2.ZERO
	var best_dist := INF
	var fallback_portal := Vector2.ZERO
	var fallback_enemy := Vector2.ZERO

	for entity in entities:
		if not is_instance_valid(entity) or not (entity is Node2D):
			continue
		var node := entity as Node2D

		# Priority 1: explicit is_goal meta
		if node.has_meta("is_goal") and bool(node.get_meta("is_goal")):
			var d := global_position.distance_to(node.global_position)
			if d < best_dist:
				best_dist = d
				best_pos = node.global_position
			continue

		# Priority 2: portal (exit)
		var asset_id := ""
		if node.has_meta("asset_id"):
			asset_id = str(node.get_meta("asset_id"))
		if asset_id.begins_with("portal") or asset_id.begins_with("exit"):
			fallback_portal = node.global_position

		# Priority 3: nearest enemy (basic direction hint)
		if node.has_method("take_damage") and not node.name.begins_with("Player"):
			if node.get("is_sleeping") != true:
				var d := global_position.distance_to(node.global_position)
				if d < best_dist:
					fallback_enemy = node.global_position

	if best_pos != Vector2.ZERO:
		return best_pos
	if fallback_portal != Vector2.ZERO:
		return fallback_portal
	return fallback_enemy
