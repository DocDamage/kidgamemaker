extends Node2D

const DEFAULT_LEVEL_PATH := "res://data/dummy_level.json"
const ASSET_ROOT := "res://data/assets"
const PLAYER_SCRIPT := "res://scripts/PlayerController.gd"
const ENEMY_SCRIPT := "res://scripts/SmartEnemy.gd"
const COLLECTIBLE_SCRIPT := "res://scripts/Collectible.gd"

const CATEGORY_SEARCH_ORDER := [
	"heroes",
	"terrain",
	"enemies",
	"collectibles",
	"backgrounds",
	"portals",
	"decorations",
	"audio"
]

var sidecar_cache: Dictionary = {}
var active_player: Node2D = null
var spawn_point: Vector2 = Vector2.ZERO
var death_y_threshold: float = 2000.0
var spawned_entities: Array = []
var target_spawn_portal_id: String = ""
var found_spawn_portal_pos: Variant = null
var current_weather: String = "clear"
var score: int = 0
var keys_collected: Dictionary = {}  # key_color -> count

# Chiptune synthesizer state
var bpm_sequence: Array = []
var _playback: AudioStreamGeneratorPlayback = null
var current_step_index: int = 0
var step_timer: float = 0.0
var step_duration: float = 0.15
var sample_rate: float = 44100.0


var hud_canvas: CanvasLayer = null
var hud_health_label: Label = null
var hud_score_label: Label = null
var _js_pause_cb: JavaScriptObject
var _js_restart_cb: JavaScriptObject
var _js_mute_cb: JavaScriptObject

static var run_record: Array = []
var current_run: Array = []
var ghost_player_node: Node2D = null
var ghost_playback_index: int = 0
var physics_tick_counter: int = 0
var room_rules: Array = []
var collectibles_collected: int = 0


func _ready() -> void:
	if OS.has_feature("web"):
		var window = JavaScriptBridge.get_interface("window")
		if window != null:
			_js_pause_cb = JavaScriptBridge.create_callback(_on_js_pause)
			_js_restart_cb = JavaScriptBridge.create_callback(_on_js_restart)
			_js_mute_cb = JavaScriptBridge.create_callback(_on_js_mute)
			window.set("godotPauseGame", _js_pause_cb)
			window.set("godotRestartGame", _js_restart_cb)
			window.set("godotMuteGame", _js_mute_cb)

			# Check if window parent already has a muted setting on load
			var initial_mute = JavaScriptBridge.eval("window.parent.currentGameMuted")
			if not initial_mute:
				initial_mute = JavaScriptBridge.eval("window.currentGameMuted")
			if initial_mute:
				AudioServer.set_bus_mute(0, true)

		var json_str = JavaScriptBridge.eval("window.parent.currentGameLevel")
		if not json_str:
			json_str = JavaScriptBridge.eval("window.currentGameLevel")
		if json_str:
			print("Loading level from JS bridge...")
			load_level_from_string(json_str)
			return
	var level_path := _resolve_level_path()
	print("KidGameMaker runner loading level: ", level_path)
	load_level(level_path)


func _on_js_pause(args: Array) -> void:
	var pause_val: bool = args[0] if args.size() > 0 else false
	get_tree().paused = pause_val
	print("Game paused via JS: ", pause_val)


func _on_js_restart(_args: Array) -> void:
	print("Game restarting via JS...")
	if current_run.size() > 20:
		run_record = current_run
	get_tree().reload_current_scene()


func _on_js_mute(args: Array) -> void:
	var mute_val: bool = args[0] if args.size() > 0 else false
	AudioServer.set_bus_mute(0, mute_val)
	print("Game mute state set via JS: ", mute_val)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		print("Reset key pressed. Reloading scene...")
		if current_run.size() > 20:
			run_record = current_run
		get_tree().reload_current_scene()


var _pulse_timer: float = 0.0
func _physics_process(delta: float) -> void:
	if _playback != null and _bgm_player != null and _bgm_player.playing:
		_fill_audio_buffer()

	physics_tick_counter += 1

	if active_player != null and is_instance_valid(active_player):
		if active_player.global_position.y > death_y_threshold:
			_respawn_player()
		elif physics_tick_counter % 3 == 0:
			current_run.append(active_player.global_position)

	if ghost_player_node != null and is_instance_valid(ghost_player_node) and not run_record.is_empty():
		if ghost_playback_index < run_record.size():
			ghost_player_node.global_position = run_record[ghost_playback_index]
			if physics_tick_counter % 3 == 0:
				ghost_playback_index += 1
		else:
			ghost_player_node.queue_free()
			ghost_player_node = null

	# Sound-to-light beat pulse (approx. 120 BPM = 2.0 Hz sine wave)
	_pulse_timer += delta
	var beat_wave := (sin(_pulse_timer * PI * 4.0) + 1.0) * 0.5 # Pulses twice per second
	for child in get_children():
		if child.has_meta("emits_light") and child.get_meta("emits_light") == true:
			var light = child.get_node_or_null("PointLight2D")
			if light != null:
				var base_energy = float(child.get_meta("light_energy"))
				light.energy = base_energy + beat_wave * 0.5


func _resolve_level_path() -> String:
	var args := OS.get_cmdline_args()
	for i in range(args.size()):
		if args[i] == "--level-json" and i + 1 < args.size():
			return args[i + 1]
	return DEFAULT_LEVEL_PATH


