extends Node2D

const DEFAULT_LEVEL_PATH := "res://data/dummy_level.json"
const ASSET_ROOT := "res://data/assets"
const PLAYER_SCRIPT := "res://scripts/PlayerController.gd"
const ENEMY_SCRIPT := "res://scripts/SmartEnemy.gd"
const COLLECTIBLE_SCRIPT := "res://scripts/Collectible.gd"
const AUDIO_MANAGER_SCRIPT := "res://scripts/AudioManager.gd"
const HUD_MANAGER_SCRIPT := "res://scripts/HudManager.gd"
const LEVEL_BALANCER_SCRIPT := preload("res://scripts/LevelBalancer.gd")
const FLOATING_TEXT_MANAGER_SCRIPT := preload("res://scripts/FloatingTextManager.gd")
const RUNTIME_VISUAL_FACTORY_SCRIPT := preload("res://scripts/RuntimeVisualFactory.gd")
const RUNTIME_WORLD_ENVIRONMENT_SCRIPT := preload("res://scripts/RuntimeWorldEnvironment.gd")
const RUNTIME_TERRAIN_MERGER_SCRIPT := preload("res://scripts/RuntimeTerrainMerger.gd")
const RUNTIME_PHASE_A_CONTRACT_SCRIPT := preload("res://scripts/RuntimePhaseAContract.gd")
const END_GAME_OVERLAY_MANAGER_SCRIPT := preload("res://scripts/EndGameOverlayManager.gd")
const RUNTIME_TRIGGER_SCRIPT := preload("res://scripts/RuntimeTrigger.gd")
const RUNTIME_RULE_EXECUTOR_SCRIPT := preload("res://scripts/RuntimeRuleExecutor.gd")
const RUNTIME_PRESSURE_PLATE_SCRIPT := preload("res://scripts/RuntimePressurePlate.gd")
const RUNTIME_GATE_SCRIPT := preload("res://scripts/RuntimeGate.gd")
const RUNTIME_JELLY_SCRIPT := preload("res://scripts/RuntimeJelly.gd")
const RUNTIME_SPEED_PAD_SCRIPT := preload("res://scripts/RuntimeSpeedPad.gd")
const RUNTIME_SPEECH_SIGN_SCRIPT := preload("res://scripts/RuntimeSpeechSign.gd")
const RUNTIME_WATER_BLOCK_SCRIPT := preload("res://scripts/RuntimeWaterBlock.gd")
const RUNTIME_CRUMBLING_CLOUD_SCRIPT := preload("res://scripts/RuntimeCrumblingCloud.gd")
const RUNTIME_HAZARD_SCRIPT := preload("res://scripts/RuntimeHazard.gd")
const RUNTIME_CONVEYOR_SCRIPT := preload("res://scripts/RuntimeConveyor.gd")
const RUNTIME_MYSTERY_BOX_SCRIPT := preload("res://scripts/RuntimeMysteryBox.gd")
const RUNTIME_GRAVITY_ZONE_SCRIPT := preload("res://scripts/RuntimeGravityZone.gd")
const RUNTIME_SHOPKEEPER_SCRIPT := preload("res://scripts/RuntimeShopkeeper.gd")
const RUNTIME_DESTRUCTIBLE_TERRAIN_SCRIPT := preload("res://scripts/RuntimeDestructibleTerrain.gd")
const RUNTIME_WIND_ZONE_SCRIPT := preload("res://scripts/RuntimeWindZone.gd")
const RUNTIME_TARGET_PRACTICE_SCRIPT := preload("res://scripts/RuntimeTargetPractice.gd")
const RUNTIME_MOVING_PLATFORM_SCRIPT := preload("res://scripts/RuntimeMovingPlatform.gd")
const RUNTIME_ILLUSION_PLATFORM_SCRIPT := preload("res://scripts/RuntimeIllusionPlatform.gd")
const RUNTIME_CLEAR_PIPE_SCRIPT := preload("res://scripts/RuntimeClearPipe.gd")
const RUNTIME_LOGIC_GATE_SCRIPT := preload("res://scripts/RuntimeLogicGate.gd")
const RUNTIME_PET_SCRIPT := preload("res://scripts/RuntimePet.gd")
const RUNTIME_RECOVERY_GHOST_SCRIPT := preload("res://scripts/RuntimeRecoveryGhost.gd")
const RUNTIME_INTERACTION_STATION_SCRIPT := preload("res://scripts/RuntimeInteractionStation.gd")
const RUNTIME_RISING_HAZARD_SCRIPT := preload("res://scripts/RuntimeRisingHazard.gd")
const RUNTIME_ZONAI_SPRING_SCRIPT := preload("res://scripts/RuntimeZonaiSpring.gd")
const RUNTIME_ZONAI_BEAM_SCRIPT := preload("res://scripts/RuntimeZonaiBeam.gd")
const RUNTIME_GHOST_COMPANION_SCRIPT := preload("res://scripts/RuntimeGhostCompanion.gd")
const RUNTIME_PIKMIN_SCRIPT := preload("res://scripts/RuntimePikmin.gd")
const RUNTIME_RUSH_ADAPTER_SCRIPT := preload("res://scripts/RuntimeRushAdapter.gd")
const RUNTIME_PALICO_SCRIPT := preload("res://scripts/RuntimePalico.gd")
const RUNTIME_PANEL_FACTORY_SCRIPT := preload("res://scripts/RuntimePanelFactory.gd")
const RUNTIME_ELEMENTAL_CHEMISTRY_SCRIPT := preload("res://scripts/RuntimeElementalChemistry.gd")
const RUNTIME_CONTRAPTION_BUILDER_SCRIPT := preload("res://scripts/RuntimeContraptionBuilder.gd")
const RUNTIME_CONTRAPTION_SIMULATOR_SCRIPT := preload("res://scripts/RuntimeContraptionSimulator.gd")
const RUNTIME_AUTOSCROLL_SCRIPT := preload("res://scripts/RuntimeAutoscroll.gd")
const RUNTIME_BEAT_PULSE_SCRIPT := preload("res://scripts/RuntimeBeatPulse.gd")
const RUNTIME_FRAME_EFFECTS_SCRIPT := preload("res://scripts/RuntimeFrameEffects.gd")
const RUNTIME_TUTORIAL_WHISPERER_SCRIPT := preload("res://scripts/RuntimeTutorialWhisperer.gd")
const RUNTIME_GHOST_REPLAY_SCRIPT := preload("res://scripts/RuntimeGhostReplay.gd")
const RUNTIME_VICTORY_CONDITIONS_SCRIPT := preload("res://scripts/RuntimeVictoryConditions.gd")
const RUNTIME_COLLECTIBLE_REWARDS_SCRIPT := preload("res://scripts/RuntimeCollectibleRewards.gd")
const RUNTIME_RECOVERY_GHOST_FACTORY_SCRIPT := preload("res://scripts/RuntimeRecoveryGhostFactory.gd")
const RUNTIME_AMBIENT_CREATURE_SCRIPT := preload("res://scripts/RuntimeAmbientCreature.gd")
const RUNTIME_COMMERCE_SCRIPT := preload("res://scripts/RuntimeCommerce.gd")
const RUNTIME_RISING_HAZARD_FACTORY_SCRIPT := preload("res://scripts/RuntimeRisingHazardFactory.gd")
const RUNTIME_ZONAI_DEVICE_FACTORY_SCRIPT := preload("res://scripts/RuntimeZonaiDeviceFactory.gd")
const RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT := preload("res://scripts/RuntimeGameplayObjectFactory.gd")
const RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT := preload("res://scripts/RuntimeSpawnEntityFactory.gd")
const RUNTIME_ENTITY_SPAWNER_SCRIPT := preload("res://scripts/RuntimeEntitySpawner.gd")
const RUNTIME_PARTICLE_FACTORY_SCRIPT := preload("res://scripts/RuntimeParticleFactory.gd")
const RUNTIME_PROGRESSION_FLOW_SCRIPT := preload("res://scripts/RuntimeProgressionFlow.gd")
const RUNTIME_COMBAT_TRAVERSAL_GLUE_SCRIPT := preload("res://scripts/RuntimeCombatTraversalGlue.gd")
const RUNTIME_VISUAL_PROGRESSION_SCRIPT := preload("res://scripts/RuntimeVisualProgression.gd")
const RUNTIME_COMPASS_SCRIPT := preload("res://scripts/RuntimeCompass.gd")

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
var active_player_1: Node2D = null
var active_player_2: Node2D = null
var health_style: String = "hearts"
var spawn_point: Vector2 = Vector2.ZERO
var death_y_threshold: float = 2000.0
var spawned_entities: Array = []
var contraptions: Array = []
var backpack_ui: CanvasLayer = null
var crafting_ui: CanvasLayer = null
var cooking_ui: CanvasLayer = null
var target_spawn_portal_id: String = ""
var found_spawn_portal_pos: Variant = null
var current_weather: String = "clear"
var score: int = 0
var keys_collected: Dictionary = {}  # key_color -> count
var victory_rules: Dictionary = {"win_condition": "all_enemies", "celebration": "confetti"}
var loss_rules: Dictionary = {"lose_condition": "health_0", "action": "game_over"}
var difficulty: String = "normal"
var calm_mode: bool = false
var enemy_speed_multiplier: float = 1.0
var boss_intro_played: bool = false
var current_boss_node: Node2D = null
var card_battle_bonus: String = ""

