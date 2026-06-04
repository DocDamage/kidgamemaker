extends Node2D

var drain_rate: float = 10.0
var _timer: float = 0.0


func _process(delta: float) -> void:
	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var player: Node2D = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return

	global_position = global_position.lerp(player.global_position + Vector2(24, -32), delta * 3.0)

	_timer += delta
	if _timer < 1.5:
		return

	_timer = 0.0
	var closest_enemy := _find_closest_enemy(player)
	if closest_enemy == null:
		return

	closest_enemy.take_damage(5)
	if player.has_method("heal"):
		player.heal(2)
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("DRAIN!", closest_enemy.global_position, Color.PURPLE)
	_show_drain_line(closest_enemy.global_position)


func _find_closest_enemy(player: Node2D) -> Node2D:
	var closest_enemy: Node2D = null
	var min_dist := 120.0
	var parent := get_parent()
	if parent == null:
		return null

	for child in parent.get_children():
		var enemy := child as Node2D
		if enemy == null or enemy == player or not enemy.has_method("take_damage"):
			continue
		if enemy.name.begins_with("Player"):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_enemy = enemy

	return closest_enemy


func _show_drain_line(target_position: Vector2) -> void:
	var line := Line2D.new()
	line.add_point(Vector2.ZERO)
	line.add_point(target_position - global_position)
	line.width = 3.0
	line.default_color = Color(0.6, 0.2, 0.8, 0.6)
	add_child(line)

	var tween := create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(line.queue_free)
