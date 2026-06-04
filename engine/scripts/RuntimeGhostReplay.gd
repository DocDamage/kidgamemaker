extends RefCounted

const RuntimeVisualFactory = preload("res://scripts/RuntimeVisualFactory.gd")


static func update(
	player: Node2D,
	ghost_node: Node2D,
	run_record: Array,
	current_run: Array,
	ghost_playback_index: int,
	physics_tick_counter: int,
	death_y_threshold: float
) -> Dictionary:
	var should_respawn := false
	if player != null and is_instance_valid(player):
		if player.global_position.y > death_y_threshold:
			should_respawn = true
		elif physics_tick_counter % 3 == 0:
			current_run.append(player.global_position)

	if ghost_node != null and is_instance_valid(ghost_node) and not run_record.is_empty():
		if ghost_playback_index < run_record.size():
			ghost_node.global_position = run_record[ghost_playback_index]
			if physics_tick_counter % 3 == 0:
				ghost_playback_index += 1
		else:
			ghost_node.queue_free()
			ghost_node = null

	return {
		"should_respawn": should_respawn,
		"current_run": current_run,
		"ghost_node": ghost_node,
		"ghost_playback_index": ghost_playback_index,
	}


static func build_ghost(
	run_record: Array,
	active_player: Node2D,
	sidecar: Dictionary,
	size: Vector2,
	asset_root: String
) -> Node2D:
	if run_record.is_empty():
		return null
	if active_player == null or not is_instance_valid(active_player):
		return null

	var ghost := Node2D.new()
	ghost.name = "GhostPlayer"
	RuntimeVisualFactory.add_visuals(ghost, sidecar, size, Color(0.2, 0.55, 1.0, 0.45), asset_root)
	ghost.modulate.a = 0.45
	ghost.global_position = run_record[0]
	return ghost