# Turf War Mode
var turf_war_enabled: bool = false
var turf_war_time_left: float = 180.0
var turf_war_ended: bool = false

# Celestial Brush
var brush_active: bool = false
var brush_points: Array[Vector2] = []
var brush_line_node: Line2D = null
var brush_overlay_label: Label = null
var game_speed_multiplier: float = 1.0

var hud_canvas: CanvasLayer = null
var hud_health_label: Label = null
var hud_score_label: Label = null
var hud_helper_label: Label = null
var hud_manager: Node = null
var _js_pause_cb: JavaScriptObject
var _js_restart_cb: JavaScriptObject
var _js_mute_cb: JavaScriptObject
var _js_live_update_cb: JavaScriptObject

static var run_record: Array = []
var current_run: Array = []
var ghost_player_node: Node2D = null
var ghost_playback_index: int = 0
var physics_tick_counter: int = 0
var room_rules: Array = []
var collectibles_collected: int = 0

var camera_autoscroll_enabled: bool = false
var camera_autoscroll_direction: String = "right"
var camera_autoscroll_speed: float = 40.0
var audio_debug: bool = false
var audio_manager: Node = null
var floating_text_manager: Node = null
var end_game_overlay_manager: Node = null
var rule_executor: Node = null
var autoscroll_camera_node: Camera2D = null
var progression_flow: Node = null
var combat_traversal_glue: Node = null

var level_balancer_enabled: bool = true
var tutorial_whisperer_enabled: bool = true
var level_balance_report: Dictionary = {}
var respawn_count: int = 0
var last_respawn_position: Vector2 = Vector2.ZERO
var last_hint_position: Vector2 = Vector2(-99999, -99999)
var hint_cooldown: float = 0.0
var schema_version: String = "1"
var movement_system_config: Dictionary = {}
var combat_system_config: Dictionary = {}
var rules_engine_config: Dictionary = {}
var ai_assist_config: Dictionary = {}

# Persistent whisperer state across deaths (death clusters, stuck timer, etc.)
var _whisperer_state: Dictionary = {}
# Current time-scale target for struggle slow — lerped toward 1.0 on recovery
var _struggle_time_scale_target: float = 1.0


func _ready() -> void:
	_ensure_audio_manager()
	_ensure_floating_text_manager()
	_ensure_end_game_overlay_manager()
	_ensure_rule_executor()
	_ensure_progression_flow()
	_ensure_combat_traversal_glue()
	if OS.has_feature("web"):
		var window = JavaScriptBridge.get_interface("window")
		if window != null:
			_js_pause_cb = JavaScriptBridge.create_callback(_on_js_pause)
			_js_restart_cb = JavaScriptBridge.create_callback(_on_js_restart)
			_js_mute_cb = JavaScriptBridge.create_callback(_on_js_mute)
			_js_live_update_cb = JavaScriptBridge.create_callback(_on_js_live_update)
			window.set("godotPauseGame", _js_pause_cb)
			window.set("godotRestartGame", _js_restart_cb)
			window.set("godotMuteGame", _js_mute_cb)
			window.set("godotLiveUpdateRoom", _js_live_update_cb)

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


func _exit_tree() -> void:
	_cleanup_audio_resources()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_cleanup_audio_resources()


func _cleanup_audio_resources() -> void:
	if audio_manager != null and is_instance_valid(audio_manager) and audio_manager.has_method("cleanup"):
		audio_manager.cleanup()


func _ensure_audio_manager() -> void:
	if audio_manager != null and is_instance_valid(audio_manager):
		return
	var script = load(AUDIO_MANAGER_SCRIPT)
	if script == null:
		push_warning("Audio manager script not found: " + AUDIO_MANAGER_SCRIPT)
		return
	audio_manager = script.new()
	audio_manager.name = "AudioManager"
	add_child(audio_manager)
	if audio_manager.has_method("configure"):
		audio_manager.configure(self)


func _ensure_hud_manager() -> void:
	if hud_manager != null and is_instance_valid(hud_manager):
		return
	var script = load(HUD_MANAGER_SCRIPT)
	if script == null:
		push_warning("HUD manager script not found: " + HUD_MANAGER_SCRIPT)
		return
	hud_manager = script.new()
	hud_manager.name = "HudManager"
	add_child(hud_manager)
	if hud_manager.has_method("configure"):
		hud_manager.configure(self)


func _ensure_floating_text_manager() -> void:
	if floating_text_manager != null and is_instance_valid(floating_text_manager):
		return
	floating_text_manager = FLOATING_TEXT_MANAGER_SCRIPT.new()
	floating_text_manager.name = "FloatingTextManager"
	add_child(floating_text_manager)


func _ensure_end_game_overlay_manager() -> void:
	if end_game_overlay_manager != null and is_instance_valid(end_game_overlay_manager):
		return
	end_game_overlay_manager = END_GAME_OVERLAY_MANAGER_SCRIPT.new()
	end_game_overlay_manager.name = "EndGameOverlayManager"
	add_child(end_game_overlay_manager)
	if end_game_overlay_manager.has_method("configure"):
		end_game_overlay_manager.configure(self)


func _ensure_rule_executor() -> void:
	if rule_executor != null and is_instance_valid(rule_executor):
		return
	rule_executor = RUNTIME_RULE_EXECUTOR_SCRIPT.new()
	rule_executor.name = "RuleExecutor"
	add_child(rule_executor)
	if rule_executor.has_method("configure"):
		rule_executor.configure(self)


func _ensure_progression_flow() -> void:
	if progression_flow != null and is_instance_valid(progression_flow):
		return
	progression_flow = RUNTIME_PROGRESSION_FLOW_SCRIPT.new()
	progression_flow.name = "ProgressionFlow"
	add_child(progression_flow)
	progression_flow.configure(self)


func _ensure_combat_traversal_glue() -> void:
	if combat_traversal_glue != null and is_instance_valid(combat_traversal_glue):
		return
	combat_traversal_glue = RUNTIME_COMBAT_TRAVERSAL_GLUE_SCRIPT.new()
	combat_traversal_glue.name = "CombatTraversalGlue"
	add_child(combat_traversal_glue)
	combat_traversal_glue.configure(self)


func _sync_hud_refs() -> void:
	if hud_manager == null or not is_instance_valid(hud_manager):
		hud_canvas = null
		hud_health_label = null
		hud_score_label = null
		hud_helper_label = null
		return
	hud_canvas = hud_manager.get("hud_canvas")
	hud_health_label = hud_manager.get("hud_health_label")
	hud_score_label = hud_manager.get("hud_score_label")
	hud_helper_label = hud_manager.get("hud_helper_label")


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


