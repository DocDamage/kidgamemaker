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


func auto_connect_proximity_triggers(room_rules: Array) -> void:
	if runtime == null or not is_instance_valid(runtime):
		return

	var spawned_entities: Array = runtime.get("spawned_entities")
	var triggers: Array[Node2D] = []
	var gates: Array[Node2D] = []

	for entity in spawned_entities:
		if not is_instance_valid(entity) or not (entity is Node2D):
			continue
		
		var node = entity as Node2D
		var asset_id = ""
		if node.has_meta("asset_id"):
			asset_id = str(node.get_meta("asset_id"))
		
		if asset_id in ["trigger_button", "trigger_lever", "trigger_pressure_plate"]:
			triggers.append(node)
		elif asset_id in ["gate_block", "locked_gate_red", "locked_gate_blue"] or node.has_method("toggle_gate"):
			gates.append(node)

	for trigger in triggers:
		var trigger_id = trigger.name
		var has_existing_rule = false
		for rule in room_rules:
			if typeof(rule) == TYPE_DICTIONARY and str(rule.get("trigger_id", "")) == trigger_id:
				has_existing_rule = true
				break
		
		if has_existing_rule:
			continue

		var closest_gate: Node2D = null
		var min_dist := 128.0
		for gate in gates:
			var dist = trigger.global_position.distance_to(gate.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_gate = gate

		if closest_gate != null:
			var trigger_type := "button_step"
			var asset_id = str(trigger.get_meta("asset_id")) if trigger.has_meta("asset_id") else ""
			if asset_id == "trigger_lever":
				trigger_type = "lever_flip"
			elif asset_id == "trigger_pressure_plate":
				trigger_type = "pressure_plate_on"
			
			if trigger_type == "pressure_plate_on":
				var rule_on = {
					"trigger_type": "pressure_plate_on",
					"trigger_id": trigger_id,
					"action_type": "toggle_gate",
					"action_id": closest_gate.name
				}
				var rule_off = {
					"trigger_type": "pressure_plate_off",
					"trigger_id": trigger_id,
					"action_type": "toggle_gate",
					"action_id": closest_gate.name
				}
				room_rules.append(rule_on)
				room_rules.append(rule_off)
			else:
				var auto_rule = {
					"trigger_type": trigger_type,
					"trigger_id": trigger_id,
					"action_type": "toggle_gate",
					"action_id": closest_gate.name
				}
				room_rules.append(auto_rule)
			print("Proximity Auto-Connect: Created rules linking trigger ", trigger_id, " to gate ", closest_gate.name)

