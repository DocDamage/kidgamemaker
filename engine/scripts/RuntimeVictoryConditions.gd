extends RefCounted


static func should_trigger_victory(victory_rules: Dictionary, spawned_entities: Array) -> Dictionary:
	var win_condition := str(victory_rules.get("win_condition", "all_enemies"))
	if win_condition == "all_enemies":
		var enemies_left := _count_enemies(spawned_entities)
		return {
			"should_trigger": enemies_left == 0,
			"metric_name": "Enemies left",
			"metric_value": enemies_left,
			"win_condition": win_condition,
		}
	elif win_condition == "all_coins":
		var coins_left := _count_collectibles(spawned_entities)
		return {
			"should_trigger": coins_left == 0,
			"metric_name": "Coins/Gems left",
			"metric_value": coins_left,
			"win_condition": win_condition,
		}

	return {
		"should_trigger": false,
		"metric_name": "",
		"metric_value": 0,
		"win_condition": win_condition,
	}


static func _count_enemies(spawned_entities: Array) -> int:
	var enemies_left := 0
	for ent in spawned_entities:
		if is_instance_valid(ent) and ent.has_method("take_damage") and not ent.name.begins_with("Player"):
			var asset_id_meta = ent.get_meta("asset_id") if ent.has_meta("asset_id") else ""
			if not asset_id_meta.begins_with("pet_") and not ent.name.begins_with("pet_"):
				enemies_left += 1
	return enemies_left


static func _count_collectibles(spawned_entities: Array) -> int:
	var coins_left := 0
	for ent in spawned_entities:
		if is_instance_valid(ent) and ent.has_meta("is_collectible"):
			var asset_id = str(ent.get("asset_id")) if "asset_id" in ent else ""
			if not asset_id.contains("key"):
				coins_left += 1
	return coins_left