func _on_js_live_update(args: Array) -> void:
	var json_str: String = args[0] if args.size() > 0 else ""
	if json_str == "":
		return
	print("Live-updating room from Svelte...")
	var json := JSON.new()
	var error := json.parse(json_str)
	if error != OK:
		push_error("JS Live Update parse error: " + json.get_error_message())
		return

	var level_data: Variant = json.get_data()
	if typeof(level_data) != TYPE_DICTIONARY:
		return

	_apply_world_settings(level_data.get("world_settings", {}))
	
	# Clear all spawned entities except players
	for node in spawned_entities:
		if is_instance_valid(node) and node != active_player_1 and node != active_player_2:
			node.queue_free()

	var next_entities := []
	if active_player_1 != null and is_instance_valid(active_player_1):
		next_entities.append(active_player_1)
	if active_player_2 != null and is_instance_valid(active_player_2):
		next_entities.append(active_player_2)
	spawned_entities = next_entities

	# Re-spawn entities except the player templates
	var entities: Array = level_data.get("entities", [])
	for entity_data in entities:
		if typeof(entity_data) == TYPE_DICTIONARY:
			var asset_id: String = str(entity_data.get("asset_id", ""))
			var sidecar := _load_sidecar(asset_id)
			var template: String = str(sidecar.get("runtime_template", ""))
			if template == "player":
				spawn_point = _read_position(entity_data.get("position", {"x": 0, "y": 0}))
				continue
			spawn_entity(entity_data)

	_build_physics_contraptions()
	_ensure_rule_executor()
	if rule_executor != null and is_instance_valid(rule_executor) and rule_executor.has_method("auto_connect_proximity_triggers"):
		rule_executor.auto_connect_proximity_triggers(room_rules)
	_initialize_logic_gates()

	_apply_weather_particles()
	_configure_camera_limits()
	_update_hud()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		print("Reset key pressed. Reloading scene...")
		if current_run.size() > 20:
			run_record = current_run
		get_tree().reload_current_scene()
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		toggle_celestial_brush()
		get_viewport().set_input_as_handled()
		return

	if brush_active:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					brush_points.clear()
					if brush_line_node != null:
						brush_line_node.clear_points()
					var mouse_pos := get_global_mouse_position()
					brush_points.append(mouse_pos)
					if brush_line_node != null:
						brush_line_node.add_point(mouse_pos)
				else:
					if brush_points.size() >= 10:
						var gesture = _classify_stroke(brush_points)
						_execute_brush_miracle(gesture, brush_points)
					else:
						if brush_line_node != null:
							brush_line_node.clear_points()
						var center_pos = get_global_mouse_position()
						spawn_floating_text("❌ TOO SHORT", center_pos, Color.RED)
					brush_points.clear()
					_deactivate_brush()
				get_viewport().set_input_as_handled()
				return

		elif event is InputEventMouseMotion:
			if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
				var mouse_pos := get_global_mouse_position()
				if brush_points.is_empty() or brush_points.back().distance_to(mouse_pos) > 8.0:
					brush_points.append(mouse_pos)
					if brush_line_node != null:
						brush_line_node.add_point(mouse_pos)
				get_viewport().set_input_as_handled()
				return


var _pulse_timer: float = 0.0
func _physics_process(delta: float) -> void:
	if audio_manager != null and is_instance_valid(audio_manager) and audio_manager.has_method("fill_audio_buffer"):
		audio_manager.fill_audio_buffer()

	physics_tick_counter += 1
	if hint_cooldown > 0.0:
		hint_cooldown = max(0.0, hint_cooldown - delta)

	if camera_autoscroll_enabled and autoscroll_camera_node != null and is_instance_valid(autoscroll_camera_node):
		var should_respawn := RUNTIME_AUTOSCROLL_SCRIPT.update(
			autoscroll_camera_node,
			active_player,
			camera_autoscroll_direction,
			camera_autoscroll_speed,
			delta,
			get_viewport_rect().size
		)
		if should_respawn:
			_respawn_player()

	var ghost_state: Dictionary = RUNTIME_GHOST_REPLAY_SCRIPT.update(
		active_player,
		ghost_player_node,
		run_record,
		current_run,
		ghost_playback_index,
		physics_tick_counter,
		death_y_threshold
	)
	current_run = ghost_state.get("current_run", current_run)
	ghost_player_node = ghost_state.get("ghost_node", ghost_player_node)
	ghost_playback_index = int(ghost_state.get("ghost_playback_index", ghost_playback_index))
	if bool(ghost_state.get("should_respawn", false)):
		_respawn_player()

	RUNTIME_CONTRAPTION_SIMULATOR_SCRIPT.update(contraptions, delta)

	# Chemistry Engine Spreading (every 0.1s)
	if physics_tick_counter % 6 == 0:
		_process_elemental_chemistry()

	_pulse_timer = RUNTIME_BEAT_PULSE_SCRIPT.update(self, _pulse_timer, delta)


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
	boss_intro_played = false
	current_boss_node = null
	respawn_count = 0
	last_respawn_position = Vector2.ZERO
	last_hint_position = Vector2(-99999, -99999)
	hint_cooldown = 0.0
	enemy_speed_multiplier = 1.0
	_whisperer_state = {}
	_struggle_time_scale_target = 1.0
	Engine.time_scale = 1.0
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
	_apply_phase_a_contract(level_data)

	var entities: Array = level_data.get("entities", [])
	var balanced_entities := _apply_level_balancer(entities)
	var processed_entities := _merge_terrain_entities(balanced_entities)

	for entity_data in processed_entities:
		if typeof(entity_data) == TYPE_DICTIONARY:
			spawn_entity(entity_data)

	_build_physics_contraptions()
	_ensure_rule_executor()
	if rule_executor != null and is_instance_valid(rule_executor) and rule_executor.has_method("auto_connect_proximity_triggers"):
		rule_executor.auto_connect_proximity_triggers(room_rules)
	_initialize_logic_gates()

	if target_spawn_portal_id != "" and found_spawn_portal_pos != null and active_player != null:
		active_player.global_position = found_spawn_portal_pos
		spawn_point = found_spawn_portal_pos
		print("Teleported player to target portal: ", target_spawn_portal_id, " at ", found_spawn_portal_pos)

	target_spawn_portal_id = ""
	found_spawn_portal_pos = null

	_apply_weather_particles()
	_configure_camera_limits()
	_check_and_spawn_rising_hazard(level_data.get("world_settings", {}))
	_create_hud()
	_spawn_ghost()


func _apply_phase_a_contract(level_data: Dictionary) -> void:
	var applied: Dictionary = RUNTIME_PHASE_A_CONTRACT_SCRIPT.apply(
		level_data,
		level_balancer_enabled,
		tutorial_whisperer_enabled
	)
	schema_version = str(applied.get("schema_version", "1"))
	movement_system_config = applied.get("movement_system", {})
	combat_system_config = applied.get("combat_system", {})
	rules_engine_config = applied.get("rules_engine", {})
	ai_assist_config = applied.get("ai_assist", {})
	level_balancer_enabled = bool(applied.get("level_balancer_enabled", level_balancer_enabled))
	tutorial_whisperer_enabled = bool(applied.get("tutorial_whisperer_enabled", tutorial_whisperer_enabled))
	print(
		"Phase A contract: schema=",
		schema_version,
		" movement=",
		movement_system_config.get("movement_ids", []),
		" combat=",
		combat_system_config.get("mechanics", []),
		" rules=",
		rules_engine_config.get("primitives", []),
		" ai=",
		ai_assist_config
	)


func _merge_terrain_entities(entities: Array) -> Array:
	return RUNTIME_TERRAIN_MERGER_SCRIPT.merge(
		entities,
		Callable(self, "_load_sidecar"),
		Callable(self, "_collision_size")
	)


func spawn_entity(data: Dictionary) -> Node2D:
	return RUNTIME_ENTITY_SPAWNER_SCRIPT.spawn(self, data)


