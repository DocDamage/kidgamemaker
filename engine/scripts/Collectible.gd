extends Area2D

## Emitted when a collectible is picked up.
## Payload: { score_value, heal_value, asset_id }
signal collected(payload: Dictionary)

@export var score_value: int = 0
@export var heal_value: int = 0
@export var asset_id: String = ""

var _collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _collected:
		return

	# Only react to the player (CharacterBody2D with health tracking)
	if not body is CharacterBody2D:
		return

	_collected = true

	# ── Heal the player if this is a health pickup ──
	if heal_value > 0 and body.has_method("heal"):
		body.heal(heal_value)
	elif heal_value > 0 and "current_health" in body and "max_health" in body:
		body.current_health = min(body.current_health + heal_value, body.max_health)
		print("Player healed by %d  HP. HP now: %d/%d" % [heal_value, body.current_health, body.max_health])

	# ── Notify Main (score board, HUD, etc.) ──
	var payload := {
		"score_value": score_value,
		"heal_value": heal_value,
		"asset_id": asset_id,
	}
	emit_signal("collected", payload)

	# Forward to Main node if it has a receiver
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("on_collectible_picked_up"):
		main.on_collectible_picked_up(payload)

	print("Collected '%s'  score+%d  heal+%d" % [asset_id, score_value, heal_value])

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
