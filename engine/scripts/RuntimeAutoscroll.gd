extends RefCounted


static func update(
	camera: Camera2D,
	player: Node2D,
	direction: String,
	speed: float,
	delta: float,
	view_size: Vector2
) -> bool:
	if camera == null or not is_instance_valid(camera):
		return false

	var scroll_dir := _direction_to_vector(direction)
	camera.global_position += scroll_dir * speed * delta

	if player == null or not is_instance_valid(player) or player.get("is_in_clear_pipe"):
		return false

	if view_size.x <= 0 or view_size.y <= 0:
		view_size = Vector2(1152, 648)

	return _clamp_player_to_camera(player, camera.global_position, view_size, direction)


static func _clamp_player_to_camera(player: Node2D, camera_position: Vector2, view_size: Vector2, direction: String) -> bool:
	var margin := 24.0
	var left_bound = camera_position.x - view_size.x * 0.5
	var right_bound = camera_position.x + view_size.x * 0.5
	var top_bound = camera_position.y - view_size.y * 0.5
	var bottom_bound = camera_position.y + view_size.y * 0.5
	var should_respawn := false

	if direction == "right":
		if player.global_position.x < left_bound - margin:
			should_respawn = true
		else:
			player.global_position.x = max(player.global_position.x, left_bound + 16)
	elif direction == "left":
		if player.global_position.x > right_bound + margin:
			should_respawn = true
		else:
			player.global_position.x = min(player.global_position.x, right_bound - 16)
	elif direction == "up":
		if player.global_position.y > bottom_bound + margin:
			should_respawn = true
		else:
			player.global_position.y = min(player.global_position.y, bottom_bound - 16)
	elif direction == "down":
		if player.global_position.y < top_bound - margin:
			should_respawn = true
		else:
			player.global_position.y = max(player.global_position.y, top_bound + 16)

	player.global_position.x = clamp(player.global_position.x, left_bound + 16, right_bound - 16)
	player.global_position.y = clamp(player.global_position.y, top_bound + 16, bottom_bound - 16)
	return should_respawn


static func _direction_to_vector(direction: String) -> Vector2:
	match direction:
		"left":
			return Vector2.LEFT
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		_:
			return Vector2.RIGHT
