extends RefCounted


static func handle(player: CharacterBody2D, event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var emoji := ""
		match event.keycode:
			KEY_1: emoji = "😊"
			KEY_2: emoji = "😡"
			KEY_3: emoji = "😱"
			KEY_4: emoji = "🎉"
			KEY_5: emoji = "💤"
			KEY_TAB:
				var main = player.get_tree().get_root().get_node_or_null("Main")
				if main != null and main.has_method("toggle_backpack_ui"):
					main.toggle_backpack_ui()
			KEY_F:
				var main = player.get_tree().get_root().get_node_or_null("Main")
				if main != null:
					var thrown = false
					for child in player.get_parent().get_children():
						if child.has_meta("asset_id") and child.get_meta("asset_id") == "companion_pikmin":
							if child.has_method("is_following") and child.is_following():
								child.throw(player.facing_direction)
								thrown = true
								break
					if thrown:
						if main.has_method("play_sfx"):
							main.play_sfx("jump")
			KEY_Q:
				var main = player.get_tree().get_root().get_node_or_null("Main")
				if main != null:
					if main.has_method("play_sfx"):
						main.play_sfx("coin")
					if main.has_method("spawn_floating_text"):
						main.spawn_floating_text("📢 WHISTLE!", player.global_position, Color.CHARTREUSE)
					for child in player.get_parent().get_children():
						if child.has_meta("asset_id") and child.get_meta("asset_id") == "companion_pikmin":
							if child.has_method("recall"):
								child.recall()
			KEY_C:
				if player.has_boomerang and not player.is_dashing and not player.is_blocking:
					player._throw_boomerang()
			KEY_V:
				if player.has_bomb and not player.is_dashing and not player.is_blocking:
					player._throw_bomb()
			KEY_G:
				if player.has_paint_gun and not player.is_dashing and not player.is_blocking:
					player._fire_paint_projectile()
			KEY_H:
				for child in player.get_parent().get_children():
					if child.has_meta("asset_id") and child.get_meta("asset_id") == "companion_rush":
						if child.has_method("toggle_form"):
							child.toggle_form()
							break
			KEY_T:
				if player.has_focus_amulet and not player.focus_active:
					var main = player.get_tree().get_root().get_node_or_null("Main")
					player.focus_active = true
					player.focus_timer = 3.0
					Engine.time_scale = player.current_time_slow_factor
					if main != null and main.has_method("play_sfx"):
						main.play_sfx("coin")
					if main != null and main.has_method("spawn_floating_text"):
						main.spawn_floating_text("⏳ TIME SLOWED! ⏳", player.global_position, Color.PURPLE)
		if emoji != "":
			player.show_emote(emoji)
