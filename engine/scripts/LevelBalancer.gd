extends RefCounted


static func apply(entities: Array, enabled: bool, sidecar_loader: Callable, collision_sizer: Callable) -> Dictionary:
	var adjusted_entities: Array = []
	for entity in entities:
		if typeof(entity) == TYPE_DICTIONARY:
			adjusted_entities.append(entity.duplicate(true))
		else:
			adjusted_entities.append(entity)

	var report := {
		"enabled": enabled,
		"difficulty_score": 0.0,
		"predicted_difficulty": "cozy",
		"adjustments": [],
		"warnings": []
	}

	if not enabled:
		return {"entities": adjusted_entities, "report": report}

	var platforms: Array = []
	var player_count := 0
	var enemy_count := 0
	var hazard_count := 0
	var movement_pickups := 0

	for entity in adjusted_entities:
		if typeof(entity) != TYPE_DICTIONARY:
			continue

		var asset_id := str(entity.get("asset_id", ""))
		var category := str(entity.get("category", ""))
		var type_str := str(entity.get("type", ""))
		var loaded_sidecar: Variant = sidecar_loader.call(asset_id, category)
		var sidecar: Dictionary = loaded_sidecar if typeof(loaded_sidecar) == TYPE_DICTIONARY else {}
		var runtime_template := str(sidecar.get("runtime_template", type_str))
		if runtime_template == "":
			runtime_template = type_str

		if runtime_template == "player":
			player_count += 1
		elif runtime_template == "enemy":
			enemy_count += 1
		elif runtime_template == "hazard":
			hazard_count += 1

		var modifiers_value: Variant = entity.get("modifiers", {})
		var modifiers: Dictionary = modifiers_value if typeof(modifiers_value) == TYPE_DICTIONARY else {}
		if asset_id in ["gadget_glider", "gadget_jetpack", "charge_spring"] or str(modifiers.get("powerup_type", "")) == "double_jump":
			movement_pickups += 1

		if _is_platform(runtime_template, type_str, asset_id):
			var pos := _read_position(entity.get("position", {"x": 0, "y": 0}))
			var loaded_size: Variant = collision_sizer.call(sidecar, Vector2(128, 32), entity)
			var size: Vector2 = loaded_size if typeof(loaded_size) == TYPE_VECTOR2 else Vector2(128, 32)
			platforms.append({
				"entity": entity,
				"position": pos,
				"size": size,
				"left": pos.x - size.x * 0.5,
				"right": pos.x + size.x * 0.5,
				"top": pos.y - size.y * 0.5
			})

	platforms.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("left", 0.0)) < float(b.get("left", 0.0))
	)

	var max_safe_gap := 220.0 + float(movement_pickups) * 35.0
	var max_vertical_delta := 150.0 + float(movement_pickups) * 20.0
	var largest_gap := 0.0
	var near_miss_margin := 96.0

	for i in range(platforms.size() - 1):
		var current: Dictionary = platforms[i]
		var next: Dictionary = platforms[i + 1]
		var gap: float = float(next.get("left", 0.0)) - float(current.get("right", 0.0))
		var vertical_delta: float = abs(float(next.get("top", 0.0)) - float(current.get("top", 0.0)))
		largest_gap = max(largest_gap, gap)

		if gap > max_safe_gap and gap <= max_safe_gap + near_miss_margin and vertical_delta <= max_vertical_delta:
			var nudge := gap - max_safe_gap
			var next_entity: Dictionary = next.get("entity", {})
			var next_pos := _read_position(next_entity.get("position", {"x": 0, "y": 0}))
			next_pos.x -= nudge
			next_entity["position"] = {"x": next_pos.x, "y": next_pos.y}
			next["left"] = float(next.get("left", 0.0)) - nudge
			next["right"] = float(next.get("right", 0.0)) - nudge
			next["position"] = next_pos
			report["adjustments"].append("Nudged %s left %.0f px to keep a jump reachable." % [str(next_entity.get("instance_id", next_entity.get("asset_id", "platform"))), nudge])
		elif gap > max_safe_gap + near_miss_margin or vertical_delta > max_vertical_delta:
			report["warnings"].append("Large jump between platforms near x=%.0f may need a spring, bridge, or helper pickup." % float(current.get("right", 0.0)))

	var difficulty_score: float = float(enemy_count) * 1.4 + float(hazard_count) * 1.8 + max(0.0, largest_gap - 160.0) / 60.0
	if player_count == 0:
		report["warnings"].append("No hero stamp found.")
		difficulty_score += 3.0

	var predicted := "cozy"
	if difficulty_score >= 7.0:
		predicted = "spicy"
	elif difficulty_score >= 3.5:
		predicted = "adventurous"

	report["difficulty_score"] = snappedf(difficulty_score, 0.1)
	report["predicted_difficulty"] = predicted

	if report["adjustments"].size() > 0 or report["warnings"].size() > 0:
		print("Level Balancer report: ", report)

	return {"entities": adjusted_entities, "report": report}


static func _read_position(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))

	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0)), float(value.get("y", 0)))

	return Vector2.ZERO


static func _is_platform(runtime_template: String, type_str: String, asset_id: String) -> bool:
	if runtime_template in ["terrain", "destructible_terrain", "crumbling_cloud"]:
		return true
	if type_str in ["terrain", "destructible_terrain", "crumbling_cloud", "conveyor"]:
		return true
	return asset_id.contains("floor") or asset_id.contains("block") or asset_id.contains("platform")
