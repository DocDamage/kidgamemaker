extends Area2D

var is_opened: bool = false
var reward_pool: Array = ["coin", "health", "speed", "shield", "slime"]


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if is_opened:
		return
	if body.has_method("take_damage") and body is CharacterBody2D:
		is_opened = true
		_play_reveal_sequence(body)


func _play_reveal_sequence(player: Node2D) -> void:
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("coin")

	var spin_timer := create_tween()
	for i in range(5):
		var text := "❓"
		match i % 4:
			0:
				text = "🪙 COIN!"
			1:
				text = "❤️ HEAL!"
			2:
				text = "⚡ SPEED!"
			3:
				text = "🛡️ SHIELD!"
		spin_timer.tween_callback(func() -> void:
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text(text, global_position + Vector2(0, -32), Color.GOLD)
		).set_delay(0.12)

	spin_timer.chain().tween_callback(func() -> void:
		var final_reward: String = reward_pool[randi() % reward_pool.size()]
		_give_reward(player, final_reward)
		_fade_out()
	)


func _give_reward(player: Node2D, reward: String) -> void:
	var main := get_tree().get_root().get_node_or_null("Main")
	match reward:
		"coin":
			if main != null:
				main.set("score", main.get("score") + 50)
				main.spawn_floating_text("+50 POINTS! 🪙", global_position + Vector2(0, -40), Color.YELLOW)
				main.play_sfx("coin")
		"health":
			if player.has_method("heal"):
				player.heal(40)
				if main != null:
					main.play_sfx("coin")
		"speed":
			if player.has_method("apply_powerup"):
				player.apply_powerup("speed")
		"shield":
			if player.has_method("apply_powerup"):
				player.apply_powerup("shield")
		"slime":
			if main != null:
				main.spawn_floating_text("OH NO! A SLIME! 👾", global_position + Vector2(0, -40), Color.RED)
				main.play_sfx("hit")
				var slime_data := {
					"asset_id": "slime_patrol",
					"category": "enemies",
					"position": {"x": global_position.x, "y": global_position.y - 48},
					"modifiers": {"patrol_speed": 80.0}
				}
				main.spawn_entity(slime_data)


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(queue_free)
