extends RefCounted

const SHOP_EQUIPMENT_FLAGS := {
	"tool_hammer": "has_hammer",
	"tool_lantern": "has_lantern",
	"weapon_sword": "has_sword",
	"weapon_boomerang": "has_boomerang",
	"weapon_bomb": "has_bomb",
}


static func attempt_shop_purchase(item: Dictionary, player: Node2D, score: int) -> Dictionary:
	var cost := int(item.get("cost", 0))
	var item_id := str(item.get("id", ""))
	var item_name := str(item.get("name", item_id))
	if score < cost:
		return {
			"score": score,
			"close_overlay": false,
			"events": [{"type": "sfx", "sfx": "hit"}, _player_text(player, "NEED MORE COINS! 🪙", Color.RED)],
		}

	var fits := false
	if player != null and is_instance_valid(player):
		fits = player.add_to_backpack(item_id)
		if fits and SHOP_EQUIPMENT_FLAGS.has(item_id):
			player.set(str(SHOP_EQUIPMENT_FLAGS[item_id]), true)

	if fits:
		score -= cost
		return {
			"score": score,
			"close_overlay": true,
			"events": [_player_text(player, "BOUGHT " + item_name + "! 🛒", Color.GREEN), {"type": "sfx", "sfx": "coin"}],
		}

	return {
		"score": score,
		"close_overlay": false,
		"events": [{"type": "sfx", "sfx": "hit"}, _player_text(player, "🎒 BACKPACK FULL!", Color.ORANGE)],
	}


static func attempt_anvil_upgrade(root: Node, player: Node2D, weapon_level: int) -> Dictionary:
	if player == null or not is_instance_valid(player):
		return {"success": false, "close_overlay": false, "events": []}

	var scrap := int(player.get("metal_scrap"))
	var powder := int(player.get("fire_powder"))
	if scrap < 1 or powder < 1:
		return {
			"success": false,
			"close_overlay": false,
			"events": [{"type": "sfx", "sfx": "hit"}, _player_text(player, "NEED 1x SCRAP & 1x POWDER! 🔩🌶️", Color.RED)],
		}

	player.set("metal_scrap", scrap - 1)
	player.set("fire_powder", powder - 1)
	player.set("weapon_level", weapon_level + 1)
	remove_backpack_item_by_type(player, "mat_metal_scrap")
	remove_backpack_item_by_type(player, "mat_fire_powder")
	_spawn_upgrade_particles(root, player.global_position)

	return {
		"success": true,
		"close_overlay": true,
		"events": [_player_text(player, "WEAPON UPGRADED TO LV. " + str(weapon_level + 1) + "! 🔥", Color.GOLD), {"type": "sfx", "sfx": "coin"}],
	}


static func remove_backpack_item_by_type(player: Node, item_type: String) -> void:
	if player == null or not "backpack_grid" in player:
		return
	for row_index in range(4):
		for column_index in range(4):
			var item = player.backpack_grid[row_index][column_index]
			if item != null and item.type == item_type:
				for row in range(4):
					for column in range(4):
						var other = player.backpack_grid[row][column]
						if other != null and other.root_r == item.root_r and other.root_c == item.root_c:
							player.backpack_grid[row][column] = null
				return


static func _player_text(player: Node2D, text: String, color: Color) -> Dictionary:
	return {
		"type": "text",
		"text": text,
		"position": player.global_position if player != null and is_instance_valid(player) else Vector2.ZERO,
		"color": color,
	}


static func _spawn_upgrade_particles(root: Node, position: Vector2) -> void:
	if root == null:
		return
	var particles := CPUParticles2D.new()
	particles.global_position = position
	particles.amount = 20
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.5
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 250.0
	particles.color = Color.ORANGE_RED
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	root.add_child(particles)
	particles.emitting = true
	root.get_tree().create_timer(0.6).timeout.connect(particles.queue_free)