func load_level(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_error("Level JSON does not exist: " + file_path)
		return

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Could not open level JSON: " + file_path)
		return

	var json_string := file.get_as_text()
	load_level_from_string(json_string)


func load_level_from_string(json_string: String) -> void:
	var json := JSON.new()
	var error := json.parse(json_string)

	if error != OK:
		push_error("JSON parse error: " + json.get_error_message())
		return

	var level_data: Variant = json.get_data()
	if typeof(level_data) != TYPE_DICTIONARY:
		push_error("Level JSON root must be a Dictionary/Object.")
		return

	var room_id := str(level_data.get("room_id", "unknown_room"))
	print("Loaded room: ", room_id)

	_apply_world_settings(level_data.get("world_settings", {}))

	var entities: Array = level_data.get("entities", [])
	var processed_entities := _merge_terrain_entities(entities)
	
	for entity_data in processed_entities:
		if typeof(entity_data) == TYPE_DICTIONARY:
			spawn_entity(entity_data)

	if target_spawn_portal_id != "" and found_spawn_portal_pos != null and active_player != null:
		active_player.global_position = found_spawn_portal_pos
		spawn_point = found_spawn_portal_pos
		print("Teleported player to target portal: ", target_spawn_portal_id, " at ", found_spawn_portal_pos)

	target_spawn_portal_id = ""
	found_spawn_portal_pos = null

	_apply_weather_particles()
	_configure_camera_limits()
	_create_hud()
	_spawn_ghost()


func _merge_terrain_entities(entities: Array) -> Array:
	var terrain_entities: Array = []
	var other_entities: Array = []

	for ent in entities:
		if typeof(ent) != TYPE_DICTIONARY:
			continue
		var category := str(ent.get("category", ""))
		var type := str(ent.get("type", ""))
		var asset_id := str(ent.get("asset_id", ""))
		var sidecar := _load_sidecar(asset_id, category)
		var runtime_template := str(sidecar.get("runtime_template", type))
		
		if runtime_template == "terrain":
			terrain_entities.append(ent.duplicate(true))
		else:
			other_entities.append(ent)

	var merged_any := true
	while merged_any:
		merged_any = false
		var merged_list: Array = []
		var skip_indices := {}

		for i in range(terrain_entities.size()):
			if skip_indices.has(i):
				continue
			var box_a: Dictionary = terrain_entities[i]
			var pos_a := _read_position(box_a.get("position", {"x": 0, "y": 0}))
			var size_a := _collision_size(_load_sidecar(str(box_a.get("asset_id", "")), str(box_a.get("category", ""))), Vector2(128, 32), box_a)
			
			var left_a := pos_a.x - size_a.x * 0.5
			var right_a := pos_a.x + size_a.x * 0.5
			var top_a := pos_a.y - size_a.y * 0.5
			var bottom_a := pos_a.y + size_a.y * 0.5

			for j in range(i + 1, terrain_entities.size()):
				if skip_indices.has(j):
					continue
				var box_b: Dictionary = terrain_entities[j]
				if box_a.get("asset_id") != box_b.get("asset_id"):
					continue
				
				var pos_b := _read_position(box_b.get("position", {"x": 0, "y": 0}))
				var size_b := _collision_size(_load_sidecar(str(box_b.get("asset_id", "")), str(box_b.get("category", ""))), Vector2(128, 32), box_b)

				var left_b := pos_b.x - size_b.x * 0.5
				var right_b := pos_b.x + size_b.x * 0.5
				var top_b := pos_b.y - size_b.y * 0.5
				var bottom_b := pos_b.y + size_b.y * 0.5

				var same_y: bool = abs(pos_a.y - pos_b.y) < 1.0
				var same_h: bool = abs(size_a.y - size_b.y) < 1.0
				var touches_x: bool = (left_b <= right_a + 2.0 and right_b >= left_a - 2.0)
				
				if same_y and same_h and touches_x:
					var new_left: float = min(left_a, left_b)
					var new_right: float = max(right_a, right_b)
					var new_width: float = new_right - new_left
					var new_center_x: float = new_left + new_width * 0.5
					
					box_a["position"] = {"x": new_center_x, "y": pos_a.y}
					if not box_a.has("modifiers"):
						box_a["modifiers"] = {}
					box_a["modifiers"]["override_size"] = [new_width, size_a.y]
					
					pos_a.x = new_center_x
					size_a.x = new_width
					left_a = new_left
					right_a = new_right

					skip_indices[j] = true
					merged_any = true

			merged_list.append(box_a)
		terrain_entities = merged_list

	return other_entities + terrain_entities


func spawn_entity(data: Dictionary) -> Node2D:
	var asset_id := str(data.get("asset_id", ""))
	if asset_id == "":
		push_warning("Entity missing asset_id.")
		return null

	var sidecar := _load_sidecar(asset_id, str(data.get("category", "")))
	var runtime_template := str(sidecar.get("runtime_template", data.get("type", "decoration")))

	var node: Node2D
	match runtime_template:
		"player":
			node = _make_player(data, sidecar)
		"terrain":
			node = _make_terrain(data, sidecar)
		"enemy":
			node = _make_enemy(data, sidecar)
		"collectible":
			node = _make_collectible(data, sidecar)
		"key_collectible":
			node = _make_key_collectible(data, sidecar)
		"checkpoint":
			node = _make_checkpoint(data, sidecar)
		"portal":
			node = _make_portal(data, sidecar)
		"locked_door":
			node = _make_locked_door(data, sidecar)
		"particles":
			node = _make_particles(data, sidecar)
		"trigger":
			node = _make_trigger(data, sidecar)
		"gate":
			node = _make_gate(data, sidecar)
		"jelly":
			node = _make_jelly(data, sidecar)
		"speed_pad":
			node = _make_speed_pad(data, sidecar)
		"speech_sign":
			node = _make_speech_sign(data, sidecar)
		"water_block":
			node = _make_water_block(data, sidecar)
		"pet":
			node = _make_pet(data, sidecar)
		"crumbling_cloud":
			node = _make_crumbling_cloud(data, sidecar)
		"hazard":
			node = _make_hazard(data, sidecar)
		_:
			node = _make_decoration(data, sidecar)

	node.name = str(data.get("instance_id", asset_id))
	node.global_position = _read_position(data.get("position", {"x": 0, "y": 0}))
	node.z_index = _z_index_for_bucket(_placement_bucket(sidecar))
	node.set_meta("asset_id", asset_id)

	var modifiers: Dictionary = data.get("modifiers", {})
	var scale_multiplier := float(modifiers.get("scale_multiplier", 1.0))
	node.scale = Vector2(scale_multiplier, scale_multiplier)

	add_child(node)
	spawned_entities.append(node)

	if runtime_template == "player":
		spawn_point = node.global_position
		active_player = node
		_attach_camera(node)
	elif runtime_template == "checkpoint":
		if node is Area2D:
			node.body_entered.connect(func(body):
				if body == active_player:
					_on_checkpoint_activated(node.global_position)
			)
	elif runtime_template == "portal":
		if node is Area2D:
			node.body_entered.connect(func(body):
				if body == active_player:
					_on_portal_entered(node, data)
			)
			if str(data.get("instance_id", "")) == target_spawn_portal_id:
				found_spawn_portal_pos = node.global_position
	elif runtime_template == "locked_door":
		if node is Area2D:
			node.body_entered.connect(func(body):
				if body == active_player:
					_on_locked_door_entered(node, data)
			)

	_apply_lighting_if_needed(node, sidecar)
	_apply_audio_if_needed(node, sidecar)

	print("Spawned ", asset_id, " as ", runtime_template, " at ", node.global_position)
	return node


func _make_player(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	var size := _collision_size(sidecar, Vector2(32, 48), data)
	_add_box_collision(body, size)
	_add_visuals(body, sidecar, size, Color(0.2, 0.55, 1.0, 0.9))

	var script := load(PLAYER_SCRIPT)
	if script != null:
		body.set_script(script)
		var attrs: Dictionary = sidecar.get("baseline_attributes", {})
		body.set("max_health", int(attrs.get("max_health", 100)))
		body.set("movement_speed", float(attrs.get("movement_speed", 220)))
		body.set("jump_force", float(attrs.get("jump_force", -460)))
		body.set("gravity_scale", float(attrs.get("gravity_scale", 1.0)))
		body.set("asset_id", str(data.get("asset_id", "")))

	return body


func _make_terrain(data: Dictionary, sidecar: Dictionary) -> CollisionObject2D:
	var modifiers: Dictionary = data.get("modifiers", {})
	var is_moving: bool = bool(modifiers.get("is_moving_platform", false))

	if is_moving:
		var body := AnimatableBody2D.new()
		var size := _collision_size(sidecar, Vector2(128, 32), data)
		_add_box_collision(body, size)
		_add_visuals(body, sidecar, size, Color(0.45, 0.45, 0.45, 1.0))
		
		var axis: String = str(modifiers.get("move_axis", "horizontal"))
		var speed: float = float(modifiers.get("move_speed", 100.0))
		var travel: float = float(modifiers.get("move_travel", 128.0))
		
		var plat_script := GDScript.new()
		plat_script.source_code = "extends AnimatableBody2D\n" + \
			"var axis: String = 'horizontal'\n" + \
			"var speed: float = 100.0\n" + \
			"var travel: float = 128.0\n" + \
			"var start_pos: Vector2\n" + \
			"var time_passed: float = 0.0\n" + \
			"func _ready() -> void:\n" + \
			"\tstart_pos = global_position\n" + \
			"func _physics_process(delta: float) -> void:\n" + \
			"\ttime_passed += delta\n" + \
			"\tvar wave = sin(time_passed * (speed / 50.0))\n" + \
			"\tif axis == 'horizontal':\n" + \
			"\t\tglobal_position.x = start_pos.x + wave * travel * 0.5\n" + \
			"\telse:\n" + \
			"\t\tglobal_position.y = start_pos.y + wave * travel * 0.5\n"
		plat_script.reload()
		body.set_script(plat_script)
		body.set("axis", axis)
		body.set("speed", speed)
		body.set("travel", travel)
		
		return body
	else:
		var is_illusion: bool = bool(modifiers.get("is_illusion", false))
		if is_illusion:
			var body := Area2D.new()
			body.collision_layer = 0
			body.collision_mask = 1
			var size := _collision_size(sidecar, Vector2(128, 32), data)
			_add_box_collision(body, size)
			_add_visuals(body, sidecar, size, Color(0.45, 0.45, 0.45, 1.0))
			
			var illusion_script := GDScript.new()
			illusion_script.source_code = """extends Area2D
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.3, 0.25)
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.25)
"""
			illusion_script.reload()
			body.set_script(illusion_script)
			return body
		else:
			var body := StaticBody2D.new()
			var size := _collision_size(sidecar, Vector2(128, 32), data)
			_add_box_collision(body, size)
			_add_visuals(body, sidecar, size, Color(0.45, 0.45, 0.45, 1.0))
			return body


func _make_enemy(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	var size := _collision_size(sidecar, Vector2(32, 32), data)
	_add_box_collision(body, size)
	_add_visuals(body, sidecar, size, Color(1.0, 0.25, 0.25, 0.9))

	var script := load(ENEMY_SCRIPT)
	if script != null:
		body.set_script(script)
		var attrs: Dictionary = sidecar.get("baseline_attributes", {})
		body.set("patrol_speed", float(attrs.get("movement_speed", 70)))
		body.set("gravity_scale", float(attrs.get("gravity_scale", 1.0)))
		body.set("damage_value", int(attrs.get("damage_value", 10)))
		var max_hp := int(attrs.get("max_health", 20))
		body.set("boss_mode", max_hp > 100)

		# Override baseline with instance modifiers
		var modifiers: Dictionary = data.get("modifiers", {})
		if modifiers.has("patrol_speed"):
			body.set("patrol_speed", float(modifiers.get("patrol_speed")))
		if modifiers.has("damage_value"):
			body.set("damage_value", int(modifiers.get("damage_value")))
		if modifiers.has("boss_mode"):
			body.set("boss_mode", bool(modifiers.get("boss_mode")))
		if modifiers.has("behavior_type"):
			body.set("behavior_type", str(modifiers.get("behavior_type")))
		if modifiers.has("shoot_projectiles"):
			body.set("shoot_projectiles", bool(modifiers.get("shoot_projectiles")))
		if modifiers.has("projectile_speed"):
			body.set("projectile_speed", float(modifiers.get("projectile_speed")))
		if modifiers.has("projectile_interval"):
			body.set("projectile_interval", float(modifiers.get("projectile_interval")))

	return body


func _make_collectible(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(24, 24), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color(1.0, 0.85, 0.15, 0.95))

	var script := load(COLLECTIBLE_SCRIPT)
	if script != null:
		area.set_script(script)
		var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
		area.set("score_value", int(gameplay.get("score_value", 0)))
		area.set("heal_value", int(gameplay.get("heal_value", 0)))
		area.set("asset_id", str(data.get("asset_id", "")))

		# Override baseline with instance modifiers
		var modifiers: Dictionary = data.get("modifiers", {})
		if modifiers.has("score_value"):
			area.set("score_value", int(modifiers.get("score_value")))
		if modifiers.has("heal_value"):
			area.set("heal_value", int(modifiers.get("heal_value")))
		if modifiers.has("powerup_type"):
			area.set("powerup_type", str(modifiers.get("powerup_type")))

	area.set_meta("is_collectible", true)
	return area


func _make_key_collectible(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(20, 20), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color(1.0, 0.85, 0.0, 0.95))
	area.set_meta("is_collectible", true)

	var script := load(COLLECTIBLE_SCRIPT)
	if script != null:
		area.set_script(script)
		var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
		area.set("score_value", 0)
		area.set("heal_value", 0)
		area.set("asset_id", str(data.get("asset_id", "")))
		# Store key_color as metadata so on_collectible_picked_up can read it
		area.set_meta("key_color", str(gameplay.get("key_color", "gold")))

	return area


func _make_checkpoint(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(40, 56), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color(0.3, 1.0, 0.7, 0.8))
	return area


func _make_portal(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(48, 64), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color(0.65, 0.45, 0.2, 0.8))
	return area


func _make_locked_door(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(48, 64), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color(0.8, 0.15, 0.15, 0.9))

	var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
	area.set_meta("requires_key", bool(gameplay.get("requires_key", true)))
	area.set_meta("key_color", str(gameplay.get("key_color", "gold")))

	return area


func _make_particles(data: Dictionary, sidecar: Dictionary) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	var asset_id := str(data.get("asset_id", ""))
	var modifiers: Dictionary = data.get("modifiers", {})

	# Set default values depending on asset_id
	var amount := 20
	var lifetime := 1.0
	var gravity_vec := Vector2(0, -90)
	var velocity_min := 20.0
	var velocity_max := 50.0
	var color_ramp_grad: Gradient = null
	var scale_curve: Curve = null
	var single_color := Color.WHITE
	var has_single_color := false

	match asset_id:
		"effects_fire":
			amount = 35
			lifetime = 0.8
			gravity_vec = Vector2(0, -180)
			velocity_min = 40.0
			velocity_max = 80.0

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 0.2, 0.0, 1.0))
			grad.add_key(0.5, Color(1.0, 0.8, 0.0, 1.0))
			grad.set_color(1, Color(1.0, 0.2, 0.0, 0.0))
			color_ramp_grad = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 6.0))
			curve.add_point(Vector2(1, 1.0))
			scale_curve = curve

		"effects_sparkles":
			amount = 15
			lifetime = 1.2
			gravity_vec = Vector2.ZERO
			velocity_min = 10.0
			velocity_max = 30.0

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 0.9, 0.4, 1.0))
			grad.add_key(0.5, Color(0.4, 0.9, 1.0, 1.0))
			grad.set_color(1, Color(0.4, 0.9, 1.0, 0.0))
			color_ramp_grad = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 0.0))
			curve.add_point(Vector2(0.2, 4.0))
			curve.add_point(Vector2(0.8, 4.0))
			curve.add_point(Vector2(1, 0.0))
			scale_curve = curve

		"effects_snow":
			amount = 25
			lifetime = 2.0
			gravity_vec = Vector2(0, 80)
			velocity_min = 20.0
			velocity_max = 40.0
			single_color = Color(1.0, 1.0, 1.0, 0.9)
			has_single_color = true

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 1.0, 1.0, 0.9))
			grad.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
			color_ramp_grad = grad

		"effects_hearts":
			amount = 10
			lifetime = 1.5
			gravity_vec = Vector2(0, -60)
			velocity_min = 20.0
			velocity_max = 50.0

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 0.4, 0.6, 1.0))
			grad.add_key(0.6, Color(1.0, 0.1, 0.4, 1.0))
			grad.set_color(1, Color(1.0, 0.1, 0.4, 0.0))
			color_ramp_grad = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 1.0))
			curve.add_point(Vector2(0.4, 5.0))
			curve.add_point(Vector2(0.8, 5.0))
			curve.add_point(Vector2(1, 0.0))
			scale_curve = curve

		"effects_smoke":
			amount = 15
			lifetime = 2.0
			gravity_vec = Vector2(10, -50)
			velocity_min = 15.0
			velocity_max = 30.0

			var grad := Gradient.new()
			grad.set_color(0, Color(0.7, 0.7, 0.7, 0.8))
			grad.add_key(0.5, Color(0.8, 0.8, 0.8, 0.4))
			grad.set_color(1, Color(0.9, 0.9, 0.9, 0.0))
			color_ramp_grad = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 3.0))
			curve.add_point(Vector2(0.5, 8.0))
			curve.add_point(Vector2(1, 12.0))
			scale_curve = curve

		_:
			amount = 10
			single_color = Color(1.0, 1.0, 1.0, 1.0)
			has_single_color = true

	# ─── OVERRIDES FROM MODIFIERS ───
	
	# 1. Effect Theme (color palettes override)
	var theme_type = str(modifiers.get("particle_theme", "default"))
	if theme_type != "default" and theme_type != "":
		has_single_color = false
		var new_grad := Gradient.new()
		match theme_type:
			"rainbow":
				new_grad.set_color(0, Color(1.0, 0.0, 0.0, 1.0))      # Red
				new_grad.add_key(0.2, Color(1.0, 1.0, 0.0, 1.0))  # Yellow
				new_grad.add_key(0.4, Color(0.0, 1.0, 0.0, 1.0))  # Green
				new_grad.add_key(0.6, Color(0.0, 1.0, 1.0, 1.0))  # Cyan
				new_grad.add_key(0.8, Color(0.5, 0.0, 1.0, 1.0))  # Purple
				new_grad.set_color(1, Color(1.0, 0.0, 0.0, 0.0))  # Fade out Red
			"neon":
				new_grad.set_color(0, Color(0.0, 1.0, 0.9, 1.0))  # Cyan
				new_grad.add_key(0.5, Color(1.0, 0.0, 0.9, 1.0))  # Magenta
				new_grad.set_color(1, Color(0.0, 1.0, 0.0, 0.0))  # Fade out Green
			"frost":
				new_grad.set_color(0, Color(0.8, 0.95, 1.0, 1.0)) # Icy white
				new_grad.add_key(0.5, Color(0.2, 0.7, 1.0, 1.0))  # Ice blue
				new_grad.set_color(1, Color(0.0, 0.4, 0.8, 0.0))  # Fade out deep blue
			"shadow":
				new_grad.set_color(0, Color(0.4, 0.0, 0.6, 1.0))  # Purple shadow
				new_grad.add_key(0.5, Color(0.1, 0.1, 0.15, 1.0)) # Dark obsidian
				new_grad.set_color(1, Color(0.0, 0.0, 0.0, 0.0))  # Fade out black
		color_ramp_grad = new_grad

	# 2. Flow Speed / Intensity
	var intensity = str(modifiers.get("particle_intensity", "normal"))
	match intensity:
		"calm":
			amount = int(amount * 0.4)
			lifetime = lifetime * 1.5
			velocity_min *= 0.5
			velocity_max *= 0.5
		"normal":
			pass
		"wild":
			amount = int(amount * 2.2)
			lifetime = lifetime * 0.7
			velocity_min *= 1.8
			velocity_max *= 1.8

	# 3. Wind / Gravity Direction
	var direction_type = str(modifiers.get("particle_direction", "default"))
	if direction_type != "default" and direction_type != "":
		var grav_mag = max(abs(gravity_vec.x), abs(gravity_vec.y))
		if grav_mag == 0.0:
			grav_mag = 120.0
		match direction_type:
			"up":
				gravity_vec = Vector2(0, -grav_mag)
			"down":
				gravity_vec = Vector2(0, grav_mag)
			"left":
				gravity_vec = Vector2(-grav_mag, 0)
			"right":
				gravity_vec = Vector2(grav_mag, 0)

	# ─── APPLY FINAL CONFIGURATION ───
	particles.amount = max(2, amount)
	particles.lifetime = lifetime
	particles.gravity = gravity_vec
	particles.initial_velocity_min = velocity_min
	particles.initial_velocity_max = velocity_max

	if color_ramp_grad != null:
		particles.color_ramp = color_ramp_grad
	if scale_curve != null:
		particles.scale_amount_curve = scale_curve
	if has_single_color:
		particles.color = single_color

	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(16, 16)
	particles.randomness = 0.5
	particles.emitting = true

	return particles


