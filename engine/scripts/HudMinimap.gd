extends Control

var main: Node2D = null


func _ready() -> void:
	main = get_tree().get_root().get_node_or_null("Main")


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.12, 0.2, 0.75), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.6, 0.9, 0.9), false, 2.0)
	if main == null or not is_instance_valid(main) or main.active_player == null or not is_instance_valid(main.active_player):
		return

	var bounds := _terrain_bounds()
	if bounds.is_empty():
		return
	var min_x: float = bounds["min_x"]
	var max_x: float = bounds["max_x"]
	var min_y: float = bounds["min_y"]
	var max_y: float = bounds["max_y"]
	var world_size := Vector2(max_x - min_x, max_y - min_y)
	if world_size.x <= 0.0 or world_size.y <= 0.0:
		return

	var map_scale: float = min((size.x - 20.0) / world_size.x, (size.y - 20.0) / world_size.y)
	for ent in main.spawned_entities:
		if not is_instance_valid(ent):
			continue
		var local_pos := _to_minimap(ent.global_position, min_x, min_y, map_scale)
		if ent is StaticBody2D or ent.name.begins_with("stone_floor") or ent.name.begins_with("floor"):
			draw_rect(Rect2(local_pos - Vector2(12, 3) * map_scale, Vector2(24, 6) * map_scale), Color(0.45, 0.45, 0.45, 0.9), true)
		elif ent.name.begins_with("brick_destructible") or ent.name.begins_with("ice_destructible"):
			draw_rect(Rect2(local_pos - Vector2(12, 3) * map_scale, Vector2(24, 6) * map_scale), Color(0.85, 0.55, 0.3, 0.9), true)
		elif ent.has_meta("is_collectible"):
			draw_circle(local_pos, 2.0, Color.GOLD)
		elif ent is Area2D and (ent.name.begins_with("portal") or ent.name.begins_with("locked_door")):
			draw_circle(local_pos, 3.0, Color.PURPLE)

	var player_pos := _to_minimap(main.active_player.global_position, min_x, min_y, map_scale)
	draw_circle(player_pos, 4.0, Color.YELLOW)


func _terrain_bounds() -> Dictionary:
	var min_x := 999999.0
	var max_x := -999999.0
	var min_y := 999999.0
	var max_y := -999999.0
	var found := false
	for ent in main.spawned_entities:
		if is_instance_valid(ent) and (ent is StaticBody2D or ent.name.begins_with("stone_floor") or ent.name.begins_with("floor") or ent.name.begins_with("brick_destructible")):
			found = true
			var pos: Vector2 = ent.global_position
			min_x = min(min_x, pos.x - 64)
			max_x = max(max_x, pos.x + 64)
			min_y = min(min_y, pos.y - 16)
			max_y = max(max_y, pos.y + 16)
	if not found:
		return {}
	return {
		"min_x": min_x,
		"max_x": max_x,
		"min_y": min_y,
		"max_y": max_y
	}


func _to_minimap(world_pos: Vector2, min_x: float, min_y: float, map_scale: float) -> Vector2:
	return Vector2((world_pos.x - min_x) * map_scale + 10.0, (world_pos.y - min_y) * map_scale + 10.0)
