extends Node

const RUNTIME_FRAME_EFFECTS_SCRIPT = preload("res://scripts/RuntimeFrameEffects.gd")

var runtime: Node = null

# Camera & effects state variables
var shake_amplitude: float = 0.0
var shake_duration: float = 0.0
var hit_stop_timer: float = 0.0
var original_time_scale: float = 1.0


func configure(main_runtime: Node) -> void:
	runtime = main_runtime



func find_camera() -> Camera2D:
	var active_player = runtime.get("active_player")
	if active_player != null and is_instance_valid(active_player):
		for child in active_player.get_children():
			if child is Camera2D:
				return child
	return null


func configure_camera_limits() -> void:
	var active_player = runtime.get("active_player")
	if active_player == null:
		return

	var camera := find_camera()
	if camera == null:
		return

	var min_x := 999999.0
	var max_x := -999999.0
	var min_y := 999999.0
	var max_y := -999999.0

	var found_terrain := false
	for child in runtime.get_children():
		if child.name.begins_with("stone_floor") or child.name.begins_with("floor") or child is StaticBody2D:
			var child_node2d := child as Node2D
			if child_node2d != null:
				found_terrain = true
				var pos: Vector2 = child_node2d.global_position
				var size: Vector2 = Vector2(128, 32)

				if child_node2d.has_meta("collision_size"):
					size = child_node2d.get_meta("collision_size")

				min_x = min(min_x, pos.x - size.x * 0.5)
				max_x = max(max_x, pos.x + size.x * 0.5)
				min_y = min(min_y, pos.y - size.y * 0.5)
				max_y = max(max_y, pos.y + size.y * 0.5)

	if not found_terrain:
		min_x = active_player.global_position.x - 1000
		max_x = active_player.global_position.x + 1000
		min_y = active_player.global_position.y - 1000
		max_y = active_player.global_position.y + 1000

	camera.limit_left = int(min_x - 400)
	camera.limit_right = int(max_x + 400)
	camera.limit_top = int(min_y - 600)
	camera.limit_bottom = int(max_y + 400)

	runtime.death_y_threshold = camera.limit_bottom + 100
	print("Camera limits configured: Left=", camera.limit_left, " Right=", camera.limit_right, " Bottom=", camera.limit_bottom, " DeathPlane=", runtime.death_y_threshold)


func attach_camera(target: Node2D) -> void:
	var camera := Camera2D.new()
	if runtime.camera_autoscroll_enabled:
		camera.position_smoothing_enabled = false
		runtime.add_child(camera)
		camera.global_position = target.global_position
		runtime.autoscroll_camera_node = camera
	else:
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 8.0
		target.add_child(camera)

	camera.make_current()
	print("Camera attached. Autoscroll active=", runtime.camera_autoscroll_enabled)


func trigger_screen_shake(amplitude: float, duration: float) -> void:
	shake_amplitude = amplitude
	shake_duration = duration


func trigger_hit_stop(duration: float) -> void:
	if hit_stop_timer <= 0.0:
		original_time_scale = Engine.time_scale
	hit_stop_timer = duration
	Engine.time_scale = 0.02


func update_effects(delta: float) -> void:
	hit_stop_timer = RUNTIME_FRAME_EFFECTS_SCRIPT.update_hit_stop(hit_stop_timer, original_time_scale, delta)
	shake_duration = RUNTIME_FRAME_EFFECTS_SCRIPT.update_screen_shake(find_camera(), shake_duration, shake_amplitude, delta)


func find_active_boss() -> Node2D:
	var spawned_entities: Array = runtime.get("spawned_entities")
	for node in spawned_entities:
		if is_instance_valid(node) and node.get("boss_mode") == true:
			return node
	return null


func play_dramatic_boss_chord() -> void:
	for i in range(3):
		var timer = runtime.get_tree().create_timer(i * 0.15)
		timer.timeout.connect(func():
			runtime.play_sfx("hit")
		)


func trigger_boss_intro(boss: Node2D) -> void:
	runtime.boss_intro_played = true
	runtime.current_boss_node = boss
	print("🚨 BOSS INTRO TRIGGERED FOR: ", boss.name)

	var camera = find_camera()
	if camera == null:
		return

	var active_player = runtime.get("active_player")
	if active_player != null and is_instance_valid(active_player):
		active_player.set_physics_process(false)
		if "velocity" in active_player:
			active_player.velocity = Vector2.ZERO

	var spawned_entities: Array = runtime.get("spawned_entities")
	for entity in spawned_entities:
		if is_instance_valid(entity) and entity != boss:
			entity.set_physics_process(false)
	boss.set_physics_process(false)

	camera.top_level = true
	var orig_zoom = camera.zoom
	var target_pos = boss.global_position

	var tween = runtime.create_tween().set_parallel(true)
	tween.tween_property(camera, "global_position", target_pos, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "zoom", Vector2(1.6, 1.6), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	play_dramatic_boss_chord()
	runtime._show_boss_banner(boss)

	var timer = runtime.get_tree().create_timer(2.2)
	timer.timeout.connect(func():
		var return_tween = runtime.create_tween().set_parallel(true)
		if is_instance_valid(camera) and is_instance_valid(active_player):
			return_tween.tween_property(camera, "global_position", active_player.global_position, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			return_tween.tween_property(camera, "zoom", orig_zoom, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		return_tween.chain().tween_callback(func():
			if is_instance_valid(camera):
				camera.top_level = false
				camera.position = Vector2.ZERO
			if is_instance_valid(active_player):
				active_player.set_physics_process(true)
			for entity in spawned_entities:
				if is_instance_valid(entity):
					entity.set_physics_process(true)
		)
	)