func spawn_floating_text(text: String, global_pos: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var settings := LabelSettings.new()
	settings.font_size = 20
	settings.font_color = color
	settings.outline_size = 4
	settings.outline_color = Color.BLACK
	label.label_settings = settings

	label.size = Vector2(100, 30)
	label.position = global_pos - label.size * 0.5
	label.z_index = 200 # draw on top of game objects
	add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50.0, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN)

	label.scale = Vector2(0.5, 0.5)
	label.pivot_offset = label.size * 0.5
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.15)

	tween.chain().tween_callback(label.queue_free)


func _make_decoration(data: Dictionary, sidecar: Dictionary) -> Node2D:
	var node := Node2D.new()
	var size := _collision_size(sidecar, Vector2(48, 48), data)
	_add_visuals(node, sidecar, size, Color(0.65, 0.35, 1.0, 0.75))
	return node


func _read_position(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))

	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0)), float(value.get("y", 0)))

	return Vector2.ZERO


func _load_sidecar(asset_id: String, category_hint: String = "") -> Dictionary:
	if sidecar_cache.has(asset_id):
		return sidecar_cache[asset_id]

	var candidates: Array[String] = []

	# Check flat path first
	candidates.append("%s/%s.json" % [ASSET_ROOT, asset_id])

	if category_hint != "":
		candidates.append("%s/%s/%s/%s.json" % [ASSET_ROOT, category_hint, asset_id, asset_id])

	for category in CATEGORY_SEARCH_ORDER:
		candidates.append("%s/%s/%s/%s.json" % [ASSET_ROOT, category, asset_id, asset_id])

	for path in candidates:
		if FileAccess.file_exists(path):
			var file := FileAccess.open(path, FileAccess.READ)
			var json := JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var parsed: Variant = json.get_data()
				if typeof(parsed) == TYPE_DICTIONARY:
					parsed["sidecar_path"] = path
					sidecar_cache[asset_id] = parsed
					return parsed

	push_warning("No sidecar found for asset_id: " + asset_id + ". Using defaults.")
	var fallback := {
		"asset_id": asset_id,
		"asset_name": asset_id,
		"runtime_template": "decoration",
		"placement_logic": {"parallax_bucket": "play_layer"},
		"collision": {"size": [48, 48]},
		"sidecar_path": ""
	}
	sidecar_cache[asset_id] = fallback
	return fallback


