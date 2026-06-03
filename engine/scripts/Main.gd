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


func _ready() -> void:
	var level_path := _resolve_level_path()
	print("KidGameMaker runner loading level: ", level_path)
	load_level(level_path)


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
	for entity_data in entities:
		if typeof(entity_data) == TYPE_DICTIONARY:
			spawn_entity(entity_data)


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
		"checkpoint":
			node = _make_checkpoint(data, sidecar)
		_:
			node = _make_decoration(data, sidecar)

	node.name = str(data.get("instance_id", asset_id))
	node.global_position = _read_position(data.get("position", {"x": 0, "y": 0}))
	node.z_index = _z_index_for_bucket(_placement_bucket(sidecar))

	var modifiers: Dictionary = data.get("modifiers", {})
	var scale_multiplier := float(modifiers.get("scale_multiplier", 1.0))
	node.scale = Vector2(scale_multiplier, scale_multiplier)

	add_child(node)

	if bool(data.get("is_camera_target", false)):
		active_player = node
		_attach_camera(node)

	_apply_lighting_if_needed(node, sidecar)

	print("Spawned ", asset_id, " as ", runtime_template, " at ", node.global_position)
	return node


func _make_player(_data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	var size := _collision_size(sidecar, Vector2(32, 48))
	_add_box_collision(body, size)
	_add_placeholder_polygon(body, size, Color(0.2, 0.55, 1.0, 0.9))

	var script := load(PLAYER_SCRIPT)
	if script != null:
		body.set_script(script)
		var attrs: Dictionary = sidecar.get("baseline_attributes", {})
		body.set("max_health", int(attrs.get("max_health", 100)))
		body.set("movement_speed", float(attrs.get("movement_speed", 220)))
		body.set("jump_force", float(attrs.get("jump_force", -460)))
		body.set("gravity_scale", float(attrs.get("gravity_scale", 1.0)))

	return body


func _make_terrain(_data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	var body := StaticBody2D.new()
	var size := _collision_size(sidecar, Vector2(128, 32))
	_add_box_collision(body, size)
	_add_placeholder_polygon(body, size, Color(0.45, 0.45, 0.45, 1.0))
	return body


func _make_enemy(_data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	var size := _collision_size(sidecar, Vector2(32, 32))
	_add_box_collision(body, size)
	_add_placeholder_polygon(body, size, Color(1.0, 0.25, 0.25, 0.9))

	var script := load(ENEMY_SCRIPT)
	if script != null:
		body.set_script(script)
		var attrs: Dictionary = sidecar.get("baseline_attributes", {})
		body.set("patrol_speed", float(attrs.get("movement_speed", 70)))
		body.set("gravity_scale", float(attrs.get("gravity_scale", 1.0)))

	return body


func _make_collectible(_data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(24, 24))
	_add_box_collision(area, size)
	_add_placeholder_polygon(area, size, Color(1.0, 0.85, 0.15, 0.95))

	var script := load(COLLECTIBLE_SCRIPT)
	if script != null:
		area.set_script(script)
		var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
		area.set("score_value", int(gameplay.get("score_value", 0)))

	return area


func _make_checkpoint(_data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size := _collision_size(sidecar, Vector2(40, 56))
	_add_box_collision(area, size)
	_add_placeholder_polygon(area, size, Color(0.3, 1.0, 0.7, 0.8))
	return area


func _make_decoration(_data: Dictionary, sidecar: Dictionary) -> Node2D:
	var node := Node2D.new()
	var size := _collision_size(sidecar, Vector2(48, 48))
	_add_placeholder_polygon(node, size, Color(0.65, 0.35, 1.0, 0.75))
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
					sidecar_cache[asset_id] = parsed
					return parsed

	push_warning("No sidecar found for asset_id: " + asset_id + ". Using defaults.")
	var fallback := {
		"asset_id": asset_id,
		"asset_name": asset_id,
		"runtime_template": "decoration",
		"placement_logic": {"parallax_bucket": "play_layer"},
		"collision": {"size": [48, 48]}
	}
	sidecar_cache[asset_id] = fallback
	return fallback


func _collision_size(sidecar: Dictionary, fallback: Vector2) -> Vector2:
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
	var weather := str(settings.get("weather", "clear"))
	print("World settings: time=", time_of_day, " weather=", weather)


func _apply_lighting_if_needed(node: Node2D, sidecar: Dictionary) -> void:
	var lighting: Dictionary = sidecar.get("lighting_logic", {})
	if not bool(lighting.get("emits_light", false)):
		return

	var light := PointLight2D.new()
	light.color = Color(str(lighting.get("light_color", "#ffffff")))
	light.energy = float(lighting.get("light_energy", 1.0))
	light.texture_scale = float(lighting.get("light_radius", 128.0)) / 128.0
	node.add_child(light)
