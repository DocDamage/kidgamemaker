extends RefCounted


static func process_travel(player: CharacterBody2D) -> bool:
	if not bool(player.get("is_in_clear_pipe")):
		return false

	var pipe_direction := player.get("pipe_direction") as Vector2
	var pipe_current_block := player.get("pipe_current_block") as Node2D
	if pipe_current_block == null or pipe_direction == Vector2.ZERO:
		_exit_pipe(player, pipe_direction)
		return false

	player.velocity = pipe_direction * 600.0
	var to_current := pipe_current_block.global_position - player.global_position
	if to_current.dot(player.velocity) <= 0.0:
		player.global_position = pipe_current_block.global_position
		var next_block := _find_next_pipe_block(player, pipe_current_block, pipe_direction)
		if next_block != null:
			player.set("pipe_previous_block", pipe_current_block)
			player.set("pipe_current_block", next_block)
		else:
			_exit_pipe(player, pipe_direction)

	player.move_and_slide()
	return true


static func try_enter(player: CharacterBody2D) -> bool:
	var main_ref := player.get_parent()
	if main_ref == null or not ("spawned_entities" in main_ref):
		return false

	var overlapping_pipe := _find_overlapping_pipe(player, main_ref.get("spawned_entities"))
	if overlapping_pipe == null:
		return false

	var desired_dir := _pressed_direction()
	if desired_dir == Vector2.ZERO:
		return false

	var search_pos := overlapping_pipe.global_position + desired_dir * 48.0
	if not _has_adjacent_pipe(search_pos, main_ref.get("spawned_entities")):
		return false

	player.set("is_in_clear_pipe", true)
	player.set("pipe_current_block", overlapping_pipe)
	player.set("pipe_previous_block", null)
	player.set("pipe_direction", desired_dir)
	player.global_position = overlapping_pipe.global_position
	player.velocity = desired_dir * 600.0
	if main_ref.has_method("play_sfx"):
		main_ref.play_sfx("jump")
	player.move_and_slide()
	return true


static func _find_next_pipe_block(player: CharacterBody2D, current_block: Node2D, direction: Vector2) -> Node2D:
	var main_node := player.get_parent()
	if main_node == null or not ("spawned_entities" in main_node):
		return null

	var spawned: Array = main_node.get("spawned_entities")
	var straight_pos := current_block.global_position + direction * 48.0
	for ent in spawned:
		var pipe := ent as Node2D
		if _is_clear_pipe(pipe) and pipe.global_position.distance_to(straight_pos) < 24.0:
			return pipe

	var previous_block := player.get("pipe_previous_block") as Node2D
	for ent in spawned:
		var pipe := ent as Node2D
		if not _is_clear_pipe(pipe) or pipe == current_block or pipe == previous_block:
			continue
		if pipe.global_position.distance_to(current_block.global_position) < 56.0:
			var new_direction := (pipe.global_position - current_block.global_position).normalized()
			if abs(new_direction.x) > abs(new_direction.y):
				new_direction = Vector2(sign(new_direction.x), 0.0)
			else:
				new_direction = Vector2(0.0, sign(new_direction.y))
			player.set("pipe_direction", new_direction)
			return pipe

	return null


static func _find_overlapping_pipe(player: CharacterBody2D, spawned: Array) -> Node2D:
	for ent in spawned:
		var pipe := ent as Node2D
		if _is_clear_pipe(pipe) and player.global_position.distance_to(pipe.global_position) < 28.0:
			return pipe
	return null


static func _has_adjacent_pipe(search_pos: Vector2, spawned: Array) -> bool:
	for ent in spawned:
		var pipe := ent as Node2D
		if _is_clear_pipe(pipe) and pipe.global_position.distance_to(search_pos) < 24.0:
			return true
	return false


static func _is_clear_pipe(node: Node2D) -> bool:
	return node != null and is_instance_valid(node) and node.has_meta("asset_id") and node.get_meta("asset_id") == "clear_pipe"


static func _pressed_direction() -> Vector2:
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		return Vector2.LEFT
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		return Vector2.RIGHT
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		return Vector2.UP
	if Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		return Vector2.DOWN
	return Vector2.ZERO


static func _exit_pipe(player: CharacterBody2D, direction: Vector2) -> void:
	player.set("is_in_clear_pipe", false)
	player.velocity = direction * 500.0
	player.set("pipe_current_block", null)
	player.set("pipe_previous_block", null)
	var main_ref := player.get_parent()
	if main_ref != null and main_ref.has_method("play_sfx"):
		main_ref.play_sfx("jump")