func _collision_size(sidecar: Dictionary, fallback: Vector2, entity_data: Dictionary = {}) -> Vector2:
	var modifiers: Dictionary = entity_data.get("modifiers", {}) if entity_data.has("modifiers") else {}
	if modifiers.has("override_size"):
		var override_size: Variant = modifiers.get("override_size")
		if typeof(override_size) == TYPE_ARRAY and override_size.size() >= 2:
			return Vector2(float(override_size[0]), float(override_size[1]))

	var collision: Dictionary = sidecar.get("collision", {})
	var size_value: Variant = collision.get("size", [fallback.x, fallback.y])
	if typeof(size_value) == TYPE_ARRAY and size_value.size() >= 2:
		return Vector2(float(size_value[0]), float(size_value[1]))
	return fallback


func _add_box_collision(parent: Node, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	parent.add_child(collision)


func _add_placeholder_polygon(parent: Node2D, size: Vector2, color: Color) -> void:
	var half := size * 0.5
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y)
	])
	poly.color = color
	parent.add_child(poly)


func _add_visuals(parent: Node2D, sidecar: Dictionary, size: Vector2, default_color: Color) -> void:
	var visual: String = str(sidecar.get("visual", ""))
	
	var is_image := false
	var ext := visual.get_extension().to_lower()
	if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "svg" or ext == "webp":
		is_image = true
		
	var texture: Texture2D = null
	if is_image:
		texture = _load_texture_dynamic(visual, str(sidecar.get("sidecar_path", "")))
		
	if texture != null:
		var runtime_template := str(sidecar.get("runtime_template", ""))
		var is_spritesheet: bool = bool(sidecar.get("is_spritesheet", false))
		var frames: Array = sidecar.get("frames", [])
		
		if is_spritesheet and frames.size() > 0 and (runtime_template == "player" or runtime_template == "enemy"):
			var animated_sprite := AnimatedSprite2D.new()
			var sprite_frames := SpriteFrames.new()
			if not sprite_frames.has_animation("default"):
				sprite_frames.add_animation("default")
			sprite_frames.set_animation_speed("default", 8.0)
			sprite_frames.set_animation_loop("default", true)
			
			for f in frames:
				if typeof(f) == TYPE_DICTIONARY:
					var frame_rect = Rect2(float(f.get("x", 0)), float(f.get("y", 0)), float(f.get("w", 0)), float(f.get("h", 0)))
					var atlas_tex := AtlasTexture.new()
					atlas_tex.atlas = texture
					atlas_tex.region = frame_rect
					sprite_frames.add_frame("default", atlas_tex)
					
			animated_sprite.sprite_frames = sprite_frames
			parent.add_child(animated_sprite)
			
			var first_frame_dict: Dictionary = frames[0]
			var f_size = Vector2(float(first_frame_dict.get("w", size.x)), float(first_frame_dict.get("h", size.y)))
			if f_size.x > 0 and f_size.y > 0:
				animated_sprite.scale = size / f_size
				
			animated_sprite.play("default")
			parent.set_meta("collision_size", size)
			
		elif is_spritesheet and frames.size() > 0:
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.region_enabled = true
			
			var f: Dictionary = frames[0]
			var frame_rect = Rect2(float(f.get("x", 0)), float(f.get("y", 0)), float(f.get("w", 0)), float(f.get("h", 0)))
			sprite.region_rect = frame_rect
			
			parent.add_child(sprite)
			
			if frame_rect.size.x > 0 and frame_rect.size.y > 0:
				sprite.scale = size / frame_rect.size
				
			parent.set_meta("collision_size", size)
			
		else:
			var sprite := Sprite2D.new()
			sprite.texture = texture
			parent.set_meta("collision_size", size)
			
			if runtime_template == "terrain":
				sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
				sprite.region_enabled = true
				sprite.region_rect = Rect2(Vector2.ZERO, size)
			else:
				var tex_size := texture.get_size()
				if tex_size.x > 0 and tex_size.y > 0:
					sprite.scale = size / tex_size
					
			parent.add_child(sprite)
	else:
		_add_placeholder_polygon(parent, size, default_color)
		if visual != "":
			var label := Label.new()
			label.text = visual
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			
			var settings := LabelSettings.new()
			settings.font_size = 24
			settings.font_color = Color.WHITE
			settings.outline_size = 4
			settings.outline_color = Color.BLACK
			label.label_settings = settings
			
			label.size = size
			label.position = -size * 0.5
			parent.add_child(label)


func _load_texture_dynamic(path: String, sidecar_file_path: String) -> Texture2D:
	var resolved_path := path
	
	if not path.begins_with("res://") and not path.begins_with("user://") and not path.is_absolute_path():
		if sidecar_file_path != "":
			var base_dir := sidecar_file_path.get_base_dir()
			resolved_path = base_dir.path_join(path)
		else:
			resolved_path = ASSET_ROOT.path_join(path)
			
	if resolved_path.begins_with("file://"):
		resolved_path = resolved_path.replace("file://", "")
		if OS.get_name() == "Windows" and resolved_path.begins_with("/"):
			resolved_path = resolved_path.substr(1)

	if resolved_path.begins_with("res://") and ResourceLoader.exists(resolved_path):
		var tex := load(resolved_path) as Texture2D
		if tex != null:
			return tex

	var final_fs_path := ProjectSettings.globalize_path(resolved_path)
	if FileAccess.file_exists(final_fs_path):
		var img := Image.load_from_file(final_fs_path)
		if img != null:
			return ImageTexture.create_from_image(img)
			
	print("Failed to load texture at path: ", resolved_path, " (FS path: ", final_fs_path, ")")
	return null


func _on_checkpoint_activated(pos: Vector2) -> void:
	spawn_point = pos
	print("Checkpoint activated at: ", spawn_point)


func _respawn_player() -> void:
	print("Player fell! Respawning at: ", spawn_point)
	
	# Save run recording to static memory if it is long enough
	if current_run.size() > 20:
		run_record = current_run
	current_run = []
	physics_tick_counter = 0
	
	# Clean up old ghost and spawn a new one
	if is_instance_valid(ghost_player_node):
		ghost_player_node.queue_free()
		ghost_player_node = null
	
	_spawn_ghost()
	
	active_player.global_position = spawn_point
	if active_player.has_method("set_velocity"):
		active_player.set("velocity", Vector2.ZERO)
	elif "velocity" in active_player:
		active_player.velocity = Vector2.ZERO


