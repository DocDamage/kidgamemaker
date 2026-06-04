extends Node2D

var pet_power: String = "magnet"
var _magnet_timer: float = 0.0


func _process(delta: float) -> void:
	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var player: Node2D = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return

	var player_position := player.global_position
	global_position = global_position.lerp(player_position + Vector2(-36, -32), delta * 4.0)

	match pet_power:
		"magnet":
			_magnet_timer += delta
			if _magnet_timer >= 0.3:
				_magnet_timer = 0.0
				_pull_nearby_collectibles(main, player_position)
		"shield":
			_recharge_player_shield(main, player, delta)


func _pull_nearby_collectibles(main: Node, player_position: Vector2) -> void:
	var spawned: Variant = main.get("spawned_entities")
	if not spawned is Array:
		return

	for ent: Variant in spawned:
		var item := ent as Node2D
		if item != null and is_instance_valid(item) and item.has_meta("is_collectible"):
			if global_position.distance_to(item.global_position) < 160.0:
				var tween := item.create_tween()
				tween.tween_property(item, "global_position", player_position, 0.25)


func _recharge_player_shield(main: Node, player: Node2D, delta: float) -> void:
	if bool(player.get("shield_active")):
		return

	_magnet_timer += delta
	if _magnet_timer < 5.0:
		return

	_magnet_timer = 0.0
	player.set("shield_active", true)
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("SHIELD RECHARGED!", player.global_position, Color.MAGENTA)
