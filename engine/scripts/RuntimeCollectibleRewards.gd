extends RefCounted

const MATERIAL_REWARDS := {
	"mat_metal_scrap": {"property": "metal_scrap", "text": "+1 Metal Scrap 🔩", "color": Color.LIGHT_GRAY},
	"mat_fire_powder": {"property": "fire_powder", "text": "+1 Fire Powder 🌶️", "color": Color.ORANGE},
	"mat_green_herb": {"property": "green_herb", "text": "+1 Green Herb 🌿", "color": Color.GREEN},
	"mat_sweet_honey": {"property": "sweet_honey", "text": "+1 Sweet Honey 🍯", "color": Color.GOLD},
}


static func apply(payload: Dictionary, active_player: Node2D, score: int, collectibles_collected: int, keys_collected: Dictionary) -> Dictionary:
	var events := []
	var score_value := int(payload.get("score_value", 0))
	score += score_value
	if score_value > 0:
		events.append({"type": "score_log", "score": score, "delta": score_value})

	var asset_id := str(payload.get("asset_id", ""))
	var blocked_by_full_backpack := false
	if asset_id == "star_piece":
		_apply_star_piece(active_player, events)

	if MATERIAL_REWARDS.has(asset_id):
		blocked_by_full_backpack = not _apply_material(active_player, asset_id, events)

	if blocked_by_full_backpack:
		return {
			"score": score,
			"collectibles_collected": collectibles_collected,
			"keys_collected": keys_collected,
			"events": events,
		}

	if not asset_id.contains("key") and not asset_id.begins_with("mat_"):
		collectibles_collected += 1
		if collectibles_collected == 5:
			events.append({"type": "rule", "rule": "coins_5"})
		elif collectibles_collected == 10:
			events.append({"type": "rule", "rule": "coins_10"})

	if asset_id.contains("key") or payload.has("key_color"):
		var key_color := str(payload.get("key_color", "gold"))
		keys_collected[key_color] = keys_collected.get(key_color, 0) + 1
		events.append({"type": "key", "key_color": key_color, "count": keys_collected[key_color]})
		events.append({"type": "sfx", "sfx": "coin"})

	return {
		"score": score,
		"collectibles_collected": collectibles_collected,
		"keys_collected": keys_collected,
		"events": events,
	}


static func _apply_star_piece(active_player: Node2D, events: Array) -> void:
	if active_player == null or not is_instance_valid(active_player) or not "star_pieces" in active_player:
		return
	active_player.star_pieces += 1
	events.append({
		"type": "text",
		"text": "🌟 STAR PIECE (" + str(active_player.star_pieces) + "/5) 🌟",
		"position": active_player.global_position,
		"color": Color.GOLD,
	})
	events.append({"type": "sfx", "sfx": "coin"})
	if active_player.star_pieces >= 5:
		active_player.star_pieces = 0
		if active_player.has_method("activate_star_mode"):
			active_player.activate_star_mode()


static func _apply_material(active_player: Node2D, asset_id: String, events: Array) -> bool:
	if active_player == null or not is_instance_valid(active_player):
		return true
	var fits = active_player.add_to_backpack(asset_id)
	if not fits:
		events.append({
			"type": "text",
			"text": "🎒 BACKPACK FULL!",
			"position": active_player.global_position,
			"color": Color.ORANGE,
		})
		return false

	var reward: Dictionary = MATERIAL_REWARDS[asset_id]
	var property_name := str(reward.get("property", ""))
	active_player.set(property_name, int(active_player.get(property_name)) + 1)
	events.append({
		"type": "text",
		"text": str(reward.get("text", "")),
		"position": active_player.global_position,
		"color": reward.get("color", Color.WHITE),
	})
	return true