func _spawn_ghost() -> void:
	if run_record.is_empty():
		return
	if active_player == null or not is_instance_valid(active_player):
		return
	
	var p_asset_id = active_player.get("asset_id")
	if p_asset_id == "":
		p_asset_id = "hero_knight" # default fallback
		
	var sidecar = _load_sidecar(p_asset_id, "heroes")
	var size = _collision_size(sidecar, Vector2(32, 48))
	
	var ghost := Node2D.new()
	ghost.name = "GhostPlayer"
	_add_visuals(ghost, sidecar, size, Color(0.2, 0.55, 1.0, 0.45))
	ghost.modulate.a = 0.45
	
	ghost.global_position = run_record[0]
	add_child(ghost)
	ghost_player_node = ghost
	ghost_playback_index = 0
	print("Spawned ghost player at: ", ghost.global_position)


func notify_trigger(trigger_id: String) -> void:
	var trigger_node = get_node_or_null(trigger_id)
	var trigger_type := "button_step"
	if trigger_node != null:
		var asset_id = ""
		if trigger_node.has_meta("asset_id"):
			asset_id = str(trigger_node.get_meta("asset_id"))
		elif "asset_id" in trigger_node:
			asset_id = str(trigger_node.get("asset_id"))
		
		if asset_id == "trigger_lever":
			trigger_type = "lever_flip"
			
	print("notify_trigger called for: ", trigger_id, " type: ", trigger_type)
	execute_rules(trigger_type, trigger_id)


func execute_rules(trigger_type: String, trigger_id: String = "") -> void:
	for rule in room_rules:
		if typeof(rule) != TYPE_DICTIONARY:
			continue
		
		var rule_trigger_type = str(rule.get("trigger_type", ""))
		var rule_trigger_id = str(rule.get("trigger_id", ""))
		
		# Match trigger type (button_step, lever_flip, coins_5, coins_10)
		if rule_trigger_type != trigger_type:
			continue
			
		# Match trigger ID if button or lever
		if (rule_trigger_type == "button_step" or rule_trigger_type == "lever_flip") and rule_trigger_id != trigger_id:
			continue
			
		var action_type = str(rule.get("action_type", ""))
		var action_id = str(rule.get("action_id", ""))
		
		print("Rule matched! Trigger: ", trigger_type, " Action: ", action_type, " Target: ", action_id)
		
		match action_type:
			"toggle_gate":
				if action_id != "":
					# Look for the gate in the scene
					var gate_node = get_node_or_null(action_id)
					if gate_node != null and gate_node.has_method("toggle_gate"):
						gate_node.toggle_gate()
					else:
						# Try spawned_entities list
						for ent in spawned_entities:
							if is_instance_valid(ent) and ent.name == action_id and ent.has_method("toggle_gate"):
								ent.toggle_gate()
								break
			"spawn_sparkles":
				if active_player != null and is_instance_valid(active_player):
					var particles_data = {
						"asset_id": "effects_sparkles",
						"category": "particles",
						"position": {"x": active_player.global_position.x, "y": active_player.global_position.y},
						"modifiers": {"particle_theme": "rainbow", "particle_intensity": "wild"}
					}
					var p_node = spawn_entity(particles_data)
					if p_node != null:
						var t = create_tween()
						t.tween_interval(1.5)
						t.tween_callback(p_node.queue_free)
			"heal_player":
				if active_player != null and is_instance_valid(active_player) and active_player.has_method("heal"):
					active_player.heal(20)
			"play_sfx_chime":
				play_sfx("coin")


func _on_portal_entered(_portal_node: Node2D, portal_data: Dictionary) -> void:
	var modifiers: Dictionary = portal_data.get("modifiers", {}) if portal_data.has("modifiers") else {}
	var target_room = str(modifiers.get("target_room", ""))
	var target_portal = str(modifiers.get("target_portal", ""))
	
	if target_room != "":
		call_deferred("transition_to_room", target_room, target_portal)


func _on_locked_door_entered(door_node: Node2D, door_data: Dictionary) -> void:
	var key_color := str(door_node.get_meta("key_color", "gold"))
	var count: int = keys_collected.get(key_color, 0)

	if count <= 0:
		print("Locked door requires a '%s' key!" % key_color)
		# Flash door red to signal locked
		var tween := create_tween()
		tween.tween_property(door_node, "modulate", Color(2.0, 0.2, 0.2), 0.08)
		tween.tween_property(door_node, "modulate", Color(1, 1, 1), 0.2)
		return

	# Consume the key and unlock
	keys_collected[key_color] = count - 1
	print("Unlocked door with '%s' key! Remaining: %d" % [key_color, keys_collected[key_color]])

	# Flash open
	var tween := create_tween()
	tween.tween_property(door_node, "modulate", Color(0.3, 2.0, 0.3), 0.1)
	tween.tween_property(door_node, "scale", Vector2(0, 1), 0.25).set_ease(Tween.EASE_IN)
	tween.tween_callback(door_node.queue_free)

	# Optionally transition if the door has a target_room modifier
	var modifiers: Dictionary = door_data.get("modifiers", {}) if door_data.has("modifiers") else {}
	var target_room := str(modifiers.get("target_room", ""))
	var target_portal := str(modifiers.get("target_portal", ""))
	if target_room != "":
		call_deferred("transition_to_room", target_room, target_portal)



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
			
	clear_spawned_entities()
	active_player = null
	sidecar_cache.clear()
	
	target_spawn_portal_id = target_portal_id
	load_level(room_path)


func clear_spawned_entities() -> void:
	for node in spawned_entities:
		if is_instance_valid(node):
			node.queue_free()
	spawned_entities.clear()
	# Free the HUD canvas explicitly so it is not left on screen if load_level
	# returns early (before _create_hud() is called on the new room).
	if hud_canvas != null and is_instance_valid(hud_canvas):
		hud_canvas.queue_free()
		hud_canvas = null
	hud_health_label = null
	hud_score_label = null


func on_collectible_picked_up(payload: Dictionary) -> void:
	score += int(payload.get("score_value", 0))
	if int(payload.get("score_value", 0)) > 0:
		print("Score: ", score, "  (+", payload.get("score_value", 0), ")")

	# Rule checking for ruby collectibles count
	var asset_id_val_temp := str(payload.get("asset_id", ""))
	if not asset_id_val_temp.contains("key"):
		collectibles_collected += 1
		if collectibles_collected == 5:
			execute_rules("coins_5")
		elif collectibles_collected == 10:
			execute_rules("coins_10")

	# Key pickup — find the node that emitted it to read key_color
	var asset_id_val := str(payload.get("asset_id", ""))
	if asset_id_val.contains("key"):
		var key_color := "gold"
		# Try to find node by asset_id to get stored key_color metadata
		for node in spawned_entities:
			if is_instance_valid(node) and node.has_meta("key_color"):
				key_color = str(node.get_meta("key_color"))
				break
		keys_collected[key_color] = keys_collected.get(key_color, 0) + 1
		print("Key collected! %s keys of color '%s'" % [keys_collected[key_color], key_color])


func _configure_camera_limits() -> void:
	if active_player == null:
		return
		
	var camera: Camera2D = null
	for child in active_player.get_children():
		if child is Camera2D:
			camera = child
			break
			
	if camera == null:
		return

	var min_x := 999999.0
	var max_x := -999999.0
	var min_y := 999999.0
	var max_y := -999999.0
	
	var found_terrain := false
	for child in get_children():
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
	
	death_y_threshold = camera.limit_bottom + 100
	print("Camera limits configured: Left=", camera.limit_left, " Right=", camera.limit_right, " Bottom=", camera.limit_bottom, " DeathPlane=", death_y_threshold)


func _attach_camera(target: Node2D) -> void:
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	target.add_child(camera)
	camera.make_current()
	print("Camera attached to: ", target.name)


func _placement_bucket(sidecar: Dictionary) -> String:
	var placement: Dictionary = sidecar.get("placement_logic", {})
	return str(placement.get("parallax_bucket", "play_layer"))


func _z_index_for_bucket(bucket: String) -> int:
	match bucket:
		"deep_background":
			return -300
		"midground":
			return -100
		"play_layer":
			return 0
		"foreground":
			return 100
		_:
			return 0