func _make_player(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	return RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT.create_player(self, data, sidecar, PLAYER_SCRIPT, difficulty)


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

		body.set_script(RUNTIME_MOVING_PLATFORM_SCRIPT)
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

			body.set_script(RUNTIME_ILLUSION_PLATFORM_SCRIPT)
			return body
		else:
			var body := StaticBody2D.new()
			var size := _collision_size(sidecar, Vector2(128, 32), data)
			_add_box_collision(body, size)
			_add_visuals(body, sidecar, size, Color(0.45, 0.45, 0.45, 1.0))
			return body


func _make_enemy(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	return RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT.create_enemy(self, data, sidecar, ENEMY_SCRIPT)


func _make_collectible(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT.create_collectible(self, data, sidecar, COLLECTIBLE_SCRIPT)


func _make_key_collectible(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT.create_key_collectible(self, data, sidecar, COLLECTIBLE_SCRIPT)


func _make_checkpoint(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT.create_checkpoint(self, data, sidecar)


func _make_portal(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT.create_portal(self, data, sidecar)


func _make_locked_door(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_SPAWN_ENTITY_FACTORY_SCRIPT.create_locked_door(self, data, sidecar)


func _make_particles(data: Dictionary, sidecar: Dictionary) -> CPUParticles2D:
	return RUNTIME_PARTICLE_FACTORY_SCRIPT.create(data, sidecar)


func spawn_floating_text(text: String, global_pos: Vector2, color: Color) -> void:
	_ensure_floating_text_manager()
	if floating_text_manager != null and is_instance_valid(floating_text_manager) and floating_text_manager.has_method("spawn_text"):
		floating_text_manager.spawn_text(text, global_pos, color)


func _make_decoration(data: Dictionary, sidecar: Dictionary) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_decoration(self, data, sidecar)


func _make_wall_run_surface(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_meta_static_body(self, data, sidecar, Vector2(48, 48), Color.CHARTREUSE, "wall_run_surface")


func _make_ceiling_run_surface(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_meta_static_body(self, data, sidecar, Vector2(48, 48), Color.CYAN, "ceiling_run_surface")


func _make_speed_booster_block(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_speed_booster_block(self, data, sidecar, RUNTIME_DESTRUCTIBLE_TERRAIN_SCRIPT)


func _make_grapple_ring(data: Dictionary, sidecar: Dictionary) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_meta_node(self, data, sidecar, Vector2(32, 32), Color.ORANGE, "grapple_ring")


func _make_climbable_vine(data: Dictionary, sidecar: Dictionary) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_meta_node(self, data, sidecar, Vector2(16, 120), Color.GREEN, "climbable_vine")


func _make_climbable_rope(data: Dictionary, sidecar: Dictionary) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_meta_node(self, data, sidecar, Vector2(16, 120), Color.SADDLE_BROWN, "climbable_rope")


func _make_clear_pipe(data: Dictionary, sidecar: Dictionary) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_clear_pipe(self, data, sidecar, RUNTIME_CLEAR_PIPE_SCRIPT)


func _make_logic_gate(data: Dictionary, sidecar: Dictionary, gate_type: String) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_logic_gate(self, data, sidecar, gate_type, RUNTIME_LOGIC_GATE_SCRIPT)


func _read_position(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))

	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0)), float(value.get("y", 0)))

	return Vector2.ZERO


func _apply_level_balancer(entities: Array) -> Array:
	var result: Dictionary = LEVEL_BALANCER_SCRIPT.apply(
		entities,
		level_balancer_enabled,
		Callable(self, "_load_sidecar"),
		Callable(self, "_collision_size")
	)
	var report_value: Variant = result.get("report", {})
	level_balance_report = report_value if typeof(report_value) == TYPE_DICTIONARY else {}
	var adjusted_value: Variant = result.get("entities", entities)
	return adjusted_value if typeof(adjusted_value) == TYPE_ARRAY else entities


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
	return RUNTIME_VISUAL_FACTORY_SCRIPT.collision_size(sidecar, fallback, entity_data)


func _add_box_collision(parent: Node, size: Vector2) -> void:
	RUNTIME_VISUAL_FACTORY_SCRIPT.add_box_collision(parent, size)


func _add_fallback_polygon(parent: Node2D, size: Vector2, color: Color) -> void:
	RUNTIME_VISUAL_FACTORY_SCRIPT.add_fallback_polygon(parent, size, color)


func _add_visuals(parent: Node2D, sidecar: Dictionary, size: Vector2, default_color: Color) -> void:
	RUNTIME_VISUAL_FACTORY_SCRIPT.add_visuals(parent, sidecar, size, default_color, ASSET_ROOT)


func _load_texture_dynamic(path: String, sidecar_file_path: String) -> Texture2D:
	return RUNTIME_VISUAL_FACTORY_SCRIPT.load_texture_dynamic(path, sidecar_file_path, ASSET_ROOT)


func _on_checkpoint_activated(pos: Vector2) -> void:
	_ensure_progression_flow()
	progression_flow.checkpoint_activated(pos)


func _respawn_player() -> void:
	_ensure_progression_flow()
	progression_flow.respawn_player()


func _note_player_failure(failure_position: Vector2) -> void:
	if not tutorial_whisperer_enabled:
		return

	# Merge persistent whisperer state with the short-lived per-call fields
	_whisperer_state["respawn_count"] = respawn_count
	_whisperer_state["last_respawn_position"] = last_respawn_position
	_whisperer_state["last_hint_position"] = last_hint_position
	_whisperer_state["hint_cooldown"] = hint_cooldown

	var result: Dictionary = RUNTIME_TUTORIAL_WHISPERER_SCRIPT.note_failure(
		failure_position,
		spawned_entities,
		level_balance_report,
		_whisperer_state
	)
	_whisperer_state = result.get("state", _whisperer_state)
	var state: Dictionary = _whisperer_state
	respawn_count = int(state.get("respawn_count", respawn_count))
	last_respawn_position = state.get("last_respawn_position", last_respawn_position)
	last_hint_position = state.get("last_hint_position", last_hint_position)
	hint_cooldown = float(state.get("hint_cooldown", hint_cooldown))

	# Dynamic Assist: Slow down enemies and boost player parameters on repeated failures
	if bool(result.get("trigger_assist", false)):
		enemy_speed_multiplier = 0.7
		if active_player != null and is_instance_valid(active_player):
			active_player.set("coyote_time_duration", 0.22)
			active_player.set("jump_buffer_duration", 0.22)
			spawn_floating_text("🛠️ ASSIST ACTIVE: Slow Enemies & Easy Jumps!", failure_position + Vector2(0, -72), Color(0.4, 1.0, 0.4))
			print("Dynamic Assist triggered: enemy_speed_multiplier=0.7, player assist duration=0.22")

	# Time-scale slow for heavy struggling
	if bool(result.get("trigger_time_slow", false)):
		_struggle_time_scale_target = 0.88
		print("Struggle time-slow engaged: target=0.88")

	# Spawn invisible assist platforms at death hotspots
	for hotspot_pos in result.get("spawn_invisible_platforms", []):
		_spawn_invisible_assist_platform(hotspot_pos)

	# Put nearby enemies to sleep after hotspot deaths
	_check_enemy_sleep_trigger(failure_position)

	var hint_text := str(result.get("hint", ""))
	if hint_text == "":
		return

	spawn_floating_text("Chip: " + hint_text, failure_position + Vector2(0, -48), Color(0.4, 0.85, 1.0))
	print("Smart Tutorial Whisperer hint: ", hint_text)


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
	var ghost := RUNTIME_GHOST_REPLAY_SCRIPT.build_ghost(run_record, active_player, sidecar, size, ASSET_ROOT)
	if ghost == null:
		return
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
		elif asset_id == "target_practice":
			trigger_type = "target_hit"

	print("notify_trigger called for: ", trigger_id, " type: ", trigger_type)
	execute_rules(trigger_type, trigger_id)
	_update_logic_gates_for_trigger(trigger_id, true)


func _update_logic_gates_for_trigger(trigger_id: String, active: bool) -> void:
	for entity in spawned_entities:
		if is_instance_valid(entity) and entity.has_method("set_input") and entity.has_meta("modifiers"):
			var mods = entity.get_meta("modifiers")
			if mods.has("logic_inputs"):
				var inputs = mods.get("logic_inputs")
				if typeof(inputs) == TYPE_ARRAY:
					var idx = inputs.find(trigger_id)
					if idx != -1:
						entity.set_input(idx + 1, active)


func _initialize_logic_gates() -> void:
	for entity in spawned_entities:
		if is_instance_valid(entity) and entity.has_method("set_input"):
			var mods = entity.get_meta("modifiers") if entity.has_meta("modifiers") else {}
			if mods.has("logic_inputs"):
				var inputs = mods.get("logic_inputs")
				if typeof(inputs) == TYPE_ARRAY:
					for idx in range(inputs.size()):
						var trigger_id = str(inputs[idx])
						var trigger_active = false
						for candidate in spawned_entities:
							if is_instance_valid(candidate) and candidate.name == trigger_id:
								if "output_state" in candidate:
									trigger_active = bool(candidate.get("output_state"))
								elif "is_pressed" in candidate:
									trigger_active = bool(candidate.get("is_pressed"))
								elif "active" in candidate:
									trigger_active = bool(candidate.get("active"))
						entity.set_input(idx + 1, trigger_active)


func execute_rules(trigger_type: String, trigger_id: String = "") -> void:
	_ensure_rule_executor()
	if rule_executor != null and is_instance_valid(rule_executor) and rule_executor.has_method("execute_rules"):
		rule_executor.execute_rules(room_rules, trigger_type, trigger_id)


func _on_portal_entered(portal_node: Node2D, portal_data: Dictionary) -> void:
	_ensure_progression_flow()
	progression_flow.portal_entered(portal_node, portal_data)


func _on_locked_door_entered(door_node: Node2D, door_data: Dictionary) -> void:
	_ensure_progression_flow()
	progression_flow.locked_door_entered(door_node, door_data)


func transition_to_room(target_room_name: String, target_portal_id: String) -> void:
	_ensure_progression_flow()
	progression_flow.transition_to_room(target_room_name, target_portal_id)


func check_victory_conditions() -> void:
	_ensure_progression_flow()
	progression_flow.check_victory_conditions()


func trigger_victory() -> void:
	_ensure_progression_flow()
	progression_flow.trigger_victory()


func trigger_game_over() -> void:
	_ensure_progression_flow()
	progression_flow.trigger_game_over()


func handle_player_death() -> void:
	_ensure_progression_flow()
	progression_flow.handle_player_death()


func clear_spawned_entities() -> void:
	_cleanup_audio_resources()
	for node in spawned_entities:
		if is_instance_valid(node):
			node.queue_free()
	spawned_entities.clear()
	active_player = null
	active_player_1 = null
	active_player_2 = null
	_ensure_hud_manager()
	if hud_manager != null and hud_manager.has_method("clear_hud"):
		hud_manager.clear_hud()
	_sync_hud_refs()


func on_collectible_picked_up(payload: Dictionary) -> void:
	var result: Dictionary = RUNTIME_COLLECTIBLE_REWARDS_SCRIPT.apply(
		payload,
		active_player,
		score,
		collectibles_collected,
		keys_collected
	)
	score = int(result.get("score", score))
	collectibles_collected = int(result.get("collectibles_collected", collectibles_collected))
	keys_collected = result.get("keys_collected", keys_collected)
	for event in result.get("events", []):
		_handle_collectible_reward_event(event)


func _handle_collectible_reward_event(event: Dictionary) -> void:
	var event_type := str(event.get("type", ""))
	if event_type == "score_log":
		print("Score: ", int(event.get("score", score)), "  (+", int(event.get("delta", 0)), ")")
	elif event_type == "text":
		spawn_floating_text(str(event.get("text", "")), event.get("position", Vector2.ZERO), event.get("color", Color.WHITE))
	elif event_type == "sfx":
		play_sfx(str(event.get("sfx", "coin")))
	elif event_type == "rule":
		execute_rules(str(event.get("rule", "")))
	elif event_type == "key":
		print("Key collected! %s keys of color '%s'" % [event.get("count", 0), str(event.get("key_color", "gold"))])


func _configure_camera_limits() -> void:
	_ensure_combat_traversal_glue()
	combat_traversal_glue.configure_camera_limits()


func _attach_camera(target: Node2D) -> void:
	_ensure_combat_traversal_glue()
	combat_traversal_glue.attach_camera(target)


func _placement_bucket(sidecar: Dictionary) -> String:
	return RUNTIME_WORLD_ENVIRONMENT_SCRIPT.placement_bucket(sidecar)


func _z_index_for_bucket(bucket: String) -> int:
	return RUNTIME_WORLD_ENVIRONMENT_SCRIPT.z_index_for_bucket(bucket)


func _apply_world_settings(settings: Dictionary) -> void:
	var applied: Dictionary = RUNTIME_WORLD_ENVIRONMENT_SCRIPT.apply_world_settings(self, settings)
	difficulty = str(applied.get("difficulty", "normal"))
	calm_mode = bool(applied.get("calm_mode", false))
	health_style = str(settings.get("health_style", "hearts"))
	camera_autoscroll_enabled = bool(applied.get("camera_autoscroll_enabled", false))
	turf_war_enabled = bool(applied.get("turf_war_enabled", false))
	
	card_battle_bonus = str(settings.get("card_battle_bonus", ""))
	if OS.has_feature("web"):
		var web_bonus = JavaScriptBridge.eval("window.parent.currentGameBonus || window.currentGameBonus || ''")
		if web_bonus:
			card_battle_bonus = str(web_bonus)
	game_speed_multiplier = float(applied.get("game_speed_multiplier", 1.0))
	if turf_war_enabled:
		turf_war_time_left = 180.0
		turf_war_ended = false
	camera_autoscroll_direction = str(applied.get("camera_autoscroll_direction", "right"))
	camera_autoscroll_speed = float(applied.get("camera_autoscroll_speed", 40.0))
	audio_debug = bool(applied.get("audio_debug", false))
	level_balancer_enabled = bool(applied.get("level_balancer_enabled", true))
	tutorial_whisperer_enabled = bool(applied.get("tutorial_whisperer_enabled", true))
	current_weather = str(applied.get("current_weather", "clear"))
	var spawned_nodes: Array = applied.get("spawned_nodes", [])
	spawned_entities.append_array(spawned_nodes)

	_ensure_audio_manager()
	if audio_manager != null:
		audio_manager.set("audio_debug", audio_debug)
		audio_manager.set("bpm_sequence", applied.get("bgm_sequence", []))
	room_rules = applied.get("room_rules", [])
	victory_rules = applied.get("victory_rules", {"win_condition": "all_enemies", "celebration": "confetti"})
	loss_rules = applied.get("loss_rules", {"lose_condition": "health_0", "action": "game_over"})
	_play_theme_bgm(str(applied.get("theme", "default")))


func _apply_lighting_if_needed(node: Node2D, sidecar: Dictionary) -> void:
	RUNTIME_WORLD_ENVIRONMENT_SCRIPT.apply_lighting_if_needed(node, sidecar)


func _apply_weather_particles() -> void:
	var spawned_nodes: Array = RUNTIME_WORLD_ENVIRONMENT_SCRIPT.apply_weather_particles(self, active_player, current_weather)
	spawned_entities.append_array(spawned_nodes)


func _apply_audio_if_needed(node: Node2D, sidecar: Dictionary) -> void:
	RUNTIME_WORLD_ENVIRONMENT_SCRIPT.apply_audio_if_needed(node, sidecar, ASSET_ROOT)


func get_paint_coverage_percentage() -> float:
	var total_terrain := 0
	var painted_terrain := 0
	for entity in spawned_entities:
		if is_instance_valid(entity):
			if entity.has_meta("runtime_template") and entity.get_meta("runtime_template") == "terrain":
				total_terrain += 1
				if entity.has_meta("paint_color") and entity.get_meta("paint_color") == "green":
					painted_terrain += 1
	if total_terrain > 0:
		return (float(painted_terrain) * 100.0) / float(total_terrain)
	return 0.0


func _process(delta: float) -> void:
	if turf_war_enabled and not turf_war_ended and active_player != null and is_instance_valid(active_player):
		turf_war_time_left -= delta
		if turf_war_time_left <= 0.0:
			turf_war_time_left = 0.0
			turf_war_ended = true
			var pct = get_paint_coverage_percentage()
			if pct >= 50.0:
				trigger_victory()
			else:
				trigger_game_over()

	_update_hud()

	# Boss Intro trigger check
	if not boss_intro_played and active_player != null and is_instance_valid(active_player):
		var boss = _find_active_boss()
		if boss != null and is_instance_valid(boss):
			var dist = active_player.global_position.distance_to(boss.global_position)
			if dist < 350.0:
				trigger_boss_intro(boss)

	# Smoothly lerp Engine.time_scale toward the target (struggle slow or recovery)
	if tutorial_whisperer_enabled:
		var current_ts := Engine.time_scale
		var ts_delta: float = delta * (1.0 / max(current_ts, 0.01))  # real-time delta
		Engine.time_scale = move_toward(current_ts, _struggle_time_scale_target, ts_delta * 0.5)
		# Gradually recover back to 1.0 when not struggling
		if _struggle_time_scale_target < 1.0 and respawn_count <= 1:
			_struggle_time_scale_target = move_toward(_struggle_time_scale_target, 1.0, delta * 0.05)

	# Ghost helper: show path hint after 30s stuck in same spot
	if tutorial_whisperer_enabled and active_player != null and is_instance_valid(active_player):
		_whisperer_state["stuck_last_pos"] = _whisperer_state.get("stuck_last_pos", active_player.global_position)
		var stuck_timer: float = float(_whisperer_state.get("stuck_timer", 0.0))
		var cur_pos: Vector2 = active_player.global_position
		var last_pos: Vector2 = _whisperer_state.get("stuck_last_pos", cur_pos)
		if cur_pos.distance_to(last_pos) > 50.0:
			_whisperer_state["stuck_last_pos"] = cur_pos
			_whisperer_state["stuck_timer"] = 0.0
		else:
			stuck_timer += delta
			_whisperer_state["stuck_timer"] = stuck_timer
			if stuck_timer >= 30.0:
				_whisperer_state["stuck_timer"] = 0.0
				_spawn_stuck_ghost_helper(cur_pos)

	_ensure_combat_traversal_glue()
	combat_traversal_glue.update_effects(delta)


func _find_active_boss() -> Node2D:
	_ensure_combat_traversal_glue()
	return combat_traversal_glue.find_active_boss()


func _find_camera() -> Camera2D:
	_ensure_combat_traversal_glue()
	return combat_traversal_glue.find_camera()


func play_dramatic_boss_chord() -> void:
	_ensure_combat_traversal_glue()
	combat_traversal_glue.play_dramatic_boss_chord()


func trigger_boss_intro(boss: Node2D) -> void:
	_ensure_combat_traversal_glue()
	combat_traversal_glue.trigger_boss_intro(boss)


func _create_hud() -> void:
	_ensure_hud_manager()
	if hud_manager != null and hud_manager.has_method("create_hud"):
		hud_manager.create_hud()
	_sync_hud_refs()


func _update_hud() -> void:
	_ensure_hud_manager()
	if hud_manager != null and hud_manager.has_method("update_hud"):
		hud_manager.update_hud()
	_sync_hud_refs()


func _show_boss_banner(boss: Node2D) -> void:
	_ensure_hud_manager()
	if hud_manager != null and hud_manager.has_method("show_boss_banner"):
		hud_manager.show_boss_banner(boss)
	_sync_hud_refs()

func play_sfx(type: String) -> void:
	_ensure_audio_manager()
	if audio_manager != null and audio_manager.has_method("play_sfx"):
		audio_manager.set("audio_debug", audio_debug)
		audio_manager.play_sfx(type)


func play_custom_sfx(asset_id: String, default_type: String = "") -> void:
	_ensure_audio_manager()
	if audio_manager != null and audio_manager.has_method("play_custom_sfx"):
		audio_manager.set("audio_debug", audio_debug)
		audio_manager.play_custom_sfx(asset_id, default_type)


func _stop_bgm() -> void:
	_ensure_audio_manager()
	if audio_manager != null and audio_manager.has_method("stop_bgm"):
		audio_manager.stop_bgm()


func _play_theme_bgm(theme: String) -> void:
	_ensure_audio_manager()
	if audio_manager != null and audio_manager.has_method("play_theme_bgm"):
		audio_manager.set("audio_debug", audio_debug)
		audio_manager.play_theme_bgm(theme)


func _make_trigger(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_trigger(self, data, sidecar, RUNTIME_TRIGGER_SCRIPT)


func _make_pressure_plate(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_pressure_plate(self, data, sidecar, RUNTIME_PRESSURE_PLATE_SCRIPT)


func notify_pressure_plate(trigger_id: String, is_pressed: bool) -> void:
	var trigger_type = "pressure_plate_on" if is_pressed else "pressure_plate_off"
	print("notify_pressure_plate called for: ", trigger_id, " type: ", trigger_type)
	execute_rules(trigger_type, trigger_id)
	_update_logic_gates_for_trigger(trigger_id, is_pressed)


func _make_gate(data: Dictionary, sidecar: Dictionary) -> AnimatableBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_gate(self, data, sidecar, RUNTIME_GATE_SCRIPT)


func _make_jelly(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_jelly(self, data, sidecar, RUNTIME_JELLY_SCRIPT)


func _make_speed_pad(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_speed_pad(self, data, sidecar, RUNTIME_SPEED_PAD_SCRIPT)


func _make_speech_sign(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_speech_sign(self, data, sidecar, RUNTIME_SPEECH_SIGN_SCRIPT)


func _make_water_block(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_water_block(self, data, sidecar, RUNTIME_WATER_BLOCK_SCRIPT)


func _make_crumbling_cloud(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_crumbling_cloud(self, data, sidecar, RUNTIME_CRUMBLING_CLOUD_SCRIPT)


func _make_hazard(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_hazard(self, data, sidecar, RUNTIME_HAZARD_SCRIPT)


func _make_conveyor(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_conveyor(self, data, sidecar, RUNTIME_CONVEYOR_SCRIPT)


func _make_mystery_box(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_mystery_box(self, data, sidecar, RUNTIME_MYSTERY_BOX_SCRIPT)


func _make_gravity_zone(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_gravity_zone(self, data, sidecar, RUNTIME_GRAVITY_ZONE_SCRIPT)


func _make_pet(data: Dictionary, sidecar: Dictionary) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_pet(self, data, sidecar, RUNTIME_PET_SCRIPT)


func _make_shopkeeper(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_shopkeeper(self, data, sidecar, RUNTIME_SHOPKEEPER_SCRIPT)


func _make_ambient_creature(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	var node := CharacterBody2D.new()
	var size: Vector2 = _collision_size(sidecar, Vector2(24, 24), data)
	_add_box_collision(node, size)
	node.set_meta("asset_id", data.get("asset_id", "ambient_butterfly"))
	node.set_meta("collision_size", size)
	var type := "butterfly"
	if str(data.get("asset_id", "")).contains("squirrel"):
		type = "squirrel"
	node.set_meta("creature_type", type)
	node.set_script(RUNTIME_AMBIENT_CREATURE_SCRIPT)
	return node


func _make_destructible_terrain(data: Dictionary, sidecar: Dictionary) -> StaticBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_destructible_terrain(self, data, sidecar, RUNTIME_DESTRUCTIBLE_TERRAIN_SCRIPT)


func open_shop_ui(shop_node: Node2D = null) -> void:
	if get_tree().paused:
		return
	print("SHOP OPENED!")
	play_sfx("coin")
	RUNTIME_PANEL_FACTORY_SCRIPT.create_shop(self, shop_node, score)
	get_tree().paused = true


func _attempt_shop_purchase(item: Dictionary, overlay: CanvasLayer) -> void:
	var result: Dictionary = RUNTIME_COMMERCE_SCRIPT.attempt_shop_purchase(item, active_player, score)
	score = int(result.get("score", score))
	for event in result.get("events", []):
		_handle_collectible_reward_event(event)
	if bool(result.get("close_overlay", false)):
		_update_hud()
		_close_panel_overlay(overlay)


func open_anvil_ui() -> void:
	if get_tree().paused:
		return
	print("ANVIL UPGRADE OPENED!")
	play_sfx("coin")
	RUNTIME_PANEL_FACTORY_SCRIPT.create_anvil(self, active_player)
	get_tree().paused = true


func _attempt_anvil_upgrade(overlay: CanvasLayer, weapon_level: int) -> void:
	var result: Dictionary = RUNTIME_COMMERCE_SCRIPT.attempt_anvil_upgrade(self, active_player, weapon_level)
	for event in result.get("events", []):
		_handle_collectible_reward_event(event)
	if bool(result.get("close_overlay", false)):
		_close_panel_overlay(overlay)


func _close_panel_overlay(overlay: CanvasLayer) -> void:
	get_tree().paused = false
	if overlay != null and is_instance_valid(overlay):
		overlay.queue_free()


func _remove_backpack_item_by_type(player, item_type: String) -> void:
	RUNTIME_COMMERCE_SCRIPT.remove_backpack_item_by_type(player, item_type)


func _spawn_recovery_ghost(pos: Vector2, lost_coins: int, lost_emeralds: int = 0) -> void:
	RUNTIME_RECOVERY_GHOST_FACTORY_SCRIPT.remove_existing(self)
	var area := RUNTIME_RECOVERY_GHOST_FACTORY_SCRIPT.create(pos, lost_coins, lost_emeralds, RUNTIME_RECOVERY_GHOST_SCRIPT)
	add_child(area)
	RUNTIME_RECOVERY_GHOST_FACTORY_SCRIPT.animate(self, area)


func _make_palico(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_palico(self, data, sidecar, RUNTIME_PALICO_SCRIPT)


func _make_rush_adapter(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_rush_adapter(self, data, sidecar, RUNTIME_RUSH_ADAPTER_SCRIPT)


func _make_anvil(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_interaction_station(self, data, sidecar, Color(0.3, 0.3, 0.35), "⚒️ UPGRADE", "open_anvil_ui", RUNTIME_INTERACTION_STATION_SCRIPT)


func _make_compass(_data: Dictionary, _sidecar: Dictionary) -> Node2D:
	var node := Node2D.new()
	node.set_script(RUNTIME_COMPASS_SCRIPT)
	return node


func _check_and_spawn_rising_hazard(settings: Dictionary) -> void:
	RUNTIME_RISING_HAZARD_FACTORY_SCRIPT.spawn_from_settings(self, spawned_entities, death_y_threshold, settings, RUNTIME_RISING_HAZARD_SCRIPT)


func _make_wind_zone(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_wind_zone(self, data, sidecar, RUNTIME_WIND_ZONE_SCRIPT)


func _make_target_practice(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_target_practice(self, data, sidecar, RUNTIME_TARGET_PRACTICE_SCRIPT)


func _make_chemistry_block(data: Dictionary, sidecar: Dictionary, type: String) -> StaticBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_chemistry_block(self, data, sidecar, type)


func _make_zonai_device(data: Dictionary, sidecar: Dictionary, type: String) -> StaticBody2D:
	return RUNTIME_ZONAI_DEVICE_FACTORY_SCRIPT.create(self, data, sidecar, type, RUNTIME_ZONAI_SPRING_SCRIPT, RUNTIME_ZONAI_BEAM_SCRIPT)


func _make_pikmin(data: Dictionary, sidecar: Dictionary) -> CharacterBody2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_pikmin(self, data, sidecar, RUNTIME_PIKMIN_SCRIPT)


func _make_ghost(data: Dictionary, sidecar: Dictionary) -> Node2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_ghost(self, data, sidecar, RUNTIME_GHOST_COMPANION_SCRIPT)


func _make_crafting_bench(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_interaction_station(self, data, sidecar, Color(0.6, 0.45, 0.3), "🔨 CRAFT", "open_crafting_ui", RUNTIME_INTERACTION_STATION_SCRIPT)


func _make_bbq_spit(data: Dictionary, sidecar: Dictionary) -> Area2D:
	return RUNTIME_GAMEPLAY_OBJECT_FACTORY_SCRIPT.create_interaction_station(self, data, sidecar, Color(0.85, 0.3, 0.1), "🍖 COOK", "open_cooking_ui", RUNTIME_INTERACTION_STATION_SCRIPT)


func _build_physics_contraptions() -> void:
	RUNTIME_CONTRAPTION_BUILDER_SCRIPT.build(self, spawned_entities, contraptions)


func _process_elemental_chemistry() -> void:
	RUNTIME_ELEMENTAL_CHEMISTRY_SCRIPT.process(self, active_player)


func toggle_backpack_ui() -> void:
	if backpack_ui != null:
		backpack_ui.queue_free()
		backpack_ui = null
		if active_player != null and is_instance_valid(active_player):
			active_player.backpack_open = false
		get_tree().paused = false
	else:
		if active_player != null and is_instance_valid(active_player):
			active_player.backpack_open = true
		get_tree().paused = true

		backpack_ui = RUNTIME_PANEL_FACTORY_SCRIPT.create_backpack(self)


var active_cooking_modifiers: Dictionary = {}
var active_crafting_modifiers: Dictionary = {}

func open_crafting_ui(station: Node = null) -> void:
	if crafting_ui != null: return
	get_tree().paused = true
	if station != null and station.has_meta("modifiers"):
		active_crafting_modifiers = station.get_meta("modifiers")
	else:
		active_crafting_modifiers = {}
	crafting_ui = RUNTIME_PANEL_FACTORY_SCRIPT.create_crafting(self)


func close_crafting_ui() -> void:
	if crafting_ui != null:
		crafting_ui.queue_free()
		crafting_ui = null
		get_tree().paused = false


func open_cooking_ui(station: Node = null) -> void:
	if cooking_ui != null: return
	get_tree().paused = true
	if station != null and station.has_meta("modifiers"):
		active_cooking_modifiers = station.get_meta("modifiers")
	else:
		active_cooking_modifiers = {}
	cooking_ui = RUNTIME_PANEL_FACTORY_SCRIPT.create_cooking(self)


func close_cooking_ui() -> void:
	if cooking_ui != null:
		cooking_ui.queue_free()
		cooking_ui = null
		get_tree().paused = false


func trigger_screen_shake(amplitude: float, duration: float) -> void:
	_ensure_combat_traversal_glue()
	combat_traversal_glue.trigger_screen_shake(amplitude, duration)


func trigger_hit_stop(duration: float) -> void:
	_ensure_combat_traversal_glue()
	combat_traversal_glue.trigger_hit_stop(duration)


## _attach_visual_progression
## Called from RuntimeEntitySpawner right after active_player is set.
## Adds a RuntimeVisualProgression child node to the player.
func _attach_visual_progression(player: Node2D) -> void:
	# Remove any old progression node (e.g., on room reload)
	var old := player.get_node_or_null("RuntimeVisualProgression")
	if old != null and is_instance_valid(old):
		old.queue_free()

	var prog := RUNTIME_VISUAL_PROGRESSION_SCRIPT.new()
	prog.name = "RuntimeVisualProgression"
	player.add_child(prog)
	print("Visual progression tracker attached to player.")


## notify_enemy_defeated
## Call when any enemy dies. Advances the player's visual progression tier.
## SmartEnemy.die() calls check_victory_conditions() via call_deferred — we
## intercept here through a direct call from SmartEnemy.die().
func notify_enemy_defeated() -> void:
	if active_player == null or not is_instance_valid(active_player):
		return
	var prog := active_player.get_node_or_null("RuntimeVisualProgression")
	if prog != null and is_instance_valid(prog) and prog.has_method("on_enemy_defeated"):
		prog.on_enemy_defeated()


## _spawn_invisible_assist_platform
## Creates a ghost-transparent StaticBody2D below a death hotspot.
## The child thinks they "got lucky" — the platform is nearly invisible at 15% opacity.
func _spawn_invisible_assist_platform(hotspot_pos: Vector2) -> void:
	var tag := "AssistPlatform_%d_%d" % [int(hotspot_pos.x), int(hotspot_pos.y)]
	if get_node_or_null(tag) != null:
		return  # Already spawned for this hotspot

	var body := StaticBody2D.new()
	body.name = tag
	body.collision_layer = 1
	body.collision_mask = 0
	# Place it 32px below the death point so it catches falls
	body.global_position = hotspot_pos + Vector2(0, 32)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(96, 12)
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)

	# Nearly invisible visual — white rectangle at 15% opacity
	var rect := ColorRect.new()
	rect.color = Color(1.0, 1.0, 0.9, 0.15)
	rect.size = Vector2(96, 12)
	rect.position = Vector2(-48, -6)
	body.add_child(rect)

	body.set_meta("is_assist_platform", true)
	add_child(body)
	spawned_entities.append(body)
	print("Invisible assist platform spawned at ", hotspot_pos)


## _check_enemy_sleep_trigger
## After 3+ deaths near an enemy, put that enemy to sleep.
func _check_enemy_sleep_trigger(failure_position: Vector2) -> void:
	if respawn_count < 3:
		return
	for entity in spawned_entities:
		if not is_instance_valid(entity):
			continue
		if not entity.has_method("put_to_sleep"):
			continue
		if entity.get("is_sleeping") == true:
			continue
		if entity.global_position.distance_to(failure_position) <= 180.0:
			entity.put_to_sleep()
			print("Enemy put to sleep near death hotspot: ", entity.name)


## _spawn_stuck_ghost_helper
## Shows a translucent firefly companion for 2 seconds when the child is stuck.
func _spawn_stuck_ghost_helper(stuck_pos: Vector2) -> void:
	# Don't stack helpers
	var existing := get_node_or_null("StuckGhostHelper")
	if existing != null and is_instance_valid(existing):
		return

	var label := Label.new()
	label.name = "StuckGhostHelper"
	label.text = "✨"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ls := LabelSettings.new()
	ls.font_size = 36
	ls.outline_size = 2
	ls.outline_color = Color.BLACK
	label.label_settings = ls
	label.modulate = Color(1.0, 1.0, 0.6, 0.85)
	label.global_position = stuck_pos + Vector2(-18, -64)
	add_child(label)

	# Drift upward then fade out after 2s
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", stuck_pos.y - 100.0, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 0.0, 2.0).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(label.queue_free)
	spawn_floating_text("Try going another way!", stuck_pos + Vector2(0, -80), Color(1.0, 0.9, 0.4))


# --- Celestial Brush (Okami) ---

func toggle_celestial_brush() -> void:
	brush_active = not brush_active
	if brush_active:
		Engine.time_scale = 0.0
		
		# Spawn visual line node to draw with
		brush_line_node = Line2D.new()
		brush_line_node.width = 6.0
		brush_line_node.default_color = Color(0.2, 0.8, 1.0, 0.85)
		add_child(brush_line_node)
		
		# Create an overlay label
		brush_overlay_label = Label.new()
		brush_overlay_label.text = "🖌️ CELESTIAL BRUSH ACTIVATED! 🖌️\nDraw on screen to perform miracles!\n- STRAIGHT SLASH: Defeat Hazards & Enemies\n- LOOP CIRCLE: Bloom Platform / Heal Self\n- WIND SPIRAL: Summon Wind Gale Updraft\n(Press [B] to Cancel)"
		brush_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		brush_overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var settings := LabelSettings.new()
		settings.font_size = 20
		settings.font_color = Color(0.2, 0.9, 1.0)
		settings.outline_size = 4
		settings.outline_color = Color.BLACK
		brush_overlay_label.label_settings = settings
		
		var viewport_size := get_viewport_rect().size
		brush_overlay_label.size = Vector2(700, 150)
		brush_overlay_label.position = (viewport_size - brush_overlay_label.size) / 2.0
		brush_overlay_label.position.y = 80
		
		var hud = get_node_or_null("HudCanvas")
		if hud != null:
			hud.add_child(brush_overlay_label)
		else:
			add_child(brush_overlay_label)
		
		if has_method("play_sfx"):
			play_sfx("coin")
			
		spawn_floating_text("🖌️ CELESTIAL BRUSH ON 🖌️", active_player.global_position if active_player else Vector2.ZERO, Color.CYAN)
	else:
		_deactivate_brush()


func _deactivate_brush() -> void:
	brush_active = false
	Engine.time_scale = game_speed_multiplier
	
	if brush_line_node != null and is_instance_valid(brush_line_node):
		var line_tween = create_tween()
		line_tween.tween_property(brush_line_node, "modulate:a", 0.0, 0.3)
		var old_line := brush_line_node
		line_tween.tween_callback(old_line.queue_free)
		brush_line_node = null
		
	if brush_overlay_label != null and is_instance_valid(brush_overlay_label):
		brush_overlay_label.queue_free()
		brush_overlay_label = null


func _classify_stroke(points: Array) -> String:
	if points.size() < 10:
		return ""
	
	var total_len := 0.0
	for i in range(points.size() - 1):
		total_len += points[i].distance_to(points[i+1])
	if total_len < 60.0:
		return ""
		
	var start: Vector2 = points[0]
	var end: Vector2 = points[points.size() - 1]
	var start_end_dist := start.distance_to(end)
	
	# Calculate bounding box & centroid
	var min_x: float = points[0].x
	var max_x: float = points[0].x
	var min_y: float = points[0].y
	var max_y: float = points[0].y
	var avg := Vector2.ZERO
	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
		avg += p
	avg /= points.size()
	
	# Calculate cumulative angle change around average center
	var cumulative_angle: float = 0.0
	var prev_angle: float = (points[0] - avg).angle()
	for i in range(1, points.size()):
		var curr_angle: float = (points[i] - avg).angle()
		var diff: float = curr_angle - prev_angle
		# Normalize diff to [-PI, PI]
		while diff < -PI: diff += 2.0 * PI
		while diff > PI: diff -= 2.0 * PI
		cumulative_angle += diff
		prev_angle = curr_angle
		
	var abs_angle: float = abs(cumulative_angle)
	print("Stroke classification details: dist=", start_end_dist, " len=", total_len, " angle=", abs_angle)
	
	# Heuristics:
	# 1. Straight Slash: High end-to-end ratio, low rotation
	if (start_end_dist / total_len) > 0.70 and abs_angle < 3.0:
		return "slash"
	# 2. Spiral: High rotation winding
	if abs_angle >= 7.0:
		return "spiral"
	# 3. Circle: Moderate rotation winding, start and end points close enough
	if abs_angle >= 3.8:
		return "circle"
		
	return ""


func _execute_brush_miracle(gesture: String, points: Array) -> void:
	if gesture == "":
		var center_pos = points[points.size() / 2]
		spawn_floating_text("❌ UNKNOWN MIRACLE", center_pos, Color.RED)
		if has_method("play_sfx"):
			play_sfx("coin")
		return
		
	var avg := Vector2.ZERO
	for p in points:
		avg += p
	avg /= points.size()
	
	if gesture == "slash":
		var hit_count := 0
		for entity in spawned_entities.duplicate():
			if is_instance_valid(entity):
				var is_target = false
				if entity.has_meta("runtime_template"):
					var template = entity.get_meta("runtime_template")
					if template == "enemy" or template == "hazard" or template == "destructible_terrain":
						is_target = true
				
				if is_target:
					var hit := false
					for p in points:
						if entity.global_position.distance_to(p) < 64.0:
							hit = true
							break
					if hit:
						hit_count += 1
						if entity.has_method("take_damage"):
							entity.call("take_damage", 100)
						else:
							entity.queue_free()
							if spawned_entities.has(entity):
								spawned_entities.erase(entity)
		
		spawn_floating_text("✨ SLASH DETECTED! Hit %d targets ✨" % hit_count, avg, Color.CHARTREUSE)
		if has_method("play_sfx"):
			play_sfx("coin")
			
	elif gesture == "circle":
		var healed_player := false
		if active_player != null and is_instance_valid(active_player):
			var player_dist := active_player.global_position.distance_to(avg)
			if player_dist < 150.0:
				var max_hp = active_player.get("max_health") if "max_health" in active_player else 100
				active_player.set("current_health", max_hp)
				healed_player = true
				
		if healed_player:
			spawn_floating_text("🌸 HEALED SELF! 🌸", active_player.global_position, Color.MAGENTA)
		else:
			# Spawn bloom block
			var bloom_block = StaticBody2D.new()
			bloom_block.global_position = avg
			
			var col_shape := CollisionShape2D.new()
			var rect_shape := RectangleShape2D.new()
			rect_shape.size = Vector2(96, 32)
			col_shape.shape = rect_shape
			bloom_block.add_child(col_shape)
			
			var color_rect := ColorRect.new()
			color_rect.color = Color(0.15, 0.75, 0.35, 0.9)
			color_rect.size = Vector2(96, 32)
			color_rect.position = -Vector2(48, 16)
			bloom_block.add_child(color_rect)
			
			var flower_label := Label.new()
			flower_label.text = "🌸 BLOOM 🌸"
			flower_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			flower_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var settings := LabelSettings.new()
			settings.font_size = 11
			settings.outline_size = 2
			settings.outline_color = Color.BLACK
			flower_label.label_settings = settings
			flower_label.size = Vector2(96, 32)
			flower_label.position = -Vector2(48, 16)
			bloom_block.add_child(flower_label)
			
			bloom_block.set_meta("runtime_template", "terrain")
			add_child(bloom_block)
			spawned_entities.append(bloom_block)
			
			get_tree().create_timer(5.0).timeout.connect(func():
				if is_instance_valid(bloom_block):
					var tween = create_tween()
					tween.tween_property(bloom_block, "modulate:a", 0.0, 0.5)
					tween.tween_callback(func():
						bloom_block.queue_free()
						if spawned_entities.has(bloom_block):
							spawned_entities.erase(bloom_block)
					)
			)
			
			spawn_floating_text("🌸 BLOOM BLOCK SPAWNED! 🌸", avg, Color.GREEN)
		if has_method("play_sfx"):
			play_sfx("coin")
			
	elif gesture == "spiral":
		var wind_zone = Area2D.new()
		wind_zone.global_position = avg
		wind_zone.set_script(load("res://scripts/RuntimeWindZone.gd"))
		wind_zone.set("force_vector", Vector2(0, -900.0))
		
		var col_shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = Vector2(180, 240)
		col_shape.shape = rect_shape
		wind_zone.add_child(col_shape)
		
		var particles := CPUParticles2D.new()
		particles.amount = 35
		particles.lifetime = 1.0
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		particles.emission_rect_extents = Vector2(90, 10)
		particles.direction = Vector2(0, -1)
		particles.gravity = Vector2.ZERO
		particles.initial_velocity_min = 180.0
		particles.initial_velocity_max = 280.0
		particles.color = Color(0.5, 0.85, 1.0, 0.65)
		particles.scale_amount_min = 2.0
		particles.scale_amount_max = 5.0
		particles.position = Vector2(0, 120)
		wind_zone.add_child(particles)
		particles.emitting = true
		
		add_child(wind_zone)
		spawned_entities.append(wind_zone)
		
		get_tree().create_timer(8.0).timeout.connect(func():
			if is_instance_valid(wind_zone):
				var tween = create_tween()
				tween.tween_property(wind_zone, "modulate:a", 0.0, 0.5)
				tween.tween_callback(func():
					wind_zone.queue_free()
					if spawned_entities.has(wind_zone):
						spawned_entities.erase(wind_zone)
				)
		)
		
		spawn_floating_text("🌀 WIND GALE SUMMONED! 🌀", avg, Color.CYAN)
		if has_method("play_sfx"):
			play_sfx("jump")
