extends RefCounted


static func apply(level_data: Dictionary, current_level_balancer: bool, current_tutorial_whisperer: bool) -> Dictionary:
	var movement_config := _merge_contract(
		level_data.get("movement_system", {}),
		_default_movement_system_contract()
	)
	var combat_config := _merge_contract(
		level_data.get("combat_system", {}),
		_default_combat_system_contract()
	)
	var rules_config := _merge_contract(
		level_data.get("rules_engine", {}),
		_default_rules_engine_contract()
	)
	var ai_config := _merge_contract(
		level_data.get("ai_assist", {}),
		_default_ai_assist_contract()
	)

	return {
		"schema_version": str(level_data.get("schema_version", "1")),
		"movement_system": movement_config,
		"combat_system": combat_config,
		"rules_engine": rules_config,
		"ai_assist": ai_config,
		"level_balancer_enabled": bool(ai_config.get("level_balancer", current_level_balancer)),
		"tutorial_whisperer_enabled": bool(ai_config.get("tutorial_whisperer", current_tutorial_whisperer))
	}


static func _merge_contract(input_value: Variant, fallback: Dictionary) -> Dictionary:
	var merged := fallback.duplicate(true)
	if typeof(input_value) != TYPE_DICTIONARY:
		return merged
	var input_dict: Dictionary = input_value
	for key in input_dict.keys():
		var value: Variant = input_dict[key]
		if typeof(value) == TYPE_DICTIONARY and typeof(merged.get(key, null)) == TYPE_DICTIONARY:
			var nested: Dictionary = merged.get(key).duplicate(true)
			var nested_input: Dictionary = value
			for nested_key in nested_input.keys():
				nested[nested_key] = nested_input[nested_key]
			merged[key] = nested
		else:
			merged[key] = value
	return merged


static func _meta(feature_domain: String) -> Dictionary:
	return {
		"feature_domain": feature_domain,
		"minimum_schema_version": "2.0.0"
	}


static func _default_movement_system_contract() -> Dictionary:
	return {
		"_meta": _meta("movement_system"),
		"enabled": true,
		"movement_ids": ["wall_jump", "double_jump", "dash", "glide", "ledge_grab", "ground_pound"],
		"params": {
			"dash_cooldown_seconds": 1.2,
			"dash_duration_seconds": 0.2,
			"wall_cling_seconds": 0.3,
			"glide_stamina_seconds": 4.0,
			"ground_pound_speed": 900
		}
	}


static func _default_combat_system_contract() -> Dictionary:
	return {
		"_meta": _meta("combat_system"),
		"enabled": true,
		"mechanics": ["sword_combo", "charge_shot", "parry", "shield_block"],
		"params": {
			"combo_steps": 3,
			"combo_reset_seconds": 1.0,
			"parry_window_seconds": 0.18,
			"charge_shot_full_seconds": 1.0
		}
	}


static func _default_rules_engine_contract() -> Dictionary:
	return {
		"_meta": _meta("rules_engine"),
		"enabled": true,
		"primitives": ["switch_door", "key_lock", "pressure_plate", "collectible_counter", "win_condition"]
	}


static func _default_ai_assist_contract() -> Dictionary:
	return {
		"_meta": _meta("ai_assist"),
		"level_balancer": true,
		"tutorial_whisperer": true
	}