func _apply_world_settings(settings: Dictionary) -> void:
	var time_of_day := str(settings.get("time_of_day", "day"))
	current_weather = str(settings.get("weather", "clear"))
	print("World settings: time=", time_of_day, " weather=", current_weather)

	var modulate_node := CanvasModulate.new()
	modulate_node.name = "CanvasModulateDayNight"
	add_child(modulate_node)
	spawned_entities.append(modulate_node)

	match time_of_day:
		"night":
			modulate_node.color = Color(0.12, 0.12, 0.28)
		"sunset":
			modulate_node.color = Color(0.85, 0.58, 0.45)
		"morning":
			modulate_node.color = Color(0.88, 0.94, 1.0)
		"day":
			modulate_node.color = Color.WHITE
		_:
			modulate_node.color = Color.WHITE

	bpm_sequence = settings.get("custom_bgm_sequence", [])
	room_rules = settings.get("room_rules", [])
	var theme := str(settings.get("theme", "default"))
	_play_theme_bgm(theme)


func _apply_lighting_if_needed(node: Node2D, sidecar: Dictionary) -> void:
	var lighting: Dictionary = sidecar.get("lighting_logic", {})
	if not bool(lighting.get("emits_light", false)):
		return

	var light := PointLight2D.new()
	light.color = Color(str(lighting.get("light_color", "#ffae34")))
	light.energy = float(lighting.get("light_energy", 1.2))
	light.texture_scale = float(lighting.get("light_radius", 150.0)) / 128.0

	# Programmatically create a radial GradientTexture2D so PointLight2D functions correctly in Godot 4
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE, Color(1.0, 1.0, 1.0, 0.0)])

	var grad_tex := GradientTexture2D.new()
	grad_tex.gradient = gradient
	grad_tex.fill = GradientTexture2D.FILL_RADIAL
	grad_tex.fill_from = Vector2(0.5, 0.5)
	grad_tex.fill_to = Vector2(1.0, 0.5)
	grad_tex.width = 128
	grad_tex.height = 128

	light.texture = grad_tex
	node.add_child(light)
	node.set_meta("emits_light", true)
	node.set_meta("light_energy", light.energy)


func _apply_weather_particles() -> void:
	if current_weather == "clear" or current_weather == "":
		return

	var particles := CPUParticles2D.new()
	particles.name = "WeatherParticles"
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(1000, 10)
	particles.amount = 150
	particles.lifetime = 3.0
	particles.preprocess = 3.0

	match current_weather:
		"rain":
			particles.color = Color(0.6, 0.7, 0.9, 0.55)
			particles.direction = Vector2(0.1, 1.0)
			particles.spread = 4.0
			particles.gravity = Vector2(50, 700)
			particles.initial_velocity_min = 350.0
			particles.initial_velocity_max = 500.0
		"snow":
			particles.color = Color(0.9, 0.95, 1.0, 0.8)
			particles.direction = Vector2(0.0, 1.0)
			particles.spread = 15.0
			particles.gravity = Vector2(0, 80)
			particles.initial_velocity_min = 40.0
			particles.initial_velocity_max = 80.0
			particles.tangential_accel_min = -10.0
			particles.tangential_accel_max = 10.0
			particles.scale_amount_min = 2.0
			particles.scale_amount_max = 5.0

	if active_player != null:
		particles.position = Vector2(0, -400)
		active_player.add_child(particles)
	else:
		particles.position = Vector2(500, 0)
		add_child(particles)
		spawned_entities.append(particles)


func _apply_audio_if_needed(node: Node2D, sidecar: Dictionary) -> void:
	var audio: Dictionary = sidecar.get("audio_logic", {})
	var stream_file := str(audio.get("stream_file", ""))
	if stream_file == "":
		return

	var sidecar_path := str(sidecar.get("sidecar_path", ""))
	var resolved_audio_path := stream_file
	if not stream_file.begins_with("res://") and not stream_file.begins_with("user://") and not stream_file.is_absolute_path():
		if sidecar_path != "":
			resolved_audio_path = sidecar_path.get_base_dir().path_join(stream_file)
		else:
			resolved_audio_path = ASSET_ROOT.path_join(stream_file)

	var fs_path := ProjectSettings.globalize_path(resolved_audio_path)
	if FileAccess.file_exists(fs_path):
		var stream := AudioStreamOggVorbis.load_from_file(fs_path)
		if stream == null:
			stream = load(resolved_audio_path)

		if stream != null:
			var loop := bool(audio.get("loop", true))
			if stream is AudioStreamOggVorbis:
				stream.loop = loop

			var is_global := bool(audio.get("global_bgm", true))
			if is_global:
				var player := AudioStreamPlayer.new()
				player.stream = stream
				player.volume_db = float(audio.get("volume_db", 0.0))
				player.autoplay = true
				node.add_child(player)
				print("Global BGM spawned for ", node.name, " playing ", resolved_audio_path)
			else:
				var player := AudioStreamPlayer2D.new()
				player.stream = stream
				player.volume_db = float(audio.get("volume_db", 0.0))
				player.autoplay = true
				player.max_distance = float(audio.get("max_distance", 500.0))
				node.add_child(player)
				print("Spatial SFX spawned for ", node.name, " playing ", resolved_audio_path)


func _process(_delta: float) -> void:
	_update_hud()


func _create_hud() -> void:
	if hud_canvas != null and is_instance_valid(hud_canvas):
		hud_canvas.queue_free()

	hud_canvas = CanvasLayer.new()
	hud_canvas.layer = 100
	add_child(hud_canvas)

	var control := Control.new()
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_canvas.add_child(control)

	hud_health_label = Label.new()
	hud_health_label.position = Vector2(24, 24)
	var health_settings := LabelSettings.new()
	health_settings.font_size = 28
	health_settings.outline_size = 6
	health_settings.outline_color = Color.BLACK
	hud_health_label.label_settings = health_settings
	control.add_child(hud_health_label)

	hud_score_label = Label.new()
	hud_score_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_score_label.anchor_left = 1.0
	hud_score_label.anchor_right = 1.0
	hud_score_label.offset_left = -250
	hud_score_label.offset_top = 24
	var score_settings := LabelSettings.new()
	score_settings.font_size = 28
	score_settings.outline_size = 6
	score_settings.outline_color = Color.BLACK
	hud_score_label.label_settings = score_settings
	control.add_child(hud_score_label)


func _update_hud() -> void:
	if hud_health_label == null or not is_instance_valid(hud_health_label):
		return
	if hud_score_label == null or not is_instance_valid(hud_score_label):
		return

	if active_player != null and is_instance_valid(active_player):
		var hp: int = active_player.get("current_health") if "current_health" in active_player else 100
		var max_hp: int = active_player.get("max_health") if "max_health" in active_player else 100
		
		var total_hearts := 5
		var hp_per_heart := float(max_hp) / float(total_hearts)
		var hearts_str := ""
		
		for i in range(total_hearts):
			var threshold := (i + 1) * hp_per_heart
			if float(hp) >= threshold:
				hearts_str += "❤️"
			elif float(hp) >= threshold - (hp_per_heart * 0.5):
				hearts_str += "💔"
			else:
				hearts_str += "🖤"
				
		hud_health_label.text = "HP: " + hearts_str
	else:
		hud_health_label.text = ""

	hud_score_label.text = "⭐ " + str(score)
	if active_player != null and is_instance_valid(active_player):
		if active_player.get("has_jetpack") == true:
			var fuel = active_player.get("jetpack_fuel")
			hud_score_label.text = "🚀 " + str(int(fuel)) + "% | " + hud_score_label.text


var _bgm_player: AudioStreamPlayer = null
var _sfx_cache: Dictionary = {}

func _play_theme_bgm(theme: String) -> void:
	if _bgm_player != null and is_instance_valid(_bgm_player):
		_bgm_player.stop()
		_bgm_player.queue_free()
		_bgm_player = null

	var bgm_path := ""
	match theme:
		"space":
			bgm_path = "res://data/assets/audio/space_bgm.wav"
		"candy":
			bgm_path = "res://data/assets/audio/candy_bgm.wav"
		"jungle":
			bgm_path = "res://data/assets/audio/jungle_bgm.wav"
		"ice":
			bgm_path = "res://data/assets/audio/ice_bgm.wav"
		"volcano":
			bgm_path = "res://data/assets/audio/volcano_bgm.wav"
		"custom":
			var generator := AudioStreamGenerator.new()
			generator.mix_rate = sample_rate
			generator.buffer_length = 0.1
			_bgm_player = AudioStreamPlayer.new()
			_bgm_player.stream = generator
			_bgm_player.volume_db = -10.0
			add_child(_bgm_player)
			_bgm_player.play()
			_playback = _bgm_player.get_stream_playback()
			print("Playing custom synthesized beat composer sequence")
			return

	if bgm_path != "":
		var stream = _load_wav_file(bgm_path)
		if stream != null:
			stream.loop = true
			_bgm_player = AudioStreamPlayer.new()
			_bgm_player.stream = stream
			_bgm_player.volume_db = -10.0 # BGM should be quiet
			add_child(_bgm_player)
			_bgm_player.play()
			print("Playing BGM theme: ", theme)


