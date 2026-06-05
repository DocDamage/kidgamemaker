extends Node

const RUNTIME_VICTORY_CONDITIONS_SCRIPT = preload("res://scripts/RuntimeVictoryConditions.gd")

var runtime: Node = null


func configure(main_runtime: Node) -> void:
	runtime = main_runtime


func transition_to_room(target_room_name: String, target_portal_id: String) -> void:
	print("Transitioning to room: ", target_room_name, " spawning at portal: ", target_portal_id)

	var room_path := "res://data/rooms/" + target_room_name + ".json"

	if not FileAccess.file_exists(room_path):
		var alternate_path := "res://data/" + target_room_name + ".json"
		if FileAccess.file_exists(alternate_path):
			room_path = alternate_path
		else:
			push_error("Room JSON file not found: " + room_path)
			return

	runtime.clear_spawned_entities()
	runtime.active_player = null
	runtime.sidecar_cache.clear()

	runtime.target_spawn_portal_id = target_portal_id
	runtime.load_level(room_path)


func check_victory_conditions() -> void:
	var result: Dictionary = RUNTIME_VICTORY_CONDITIONS_SCRIPT.should_trigger_victory(runtime.victory_rules, runtime.spawned_entities)
	print("Checking victory conditions... win_cond: ", result.get("win_condition", ""))
	if str(result.get("metric_name", "")) != "":
		print(str(result.get("metric_name", "")), ": ", int(result.get("metric_value", 0)))
	if bool(result.get("should_trigger", false)):
		trigger_victory()


func trigger_victory() -> void:
	if runtime.get_tree().paused:
		return
	print("VICTORY TRIGGERED!")
	runtime.play_sfx("coin")
	runtime._ensure_end_game_overlay_manager()
	if runtime.end_game_overlay_manager != null and is_instance_valid(runtime.end_game_overlay_manager) and runtime.end_game_overlay_manager.has_method("show_victory"):
		runtime.end_game_overlay_manager.show_victory(str(runtime.victory_rules.get("celebration", "confetti")))


func trigger_game_over() -> void:
	if runtime.get_tree().paused:
		return
	print("GAME OVER TRIGGERED!")
	runtime._ensure_end_game_overlay_manager()
	if runtime.end_game_overlay_manager != null and is_instance_valid(runtime.end_game_overlay_manager) and runtime.end_game_overlay_manager.has_method("show_game_over"):
		runtime.end_game_overlay_manager.show_game_over()


func handle_player_death() -> void:
	var action = runtime.loss_rules.get("action", "game_over")
	print("handle_player_death called. loss action rule: ", action, " calm_mode: ", runtime.calm_mode)
	if runtime.calm_mode or action == "respawn":
		if runtime.active_player != null and is_instance_valid(runtime.active_player) and "max_health" in runtime.active_player:
			runtime.active_player.set("current_health", runtime.active_player.get("max_health"))
		respawn_player()
	else:
		trigger_game_over()


func checkpoint_activated(pos: Vector2) -> void:
	runtime.spawn_point = pos
	print("Checkpoint activated at: ", runtime.spawn_point)


func respawn_player() -> void:
	print("Player fell! Respawning at: ", runtime.spawn_point)
	if runtime.active_player != null and is_instance_valid(runtime.active_player):
		runtime._note_player_failure(runtime.active_player.global_position)

	if not runtime.calm_mode and runtime.active_player != null and is_instance_valid(runtime.active_player):
		var lost_coins := int(runtime.score * 0.5)
		var lost_emeralds := 0
		if "emeralds_collected" in runtime.active_player:
			lost_emeralds = runtime.active_player.emeralds_collected
			runtime.active_player.emeralds_collected = 0
		if lost_coins > 0 or lost_emeralds > 0:
			if lost_coins > 0:
				runtime.score -= lost_coins
				runtime._update_hud()
			runtime._spawn_recovery_ghost(runtime.active_player.global_position, lost_coins, lost_emeralds)

	if runtime.camera_autoscroll_enabled and is_instance_valid(runtime.autoscroll_camera_node):
		runtime.autoscroll_camera_node.global_position = runtime.spawn_point

	# Save run recording to static memory if it is long enough
	if runtime.current_run.size() > 20:
		runtime.get_script().run_record = runtime.current_run
	runtime.current_run = []
	runtime.physics_tick_counter = 0

	# Clean up old ghost and spawn a new one
	if is_instance_valid(runtime.ghost_player_node):
		runtime.ghost_player_node.queue_free()
		runtime.ghost_player_node = null

	runtime._spawn_ghost()

	runtime.active_player.global_position = runtime.spawn_point
	if runtime.active_player.has_method("set_velocity"):
		runtime.active_player.set("velocity", Vector2.ZERO)
	elif "velocity" in runtime.active_player:
		runtime.active_player.velocity = Vector2.ZERO


func portal_entered(portal_node: Node2D, portal_data: Dictionary) -> void:
	if runtime.victory_rules.get("win_condition", "all_enemies") == "portal":
		trigger_victory()
		return

	var modifiers: Dictionary = portal_data.get("modifiers", {}) if portal_data.has("modifiers") else {}
	var target_room = str(modifiers.get("target_room", ""))
	var target_portal = str(modifiers.get("target_portal", ""))

	if target_room != "":
		runtime.call_deferred("transition_to_room", target_room, target_portal)


func locked_door_entered(door_node: Node2D, door_data: Dictionary) -> void:
	var key_color := str(door_node.get_meta("key_color", "gold"))
	var count: int = runtime.keys_collected.get(key_color, 0)

	if count <= 0:
		print("Locked door requires a '%s' key!" % key_color)
		# Flash door red to signal locked
		var tween := runtime.create_tween()
		tween.tween_property(door_node, "modulate", Color(2.0, 0.2, 0.2), 0.08)
		tween.tween_property(door_node, "modulate", Color(1, 1, 1), 0.2)
		return

	# Consume the key and unlock
	runtime.keys_collected[key_color] = count - 1
	print("Unlocked door with '%s' key! Remaining: %d" % [key_color, runtime.keys_collected[key_color]])

	# Flash open
	var tween := runtime.create_tween()
	tween.tween_property(door_node, "modulate", Color(0.3, 2.0, 0.3), 0.1)
	tween.tween_property(door_node, "scale", Vector2(0, 1), 0.25).set_ease(Tween.EASE_IN)
	tween.tween_callback(door_node.queue_free)

	# Optionally transition if the door has a target_room modifier
	var modifiers: Dictionary = door_data.get("modifiers", {}) if door_data.has("modifiers") else {}
	var target_room := str(modifiers.get("target_room", ""))
	var target_portal := str(modifiers.get("target_portal", ""))
	if target_room != "":
		runtime.call_deferred("transition_to_room", target_room, target_portal)
