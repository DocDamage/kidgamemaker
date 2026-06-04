extends RefCounted

# Death clustering: positions where the player has died 3+ times get an
# invisible assist platform spawned just below the hotspot.
const HOTSPOT_RADIUS := 96.0
const HOTSPOT_TRIGGER_COUNT := 3
const GHOST_STUCK_SECONDS := 30.0
const STRUGGLE_TIME_SCALE := 0.88
const STRUGGLE_CONSECUTIVE_THRESHOLD := 4   # deaths before time-slow kicks in


static func note_failure(
	failure_position: Vector2,
	spawned_entities: Array,
	level_balance_report: Dictionary,
	state: Dictionary
) -> Dictionary:
	var respawn_count := int(state.get("respawn_count", 0))
	var last_respawn_position: Vector2 = state.get("last_respawn_position", Vector2.ZERO)
	if last_respawn_position.distance_to(failure_position) <= HOTSPOT_RADIUS:
		respawn_count += 1
	else:
		respawn_count = 1

	state["respawn_count"] = respawn_count
	state["last_respawn_position"] = failure_position

	# Track death hotspot cluster history for invisible platform spawning
	var death_clusters: Array = state.get("death_clusters", [])
	var merged := false
	for cluster in death_clusters:
		if Vector2(cluster["x"], cluster["y"]).distance_to(failure_position) <= HOTSPOT_RADIUS:
			cluster["count"] = int(cluster.get("count", 0)) + 1
			merged = true
			break
	if not merged:
		death_clusters.append({"x": failure_position.x, "y": failure_position.y, "count": 1})
	state["death_clusters"] = death_clusters

	var trigger_assist := (respawn_count >= 3)
	var trigger_time_slow := (respawn_count >= STRUGGLE_CONSECUTIVE_THRESHOLD)

	# Find hotspot clusters that need an invisible platform
	var spawn_invisible_platform_at: Array = []
	for cluster in death_clusters:
		if int(cluster.get("count", 0)) == HOTSPOT_TRIGGER_COUNT:
			# Only trigger once per cluster (count == exactly the threshold)
			spawn_invisible_platform_at.append(Vector2(cluster["x"], cluster["y"]))

	if float(state.get("hint_cooldown", 0.0)) > 0.0:
		return {
			"state": state,
			"hint": "",
			"trigger_assist": trigger_assist,
			"trigger_time_slow": trigger_time_slow,
			"spawn_invisible_platforms": spawn_invisible_platform_at,
		}

	if respawn_count < 2:
		return {
			"state": state,
			"hint": "",
			"trigger_assist": trigger_assist,
			"trigger_time_slow": trigger_time_slow,
			"spawn_invisible_platforms": spawn_invisible_platform_at,
		}

	var last_hint_position: Vector2 = state.get("last_hint_position", Vector2(-99999, -99999))
	if last_hint_position.distance_to(failure_position) <= HOTSPOT_RADIUS and respawn_count < 4:
		return {
			"state": state,
			"hint": "",
			"trigger_assist": trigger_assist,
			"trigger_time_slow": trigger_time_slow,
			"spawn_invisible_platforms": spawn_invisible_platform_at,
		}

	var hint_text := _build_hint(failure_position, spawned_entities, level_balance_report)
	if hint_text == "":
		return {
			"state": state,
			"hint": "",
			"trigger_assist": trigger_assist,
			"trigger_time_slow": trigger_time_slow,
			"spawn_invisible_platforms": spawn_invisible_platform_at,
		}

	state["last_hint_position"] = failure_position
	state["hint_cooldown"] = 12.0
	return {
		"state": state,
		"hint": hint_text,
		"trigger_assist": trigger_assist,
		"trigger_time_slow": trigger_time_slow,
		"spawn_invisible_platforms": spawn_invisible_platform_at,
	}


static func note_stuck(
	current_position: Vector2,
	state: Dictionary
) -> Dictionary:
	## Call every frame from Main._process. Returns true if player is stuck and a ghost helper should appear.
	var last_pos: Vector2 = state.get("stuck_last_pos", current_position)
	var stuck_timer: float = float(state.get("stuck_timer", 0.0))

	if current_position.distance_to(last_pos) > 50.0:
		# Player is moving — reset the stuck timer and update last position
		state["stuck_last_pos"] = current_position
		state["stuck_timer"] = 0.0
		return {"state": state, "show_ghost_helper": false}

	stuck_timer += get_process_delta_time_estimate()
	state["stuck_timer"] = stuck_timer
	var show_ghost := stuck_timer >= GHOST_STUCK_SECONDS
	if show_ghost:
		state["stuck_timer"] = 0.0  # Reset so it doesn't fire every frame
	return {"state": state, "show_ghost_helper": show_ghost}


static func get_process_delta_time_estimate() -> float:
	## Approximate delta for note_stuck — actual delta passed by caller is better,
	## but this static helper allows RefCounted usage without Engine access.
	return 1.0 / 60.0


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
