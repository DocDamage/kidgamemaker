extends RefCounted


static func note_failure(
	failure_position: Vector2,
	spawned_entities: Array,
	level_balance_report: Dictionary,
	state: Dictionary
) -> Dictionary:
	if float(state.get("hint_cooldown", 0.0)) > 0.0:
		return {"state": state, "hint": ""}

	var respawn_count := int(state.get("respawn_count", 0))
	var last_respawn_position: Vector2 = state.get("last_respawn_position", Vector2.ZERO)
	if last_respawn_position.distance_to(failure_position) <= 96.0:
		respawn_count += 1
	else:
		respawn_count = 1

	state["respawn_count"] = respawn_count
	state["last_respawn_position"] = failure_position
	if respawn_count < 2:
		return {"state": state, "hint": ""}

	var last_hint_position: Vector2 = state.get("last_hint_position", Vector2(-99999, -99999))
	if last_hint_position.distance_to(failure_position) <= 96.0 and respawn_count < 4:
		return {"state": state, "hint": ""}

	var hint_text := _build_hint(failure_position, spawned_entities, level_balance_report)
	if hint_text == "":
		return {"state": state, "hint": ""}

	state["last_hint_position"] = failure_position
	state["hint_cooldown"] = 12.0
	return {"state": state, "hint": hint_text}


static func _build_hint(failure_position: Vector2, spawned_entities: Array, level_balance_report: Dictionary) -> String:
	var nearby_hazard := _nearest_entity_matching(spawned_entities, failure_position, ["hazard", "cactus", "spike"], 180.0)
	if nearby_hazard != null:
		return "Try waiting, blocking, or jumping over the danger."

	var nearby_enemy := _nearest_entity_matching(spawned_entities, failure_position, ["enemy", "slime"], 180.0)
	if nearby_enemy != null:
		return "Use your attack button, stomp from above, or give yourself a sword."

	var nearby_platform := _nearest_entity_matching(spawned_entities, failure_position, ["terrain", "floor", "block", "platform"], 240.0)
	if nearby_platform != null:
		return "Hold run before jumping, or add a spring if this jump feels too big."

	if level_balance_report.has("warnings") and level_balance_report["warnings"].size() > 0:
		return "This room has one tricky jump. A bridge, spring, or double jump pickup can help."

	return "Take a breath and try one small jump at a time."


static func _nearest_entity_matching(spawned_entities: Array, origin: Vector2, keywords: Array, max_distance: float) -> Node2D:
	var closest: Node2D = null
	var closest_distance := max_distance
	for entity in spawned_entities:
		if not is_instance_valid(entity) or not (entity is Node2D):
			continue

		var node := entity as Node2D
		var descriptor := node.name.to_lower()
		if node.has_meta("asset_id"):
			descriptor += " " + str(node.get_meta("asset_id")).to_lower()
		if "asset_id" in node:
			descriptor += " " + str(node.get("asset_id")).to_lower()

		var matches := false
		for keyword in keywords:
			if descriptor.contains(str(keyword)):
				matches = true
				break

		if not matches:
			continue

		var distance := origin.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = node

	return closest