func _fill_audio_buffer() -> void:
	if _playback == null:
		return

	var frames_to_fill := _playback.get_frames_available()
	if frames_to_fill <= 0:
		return

	var buffer := PackedVector2Array()
	buffer.resize(frames_to_fill)

	for i in range(frames_to_fill):
		step_timer += 1.0 / sample_rate
		if step_timer >= step_duration:
			step_timer = 0.0
			current_step_index = (current_step_index + 1) % 8

		var sample_val := 0.0

		if bpm_sequence.size() >= 4:
			# Kick (row 0)
			if int(bpm_sequence[0][current_step_index]) == 1:
				var t := step_timer
				if t < 0.1:
					var freq := lerp(150.0, 40.0, t / 0.1)
					var env := (1.0 - t / 0.1)
					sample_val += sin(t * TAU * freq) * 0.3 * env

			# Snare (row 1)
			if int(bpm_sequence[1][current_step_index]) == 1:
				var t := step_timer
				if t < 0.12:
					var noise_val := (randf() * 2.0 - 1.0)
					var env := (1.0 - t / 0.12)
					sample_val += noise_val * 0.15 * env

			# Hi-Hat (row 2)
			if int(bpm_sequence[2][current_step_index]) == 1:
				var t := step_timer
				if t < 0.04:
					var noise_val := (randf() * 2.0 - 1.0)
					var env := (1.0 - t / 0.04)
					sample_val += noise_val * 0.05 * env

			# Bass Synth (row 3)
			if int(bpm_sequence[3][current_step_index]) == 1:
				var notes := [130.81, 155.56, 196.00, 233.08, 261.63, 196.00, 155.56, 130.81]
				var freq := notes[current_step_index % notes.size()]
				var t := step_timer
				if t < 0.15:
					var wave_val := 1.0 if sin(t * TAU * freq) > 0.0 else -1.0
					var env := (1.0 - t / 0.15)
					sample_val += wave_val * 0.1 * env

		sample_val = clamp(sample_val, -1.0, 1.0)
		buffer[i] = Vector2(sample_val, sample_val)

	_playback.push_many(buffer)


func play_sfx(type: String) -> void:
	var sound_path := ""
	match type:
		"coin":
			sound_path = "res://data/assets/audio/coin.wav"
		"jump":
			sound_path = "res://data/assets/audio/jump.wav"
		"hit":
			sound_path = "res://data/assets/audio/hit.wav"

	if sound_path == "":
		return

	var stream: AudioStreamWav = null
	if _sfx_cache.has(type):
		stream = _sfx_cache[type]
	else:
		stream = _load_wav_file(sound_path)
		if stream != null:
			_sfx_cache[type] = stream

	if stream != null:
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = -5.0 # slightly quieter for kid ears
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)


func play_custom_sfx(asset_id: String, default_type: String = "") -> void:
	if asset_id == "":
		if default_type != "":
			play_sfx(default_type)
		return

	if _sfx_cache.has(asset_id + "_custom"):
		var stream = _sfx_cache[asset_id + "_custom"]
		if stream != null:
			var player := AudioStreamPlayer.new()
			player.stream = stream
			player.volume_db = -5.0
			add_child(player)
			player.play()
			player.finished.connect(player.queue_free)
			return

	var sidecar = _load_sidecar(asset_id)
	var audio_logic = sidecar.get("audio_logic", {})
	var stream_file = str(audio_logic.get("stream_file", ""))
	
	if stream_file != "":
		var sidecar_path = str(sidecar.get("sidecar_path", ""))
		var resolved_audio_path = stream_file
		if sidecar_path != "":
			resolved_audio_path = sidecar_path.get_base_dir().path_join(stream_file)
		else:
			resolved_audio_path = ASSET_ROOT.path_join(stream_file)
		
		var stream = _load_wav_file(resolved_audio_path)
		if stream != null:
			_sfx_cache[asset_id + "_custom"] = stream
			var player := AudioStreamPlayer.new()
			player.stream = stream
			player.volume_db = -5.0
			add_child(player)
			player.play()
			player.finished.connect(player.queue_free)
			return

	if default_type != "":
		play_sfx(default_type)


func _load_wav_file(path: String) -> AudioStreamWav:
	var resolved_path := path
	if resolved_path.begins_with("file://"):
		resolved_path = resolved_path.replace("file://", "")
		if OS.get_name() == "Windows" and resolved_path.begins_with("/"):
			resolved_path = resolved_path.substr(1)

	var final_fs_path := ProjectSettings.globalize_path(resolved_path)
	if not FileAccess.file_exists(final_fs_path):
		# Fallback: check relative to engine directory
		var exe_dir = OS.get_executable_path().get_base_dir()
		var alt_path = exe_dir.path_join(path.replace("res://", ""))
		if FileAccess.file_exists(alt_path):
			final_fs_path = alt_path
		else:
			print("SFX file not found: ", final_fs_path)
			return null

	var file = FileAccess.open(final_fs_path, FileAccess.READ)
	if file == null:
		return null
	var bytes = file.get_buffer(file.get_length())
	if bytes.size() < 44:
		return null

	var stream = AudioStreamWav.new()
	stream.format = AudioStreamWav.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	stream.data = bytes.slice(44)
	return stream


func _make_trigger(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(32, 32), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color(1.0, 0.6, 0.2, 0.8))

	var modifiers: Dictionary = data.get("modifiers", {})
	var target_id: String = str(modifiers.get("target_id", ""))

	var trigger_script := GDScript.new()
	trigger_script.source_code = "extends Area2D\n" + \
		"var target_id: String = ''\n" + \
		"var triggered: bool = false\n" + \
		"func _ready() -> void:\n" + \
		"\tbody_entered.connect(_on_body_entered)\n" + \
		"func _on_body_entered(body: Node) -> void:\n" + \
		"\tif triggered or not body is CharacterBody2D:\n" + \
		"\t\treturn\n" + \
		"\ttriggered = true\n" + \
		"\tvar main = get_tree().get_root().get_node_or_null('Main')\n" + \
		"\tif main != null and main.has_method('play_sfx'):\n" + \
		"\t\tmain.play_sfx('coin')\n" + \
		"\tif main != null and main.has_method('notify_trigger'):\n" + \
		"\t\tmain.notify_trigger(name)\n" + \
		"\tvar target = get_parent().get_node_or_null(target_id)\n" + \
		"\tif target != null and target.has_method('toggle_gate'):\n" + \
		"\t\ttarget.toggle_gate()\n"
	trigger_script.reload()
	area.set_script(trigger_script)
	area.set("target_id", target_id)

	return area


func _make_gate(data: Dictionary, sidecar: Dictionary) -> AnimatableBody2D:
	var body := AnimatableBody2D.new()
	var size := _collision_size(sidecar, Vector2(48, 48), data)
	_add_box_collision(body, size)
	_add_visuals(body, sidecar, size, Color(0.1, 0.8, 0.5, 0.95))

	var gate_script := GDScript.new()
	gate_script.source_code = "extends AnimatableBody2D\n" + \
		"var is_open: bool = false\n" + \
		"func toggle_gate() -> void:\n" + \
		"\tis_open = !is_open\n" + \
		"\tvar main = get_tree().get_root().get_node_or_null('Main')\n" + \
		"\tif is_open:\n" + \
		"\t\tcollision_layer = 0\n" + \
		"\t\tcollision_mask = 0\n" + \
		"\t\tvar tween = create_tween()\n" + \
		"\t\ttween.tween_property(self, 'modulate:a', 0.15, 0.3)\n" + \
		"\t\tif main != null and main.has_method('spawn_floating_text'):\n" + \
		"\t\t\tmain.spawn_floating_text('GATE OPENED!', global_position, Color.GREEN)\n" + \
		"\telse:\n" + \
		"\t\tcollision_layer = 1\n" + \
		"\t\tcollision_mask = 1\n" + \
		"\t\tvar tween = create_tween()\n" + \
		"\t\ttween.tween_property(self, 'modulate:a', 1.0, 0.3)\n" + \
		"\t\tif main != null and main.has_method('spawn_floating_text'):\n" + \
		"\t\t\tmain.spawn_floating_text('GATE CLOSED!', global_position, Color.RED)\n"
	gate_script.reload()
	body.set_script(gate_script)

	return body


func _make_jelly(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(48, 48), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color.YELLOW)

	var jelly_script := GDScript.new()
	jelly_script.source_code = """extends Area2D
var bounce_force: float = 500.0
var scale_multiplier: float = 1.0
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage") and body is CharacterBody2D:
		body.velocity.y = -bounce_force
		var main = get_tree().get_root().get_node_or_null("Main")
		if main != null:
			if main.has_method("play_sfx"): main.play_sfx("jump")
			if main.has_method("spawn_floating_text"):
				main.spawn_floating_text("BOING!", global_position, Color.YELLOW)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.3 * scale_multiplier, 0.6 * scale_multiplier), 0.08)
		tween.tween_property(self, "scale", Vector2(1.0 * scale_multiplier, 1.0 * scale_multiplier), 0.12)
"""
	jelly_script.reload()
	area.set_script(jelly_script)
	var mods: Dictionary = data.get("modifiers", {})
	area.set("bounce_force", float(mods.get("bounce_force", 500.0)))
	area.set("scale_multiplier", float(mods.get("scale_multiplier", 1.0)))
	return area


