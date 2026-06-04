extends RefCounted


static func create_player(app, data: Dictionary, sidecar: Dictionary, player_script_path: String, difficulty: String) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(32, 48), data)
	app._add_box_collision(body, size)
	app._add_visuals(body, sidecar, size, Color(0.2, 0.55, 1.0, 0.9))
	var script := load(player_script_path)
	if script != null:
		body.set_script(script)
		var attrs: Dictionary = sidecar.get("baseline_attributes", {})
		var base_health := int(attrs.get("max_health", 100))
		if difficulty == "easy":
			base_health = base_health * 2
		body.set("max_health", base_health)
		body.set("movement_speed", float(attrs.get("movement_speed", 220)))
		body.set("jump_force", float(attrs.get("jump_force", -460)))
		body.set("gravity_scale", float(attrs.get("gravity_scale", 1.0)))
		body.set("asset_id", str(data.get("asset_id", "")))
		var modifiers: Dictionary = data.get("modifiers", {})
		if modifiers.has("costume_tint"):
			body.set("costume_tint", str(modifiers.get("costume_tint")))
		if modifiers.has("hero_class"):
			body.set("hero_class", str(modifiers.get("hero_class")))
	return body


static func create_enemy(app, data: Dictionary, sidecar: Dictionary, enemy_script_path: String) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(32, 32), data)
	app._add_box_collision(body, size)
	app._add_visuals(body, sidecar, size, Color(1.0, 0.25, 0.25, 0.9))
	var script := load(enemy_script_path)
	if script != null:
		body.set_script(script)
		var attrs: Dictionary = sidecar.get("baseline_attributes", {})
		body.set("patrol_speed", float(attrs.get("movement_speed", 70)))
		body.set("gravity_scale", float(attrs.get("gravity_scale", 1.0)))
		body.set("damage_value", int(attrs.get("damage_value", 10)))
		var max_hp := int(attrs.get("max_health", 20))
		body.set("boss_mode", max_hp > 100)
		_apply_enemy_modifiers(body, data.get("modifiers", {}))
	return body


static func _apply_enemy_modifiers(body: CharacterBody2D, raw_modifiers: Variant) -> void:
	var modifiers: Dictionary = raw_modifiers if typeof(raw_modifiers) == TYPE_DICTIONARY else {}
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
	if modifiers.has("boss_hud_style"):
		body.set("boss_hud_style", str(modifiers.get("boss_hud_style")))
	if modifiers.has("boss_phases_count"):
		body.set("boss_phases_count", int(modifiers.get("boss_phases_count")))


static func create_collectible(app, data: Dictionary, sidecar: Dictionary, collectible_script_path: String) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(24, 24), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(1.0, 0.85, 0.15, 0.95))
	var script := load(collectible_script_path)
	if script != null:
		area.set_script(script)
		var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
		area.set("score_value", int(gameplay.get("score_value", 0)))
		area.set("heal_value", int(gameplay.get("heal_value", 0)))
		area.set("powerup_type", str(gameplay.get("powerup_type", "")))
		area.set("charge_jump_speed", str(gameplay.get("charge_jump_speed", "normal")))
		area.set("asset_id", str(data.get("asset_id", "")))
		_apply_collectible_modifiers(area, data.get("modifiers", {}))
	area.set_meta("is_collectible", true)
	return area


static func _apply_collectible_modifiers(area: Area2D, raw_modifiers: Variant) -> void:
	var modifiers: Dictionary = raw_modifiers if typeof(raw_modifiers) == TYPE_DICTIONARY else {}
	if modifiers.has("score_value"):
		area.set("score_value", int(modifiers.get("score_value")))
	if modifiers.has("heal_value"):
		area.set("heal_value", int(modifiers.get("heal_value")))
	if modifiers.has("powerup_type"):
		area.set("powerup_type", str(modifiers.get("powerup_type")))
	if modifiers.has("charge_jump_speed"):
		area.set("charge_jump_speed", str(modifiers.get("charge_jump_speed")))


static func create_key_collectible(app, data: Dictionary, sidecar: Dictionary, collectible_script_path: String) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(20, 20), data)
	app._add_box_collision(area, size)
	var asset_id := str(data.get("asset_id", ""))
	var key_color := key_color_for(data, sidecar)
	app._add_visuals(area, sidecar, size, color_for_key(key_color, Color(1.0, 0.85, 0.0, 0.95)))
	area.set_meta("is_collectible", true)
	var script := load(collectible_script_path)
	if script != null:
		area.set_script(script)
		area.set("score_value", 0)
		area.set("heal_value", 0)
		area.set("asset_id", asset_id)
		area.set_meta("key_color", key_color)
	return area


static func create_checkpoint(app, data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(40, 56), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.3, 1.0, 0.7, 0.8))
	return area


static func create_portal(app, data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 64), data)
	app._add_box_collision(area, size)
	app._add_visuals(area, sidecar, size, Color(0.65, 0.45, 0.2, 0.8))
	return area


static func create_locked_door(app, data: Dictionary, sidecar: Dictionary) -> Area2D:
	var area := Area2D.new()
	var size: Vector2 = app._collision_size(sidecar, Vector2(48, 64), data)
	app._add_box_collision(area, size)
	var key_color := key_color_for(data, sidecar)
	app._add_visuals(area, sidecar, size, color_for_key(key_color, Color(0.8, 0.15, 0.15, 0.9)))
	var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
	area.set_meta("requires_key", bool(gameplay.get("requires_key", true)))
	area.set_meta("key_color", key_color)
	return area


static func key_color_for(data: Dictionary, sidecar: Dictionary) -> String:
	var asset_id := str(data.get("asset_id", ""))
	var modifiers: Dictionary = data.get("modifiers", {})
	var key_color := str(modifiers.get("key_color", ""))
	if key_color != "":
		return key_color
	if asset_id.contains("red"):
		return "red"
	if asset_id.contains("blue"):
		return "blue"
	var gameplay: Dictionary = sidecar.get("gameplay_logic", {})
	return str(gameplay.get("key_color", "gold"))


static func color_for_key(key_color: String, fallback: Color) -> Color:
	if key_color == "red":
		return Color(1.0, 0.2, 0.2, fallback.a)
	if key_color == "blue":
		return Color(0.2, 0.5, 1.0, fallback.a)
	if key_color == "gold":
		return Color(1.0, 0.8, 0.0, fallback.a)
	return fallback
