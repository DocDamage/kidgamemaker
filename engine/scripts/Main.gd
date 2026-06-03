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

var hud_canvas: CanvasLayer = null
var hud_health_label: Label = null
var hud_score_label: Label = null
var _js_pause_cb: JavaScriptObject
var _js_restart_cb: JavaScriptObject
var _js_mute_cb: JavaScriptObject


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
	get_tree().reload_current_scene()


func _on_js_mute(args: Array) -> void:
	var mute_val: bool = args[0] if args.size() > 0 else false
	AudioServer.set_bus_mute(0, mute_val)
	print("Game mute state set via JS: ", mute_val)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		print("Reset key pressed. Reloading scene...")
		get_tree().reload_current_scene()


func _physics_process(_delta: float) -> void:
	if active_player != null:
		if active_player.global_position.y > death_y_threshold:
			_respawn_player()


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
		_:
			node = _make_decoration(data, sidecar)

	node.name = str(data.get("instance_id", asset_id))
	node.global_position = _read_position(data.get("position", {"x": 0, "y": 0}))
	node.z_index = _z_index_for_bucket(_placement_bucket(sidecar))

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


func _make_terrain(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
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

	return area


func _make_key_collectible(data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(20, 20), data)
	_add_box_collision(area, size)
	_add_visuals(area, sidecar, size, Color(1.0, 0.85, 0.0, 0.95))

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

	particles.amount = 20
	particles.lifetime = 1.0
	particles.explosiveness = 0.0
	particles.randomness = 0.5
	particles.emitting = true

	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(16, 16)

	match asset_id:
		"effects_fire":
			particles.amount = 35
			particles.lifetime = 0.8
			particles.direction = Vector2(0, -1)
			particles.spread = 20.0
			particles.gravity = Vector2(0, -180)
			particles.initial_velocity_min = 40.0
			particles.initial_velocity_max = 80.0

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 0.2, 0.0, 1.0))
			grad.add_key(0.5, Color(1.0, 0.8, 0.0, 1.0))
			grad.set_color(1, Color(1.0, 0.2, 0.0, 0.0))
			particles.color_ramp = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 6.0))
			curve.add_point(Vector2(1, 1.0))
			particles.scale_amount_curve = curve

		"effects_sparkles":
			particles.amount = 15
			particles.lifetime = 1.2
			particles.direction = Vector2.ZERO
			particles.spread = 180.0
			particles.gravity = Vector2(0, 0)
			particles.initial_velocity_min = 10.0
			particles.initial_velocity_max = 30.0

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 0.9, 0.4, 1.0))
			grad.add_key(0.5, Color(0.4, 0.9, 1.0, 1.0))
			grad.set_color(1, Color(0.4, 0.9, 1.0, 0.0))
			particles.color_ramp = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 0.0))
			curve.add_point(Vector2(0.2, 4.0))
			curve.add_point(Vector2(0.8, 4.0))
			curve.add_point(Vector2(1, 0.0))
			particles.scale_amount_curve = curve

		"effects_snow":
			particles.amount = 25
			particles.lifetime = 2.0
			particles.direction = Vector2(0.2, 1.0)
			particles.spread = 15.0
			particles.gravity = Vector2(0, 80)
			particles.initial_velocity_min = 20.0
			particles.initial_velocity_max = 40.0
			particles.color = Color(1.0, 1.0, 1.0, 0.9)

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 1.0, 1.0, 0.9))
			grad.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
			particles.color_ramp = grad

			particles.scale_amount_min = 2.0
			particles.scale_amount_max = 4.0

		"effects_hearts":
			particles.amount = 10
			particles.lifetime = 1.5
			particles.direction = Vector2(0, -1)
			particles.spread = 45.0
			particles.gravity = Vector2(0, -60)
			particles.initial_velocity_min = 20.0
			particles.initial_velocity_max = 50.0

			var grad := Gradient.new()
			grad.set_color(0, Color(1.0, 0.4, 0.6, 1.0))
			grad.add_key(0.6, Color(1.0, 0.1, 0.4, 1.0))
			grad.set_color(1, Color(1.0, 0.1, 0.4, 0.0))
			particles.color_ramp = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 1.0))
			curve.add_point(Vector2(0.4, 5.0))
			curve.add_point(Vector2(0.8, 5.0))
			curve.add_point(Vector2(1, 0.0))
			particles.scale_amount_curve = curve

		"effects_smoke":
			particles.amount = 15
			particles.lifetime = 2.0
			particles.direction = Vector2(0.5, -1.0)
			particles.spread = 30.0
			particles.gravity = Vector2(10, -50)
			particles.initial_velocity_min = 15.0
			particles.initial_velocity_max = 30.0

			var grad := Gradient.new()
			grad.set_color(0, Color(0.7, 0.7, 0.7, 0.8))
			grad.add_key(0.5, Color(0.8, 0.8, 0.8, 0.4))
			grad.set_color(1, Color(0.9, 0.9, 0.9, 0.0))
			particles.color_ramp = grad

			var curve := Curve.new()
			curve.add_point(Vector2(0, 3.0))
			curve.add_point(Vector2(0.5, 8.0))
			curve.add_point(Vector2(1, 12.0))
			particles.scale_amount_curve = curve

		_:
			particles.amount = 10
			particles.color = Color(1.0, 1.0, 1.0, 1.0)

	return particles


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
	active_player.global_position = spawn_point
	if active_player.has_method("set_velocity"):
		active_player.set("velocity", Vector2.ZERO)
	elif "velocity" in active_player:
		active_player.velocity = Vector2.ZERO


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