func _make_speed_pad(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(48, 48), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color.CYAN)

	var speed_script := GDScript.new()
	speed_script.source_code = """extends Area2D
var boost_direction: float = 1.0
var boost_force: float = 550.0
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and "speed_pad_velocity" in body:
		body.speed_pad_velocity = Vector2(boost_direction * boost_force, 0.0)
		var main = get_tree().get_root().get_node_or_null("Main")
		if main != null:
			if main.has_method("play_sfx"): main.play_sfx("coin")
			if main.has_method("spawn_floating_text"):
				main.spawn_floating_text("ZOOM!", global_position, Color.CYAN)
"""
	speed_script.reload()
	area.set_script(speed_script)
	var mods: Dictionary = data.get("modifiers", {})
	area.set("boost_direction", float(mods.get("boost_direction", 1.0)))
	area.set("boost_force", float(mods.get("boost_force", 550.0)))
	return area


func _make_speech_sign(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(48, 48), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color.DARK_ORANGE)

	var bubble := PanelContainer.new()
	bubble.name = "SpeechBubble"
	bubble.visible = false
	bubble.position = Vector2(-75, -70)
	bubble.custom_minimum_size = Vector2(150, 45)
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.12, 0.2, 0.88)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.6, 0.9, 0.9)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	bubble.add_theme_stylebox_override("panel", style_box)

	var label := Label.new()
	label.name = "SpeechLabel"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var lbl_settings := LabelSettings.new()
	lbl_settings.font_size = 11
	lbl_settings.font_color = Color.WHITE
	label.label_settings = lbl_settings
	bubble.add_child(label)
	area.add_child(bubble)

	var sign_script := GDScript.new()
	sign_script.source_code = """extends Area2D
var speech_text: String = ""
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		var lbl = get_node_or_null("SpeechBubble/SpeechLabel")
		var bub = get_node_or_null("SpeechBubble")
		if lbl != null and bub != null:
			lbl.text = speech_text
			bub.visible = true
			var main = get_tree().get_root().get_node_or_null("Main")
			if main != null and main.has_method("play_sfx"): main.play_sfx("jump")
func _on_body_exited(body: Node) -> void:
	var bub = get_node_or_null("SpeechBubble")
	if bub != null: bub.visible = false
"""
	sign_script.reload()
	area.set_script(sign_script)
	var mods: Dictionary = data.get("modifiers", {})
	area.set("speech_text", str(mods.get("speech_text", "Hello adventurer! 🧙‍♂️")))
	return area


func _make_water_block(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(128, 128), data)
	_add_box_collision(area, size)

	var rect := ColorRect.new()
	var mods: Dictionary = data.get("modifiers", {})
	var flavor := str(mods.get("water_flavor", "normal"))
	var tint := Color(0.2, 0.5, 0.8, 0.4)
	if flavor == "toxic":
		tint = Color(0.2, 0.8, 0.2, 0.4)
	elif flavor == "lava":
		tint = Color(0.9, 0.2, 0.1, 0.4)
	rect.color = tint
	rect.size = size
	rect.position = -size * 0.5
	area.add_child(rect)

	_add_visuals(area, sidecar, size * 0.5, tint)

	var water_script := GDScript.new()
	water_script.source_code = """extends Area2D
var buoyancy: float = 0.5
var flavor: String = "normal"
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and "inside_water" in body:
		body.inside_water = true
		body.water_buoyancy = buoyancy
		body.water_type = flavor
		body.water_hurt_timer = 0.0
		var main = get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("SPLASH!", global_position, Color.CYAN)
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D and "inside_water" in body:
		body.inside_water = false
"""
	water_script.reload()
	area.set_script(water_script)
	area.set("buoyancy", float(mods.get("water_buoyancy", 0.5)))
	area.set("flavor", flavor)
	return area


func _make_crumbling_cloud(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size := _collision_size(sidecar, Vector2(128, 32), data)
	_add_box_collision(body, size)
	_add_visuals(body, sidecar, size, Color(0.8, 0.9, 1.0, 0.8))

	var sensor := Area2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(size.x - 8, 10)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -size.y * 0.5 - 5)
	sensor.add_child(col)
	body.add_child(sensor)

	var cloud_script := GDScript.new()
	cloud_script.source_code = """extends StaticBody2D
var crumble_delay: float = 0.5
var respawn_time: float = 3.0
var is_crumbled: bool = false
func _ready() -> void:
	var sens = get_child(get_child_count() - 1)
	sens.body_entered.connect(_on_player_step)
func _on_player_step(body: Node) -> void:
	if is_crumbled or not body is CharacterBody2D:
		return
	is_crumbled = true
	var tween = create_tween()
	var pos_y = position.y
	tween.tween_property(self, "position:y", pos_y + 4.0, 0.05)
	tween.tween_property(self, "position:y", pos_y - 4.0, 0.05)
	tween.set_loops(int(crumble_delay / 0.1))
	await get_tree().create_timer(crumble_delay).timeout
	collision_layer = 0
	collision_mask = 0
	var ft = create_tween()
	ft.tween_property(self, "modulate:a", 0.0, 0.2)
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("play_sfx"): main.play_sfx("hit")
	await get_tree().create_timer(respawn_time).timeout
	collision_layer = 1
	collision_mask = 1
	var rt = create_tween()
	rt.tween_property(self, "modulate:a", 1.0, 0.25)
	is_crumbled = false
"""
	cloud_script.reload()
	body.set_script(cloud_script)
	var mods: Dictionary = data.get("modifiers", {})
	body.set("crumble_delay", float(mods.get("crumble_delay", 0.5)))
	body.set("respawn_time", float(mods.get("respawn_time", 3.0)))
	return body


func _make_hazard(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(48, 48), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color.RED)

	var hazard_script := GDScript.new()
	hazard_script.source_code = """extends Area2D
var damage_value: int = 15
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage") and body is CharacterBody2D:
		body.take_damage(damage_value)
"""
	hazard_script.reload()
	area.set_script(hazard_script)
	var mods: Dictionary = data.get("modifiers", {})
	area.set("damage_value", int(mods.get("damage_value", 15)))
	return area


func _make_pet(data: Dictionary, sidecar: Dictionary) -> Node2D:
	var node := Node2D.new()
	var size := _collision_size(sidecar, Vector2(32, 32), data)
	_add_visuals(node, sidecar, size, Color.MAGENTA)

	var pet_script := GDScript.new()
	pet_script.source_code = """extends Node2D
var pet_power: String = "magnet"
var _magnet_timer: float = 0.0
func _process(delta: float) -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null or main.active_player == null: return
	var p_pos = main.active_player.global_position
	var target_pos = p_pos + Vector2(-36, -32)
	global_position = global_position.lerp(target_pos, delta * 4.0)
	match pet_power:
		"magnet":
			_magnet_timer += delta
			if _magnet_timer >= 0.3:
				_magnet_timer = 0.0
				for ent in main.spawned_entities:
					if is_instance_valid(ent) and ent.has_meta("is_collectible"):
						var dist = global_position.distance_to(ent.global_position)
						if dist < 160.0:
							var t = ent.create_tween()
							t.tween_property(ent, "global_position", p_pos, 0.25)
		"shield":
			if not main.active_player.shield_active:
				_magnet_timer += delta
				if _magnet_timer >= 5.0:
					_magnet_timer = 0.0
					main.active_player.shield_active = true
					if main.has_method("spawn_floating_text"):
						main.spawn_floating_text("SHIELD RECHARGED!", main.active_player.global_position, Color.MAGENTA)
"""
	pet_script.reload()
	node.set_script(pet_script)
	var mods: Dictionary = data.get("modifiers", {})
	var power = str(mods.get("pet_power", "magnet"))
	node.set("pet_power", power)

	if power == "light":
		var light := PointLight2D.new()
		light.color = Color(1.0, 0.9, 0.6)
		light.energy = 1.3
		light.texture_scale = 200.0 / 128.0
		
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray([Color.WHITE, Color(1.0, 1.0, 1.0, 0.0)])
		var grad_tex := GradientTexture2D.new()
		grad_tex.gradient = gradient
		grad_tex.fill = GradientTexture2D.FILL_RADIAL
		grad_tex.fill_from = Vector2(0.5, 0.5)
		grad_tex.fill_to = Vector2(1.0, 0.5)
		grad_tex.width = 128
		grad_tex.height = 128
		light.texture = grad_tex
		node.add_child(light)

	return node

