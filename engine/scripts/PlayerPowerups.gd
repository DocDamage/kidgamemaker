extends RefCounted


static func apply(player: Node2D, powerup_type: String) -> void:
	var main := player.get_tree().get_root().get_node_or_null("Main")
	match powerup_type:
		"speed":
			player.set("speed_boost_timer", 5.0)
			print("Player acquired Speed Boost!")
			_play_coin(main)
		"shield":
			player.set("shield_active", true)
			print("Player acquired Shield!")
			_play_coin(main)
		"double_jump":
			player.set("double_jump_enabled", true)
			print("Player acquired Double Jump Shoes!")
			_play_coin(main)
		"charge_jump":
			player.set("charge_jump_enabled", true)
			print("Player acquired Charge Spring!")
			_play_coin(main)
		"glider":
			player.set("has_glider", true)
			print("Player acquired Glider Cape!")
			_play_coin(main)
		"jetpack":
			player.set("has_jetpack", true)
			player.set("jetpack_fuel", 100.0)
			print("Player acquired Jetpack!")
			_play_coin(main)
		"giant":
			player.set("giant_timer", 6.0)
			player.set("is_giant", true)
			player.scale = Vector2(2.0, 2.0)
			print("Player acquired Giant Growth!")
			_play_coin(main)
		"gravity":
			var gravity_inverted := not bool(player.get("gravity_inverted"))
			player.set("gravity_inverted", gravity_inverted)
			player.set("gravity_scale", -1.0 if gravity_inverted else 1.0)
			print("Player toggled gravity!")
			_play_coin(main)
		"hammer":
			player.set("has_hammer", true)
			print("Player acquired Toy Hammer!")
			_play_coin(main)
		"lantern":
			player.set("has_lantern", true)
			print("Player acquired Lantern!")
			_play_coin(main)
		"sword":
			player.set("has_sword", true)
			print("Player acquired Toy Sword!")
			_play_coin(main)
		"boomerang":
			player.set("has_boomerang", true)
			print("Player acquired Boomerang!")
			_play_coin(main)
		"bomb":
			player.set("has_bomb", true)
			print("Player acquired Bomb!")
			_play_coin(main)
		"focus_amulet":
			player.set("has_focus_amulet", true)
			print("Player acquired Focus Amulet!")
			_play_coin(main)
		"paint_gun":
			player.set("has_paint_gun", true)
			print("Player acquired Paint Gun!")
			_play_coin(main)

	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text(powerup_type.replace("_", " ").to_upper() + "!", player.global_position, Color.CYAN)


static func _play_coin(main: Node) -> void:
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("coin")
