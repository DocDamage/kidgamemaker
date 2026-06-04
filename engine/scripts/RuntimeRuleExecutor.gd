extends Node

var runtime: Node = null


func configure(main_runtime: Node) -> void:
	runtime = main_runtime


func execute_rules(room_rules: Array, trigger_type: String, trigger_id: String = "") -> void:
	if runtime == null or not is_instance_valid(runtime):
		return

	for rule in room_rules:
		if typeof(rule) != TYPE_DICTIONARY:
			continue
		if not _rule_matches(rule, trigger_type, trigger_id):
			continue

		var action_type := str(rule.get("action_type", ""))
		var action_id := str(rule.get("action_id", ""))
		print("Rule matched! Trigger: ", trigger_type, " Action: ", action_type, " Target: ", action_id)
		_execute_action(action_type, action_id)


func _rule_matches(rule: Dictionary, trigger_type: String, trigger_id: String) -> bool:
	var rule_trigger_type := str(rule.get("trigger_type", ""))
	if rule_trigger_type != trigger_type:
		return false

	if _trigger_requires_id(rule_trigger_type):
		return str(rule.get("trigger_id", "")) == trigger_id

	return true


func _trigger_requires_id(trigger_type: String) -> bool:
	return trigger_type in [
		"button_step",
		"lever_flip",
		"target_hit",
		"pressure_plate_on",
		"pressure_plate_off",
		"logic_gate_on",
		"logic_gate_off"
	]


func _execute_action(action_type: String, action_id: String) -> void:
	match action_type:
		"toggle_gate":
			_toggle_gate(action_id)
		"spawn_sparkles":
			_spawn_sparkles()
		"heal_player":
			_heal_player()
		"play_sfx_chime":
			if runtime.has_method("play_sfx"):
				runtime.play_sfx("coin")
		"set_logic_input_1_on":
			_set_logic_input(action_id, 1, true)
		"set_logic_input_1_off":
			_set_logic_input(action_id, 1, false)
		"set_logic_input_2_on":
			_set_logic_input(action_id, 2, true)
		"set_logic_input_2_off":
			_set_logic_input(action_id, 2, false)


func _toggle_gate(action_id: String) -> void:
	var gate := _find_action_node(action_id, "toggle_gate")
	if gate != null:
		gate.toggle_gate()


func _spawn_sparkles() -> void:
	var active_player = runtime.get("active_player")
	if active_player == null or not is_instance_valid(active_player):
		return
	if not runtime.has_method("spawn_entity"):
		return

	var particles_data := {
		"asset_id": "effects_sparkles",
		"category": "particles",
		"position": {"x": active_player.global_position.x, "y": active_player.global_position.y},
		"modifiers": {"particle_theme": "rainbow", "particle_intensity": "wild"}
	}
	var particle_node = runtime.spawn_entity(particles_data)
	if particle_node != null:
		var tween := create_tween()
		tween.tween_interval(1.5)
		tween.tween_callback(particle_node.queue_free)


func _heal_player() -> void:
	var active_player = runtime.get("active_player")
	if active_player != null and is_instance_valid(active_player) and active_player.has_method("heal"):
		active_player.heal(20)


func _set_logic_input(action_id: String, index: int, value: bool) -> void:
	var gate := _find_action_node(action_id, "set_input")
	if gate != null:
		gate.set_input(index, value)


func _find_action_node(action_id: String, method_name: String) -> Node:
	if action_id == "":
		return null

	var direct_node := runtime.get_node_or_null(action_id)
	if direct_node != null and direct_node.has_method(method_name):
		return direct_node

	var spawned_entities: Array = runtime.get("spawned_entities")
	for entity in spawned_entities:
		if is_instance_valid(entity) and entity.name == action_id and entity.has_method(method_name):
			return entity

	return null
