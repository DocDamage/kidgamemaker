extends Area2D

## Emitted when a collectible is picked up.
## Payload: { score_value, heal_value, asset_id }
signal collected(payload: Dictionary)

@export var score_value: int = 0
@export var heal_value: int = 0
@export var asset_id: String = ""
@export var powerup_type: String = ""
@export var charge_jump_speed: String = "normal"
@export var combined_with: String = ""

var _collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if powerup_type == "":
		if asset_id == "alchemy_potion_speed":
			powerup_type = "speed"
		elif asset_id == "alchemy_potion_giant":
			powerup_type = "giant"
		elif asset_id == "alchemy_potion_gravity":
			powerup_type = "gravity"
		elif asset_id == "alchemy_potion_jump":
			powerup_type = "double_jump"
		elif asset_id == "gadget_glider":
			powerup_type = "glider"
		elif asset_id == "gadget_jetpack":
			powerup_type = "jetpack"
		elif asset_id == "charge_spring":
			powerup_type = "charge_jump"
		elif asset_id == "weapon_boomerang":
			powerup_type = "boomerang"
		elif asset_id == "weapon_bomb":
			powerup_type = "bomb"
		elif asset_id == "focus_amulet":
			powerup_type = "focus_amulet"


func _on_body_entered(body: Node) -> void:
	if _collected:
		return

	# Only react to the player (CharacterBody2D with health tracking)
	if not body is CharacterBody2D:
		return

	_collected = true

	# -- Check for Emerald/Ruby collections for Golden Flight Mode --
	if asset_id == "gold_ruby" or asset_id == "star_piece" or asset_id.contains("emerald"):
		if "emeralds_collected" in body:
			body.emeralds_collected += 1
			print("Emeralds collected: ", body.emeralds_collected)
			if body.emeralds_collected >= 7 and not body.get("is_golden_flight"):
				body.call("activate_golden_flight")

	# ── Heal the player if this is a health pickup ──
	if heal_value > 0 and body.has_method("heal"):
		body.heal(heal_value)
	elif heal_value > 0 and "current_health" in body and "max_health" in body:
		body.current_health = min(body.current_health + heal_value, body.max_health)
		print("Player healed by %d HP. HP now: %d/%d" % [heal_value, body.current_health, body.max_health])

	# ── Apply power-up status effect ──
	if powerup_type != "" and body.has_method("apply_powerup"):
		if powerup_type == "charge_jump":
			var time_per_level := 0.8
			match charge_jump_speed:
				"fast":
					time_per_level = 0.5
				"slow":
					time_per_level = 1.1
				_:
					time_per_level = 0.8
			body.set("charge_jump_time_per_level", time_per_level)
		if body.has_method("apply_powerup_with_combo"):
			body.apply_powerup_with_combo(powerup_type, combined_with)
		else:
			body.apply_powerup(powerup_type)

	# ── Notify Main (score board, HUD, etc.) ──
	var payload := {
		"score_value": score_value,
		"heal_value": heal_value,
		"asset_id": asset_id,
	}
	if has_meta("key_color"):
		payload["key_color"] = str(get_meta("key_color"))
	emit_signal("collected", payload)

	# Forward to Main node if it has a receiver
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("on_collectible_picked_up"):
		main.on_collectible_picked_up(payload)
	if main != null and main.has_method("play_custom_sfx"):
		main.play_custom_sfx(asset_id, "coin")
	if score_value > 0 and main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("+%d" % score_value, global_position, Color(1.0, 0.85, 0.15))

	print("Collected '%s' score+%d heal+%d powerup=%s" % [asset_id, score_value, heal_value, powerup_type])

	# ── Pop-and-fade tween ──
	_play_collect_tween()


func _play_collect_tween() -> void:
	# Disable collision immediately so nothing else triggers it
	set_deferred("monitoring", false)

	var tween := create_tween()
	tween.set_parallel(true)

	# Scale pop: grow then shrink
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.08).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.18) \
		.set_delay(0.08).set_ease(Tween.EASE_IN)

	# Drift upward
	tween.tween_property(self, "position", position + Vector2(0, -28), 0.26) \
		.set_ease(Tween.EASE_OUT)

	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.22) \
		.set_delay(0.06).set_ease(Tween.EASE_IN)

	tween.chain().tween_callback(queue_free)
