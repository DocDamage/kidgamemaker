extends Panel

var cursor_r: int = 0
var cursor_c: int = 0
var selected_item_ref: Variant = null
var main_ref: Node = null
var slots: Array = []


func _ready() -> void:
	main_ref = get_tree().get_root().get_node_or_null("Main")
	for r in range(4):
		var row: Array = []
		for c in range(4):
			var slot_rect := ColorRect.new()
			slot_rect.color = Color(0.12, 0.16, 0.24, 0.8)
			slot_rect.custom_minimum_size = Vector2(60, 60)
			slot_rect.size = Vector2(60, 60)
			slot_rect.position = Vector2(100 + c * 70, 80 + r * 70)
			add_child(slot_rect)

			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size = slot_rect.size
			slot_rect.add_child(label)

			row.append({"rect": slot_rect, "label": label})
		slots.append(row)

	_update_grid_ui()


func _update_grid_ui() -> void:
	var player: Node = _player()
	if player == null:
		return

	var grid: Array = player.get("backpack_grid")
	for r in range(4):
		for c in range(4):
			var slot: Dictionary = slots[r][c]
			var rect := slot["rect"] as ColorRect
			var label := slot["label"] as Label
			rect.color = Color(0.12, 0.16, 0.24, 0.8)
			label.text = ""

	var drawn_roots: Dictionary = {}
	for r in range(4):
		for c in range(4):
			var item: Variant = grid[r][c]
			if item == null:
				continue

			var item_type := _item_string(item, "type")
			var root_key := "%d_%d" % [_item_int(item, "root_r"), _item_int(item, "root_c")]
			var slot: Dictionary = slots[r][c]
			var rect := slot["rect"] as ColorRect
			var label := slot["label"] as Label

			if not drawn_roots.has(root_key):
				drawn_roots[root_key] = true
				label.text = _get_item_icon(item_type)

			if item_type in ["shield", "weapon_shield"]:
				rect.color = Color(0.1, 0.4, 0.5, 0.9)
			elif item_type in ["sword", "firesword", "weapon_sword", "tool_hammer"]:
				rect.color = Color(0.5, 0.4, 0.1, 0.9)
			elif item_type in ["potion", "tool_lantern"]:
				rect.color = Color(0.5, 0.1, 0.5, 0.9)
			elif item_type in ["weapon_boomerang", "weapon_bomb", "weapon_paint_gun"]:
				rect.color = Color(0.6, 0.2, 0.2, 0.9)
			else:
				rect.color = Color(0.2, 0.3, 0.25, 0.9)

	var cursor_slot: Dictionary = slots[cursor_r][cursor_c]
	var cursor_rect := cursor_slot["rect"] as ColorRect
	cursor_rect.color = Color(0.8, 0.4, 0.1, 0.9) if selected_item_ref != null else Color(0.9, 0.8, 0.2, 0.9)

	var desc_label := get_node_or_null("DescLabel") as Label
	if desc_label == null:
		return

	var selected_item: Variant = grid[cursor_r][cursor_c]
	if selected_item != null:
		var selected_type := _item_string(selected_item, "type")
		var details := ""
		if selected_type == "potion":
			details = " ( Heals 50 HP!)"
		elif selected_type in ["sword", "weapon_sword"]:
			details = " ( Equip to swing!)"
		elif selected_type == "firesword":
			details = " ( Attacks ignite enemies!)"
		elif selected_type == "shield":
			details = " ( Absorbs next hit!)"
		elif selected_type == "weapon_boomerang":
			details = " ( Press [C] to throw!)"
		elif selected_type == "weapon_bomb":
			details = " ( Press [V] to drop!)"
		elif selected_type == "weapon_paint_gun":
			details = " ( Press [G] to paint!)"
		elif selected_type == "tool_hammer":
			details = " ( Smash obstacles!)"
		elif selected_type == "tool_lantern":
			details = " ( See in the dark!)"
		desc_label.text = "Cursor: " + selected_type.replace("weapon_", "").replace("tool_", "").replace("mat_", "").capitalize() + details + "\n[E] Use/Equip | [Space] Move | [X] Discard"
	else:
		desc_label.text = "Empty Slot\n[W/A/S/D] Navigate | [Tab/Esc] Close"


func _get_item_icon(type: String) -> String:
	match type:
		"potion":
			return "POT"
		"shield", "weapon_shield":
			return "SHD"
		"sword", "weapon_sword":
			return "SWD"
		"firesword":
			return "FIRE"
		"weapon_boomerang":
			return "BMRG"
		"weapon_bomb":
			return "BMB"
		"weapon_paint_gun":
			return "GUN"
		"tool_hammer":
			return "HAM"
		"tool_lantern":
			return "LNTN"
		"mat_metal_scrap":
			return "SCR"
		"mat_fire_powder":
			return "SPCE"
		"mat_green_herb":
			return "HRB"
		"mat_sweet_honey":
			return "HNY"
		_:
			return "BOX"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return

	if event.is_action_pressed("ui_up") or event.is_physical_key_pressed(KEY_W):
		cursor_r = posmod(cursor_r - 1, 4)
		_update_grid_ui()
	elif event.is_action_pressed("ui_down") or event.is_physical_key_pressed(KEY_S):
		cursor_r = posmod(cursor_r + 1, 4)
		_update_grid_ui()
	elif event.is_action_pressed("ui_left") or event.is_physical_key_pressed(KEY_A):
		cursor_c = posmod(cursor_c - 1, 4)
		_update_grid_ui()
	elif event.is_action_pressed("ui_right") or event.is_physical_key_pressed(KEY_D):
		cursor_c = posmod(cursor_c + 1, 4)
		_update_grid_ui()
	elif event.is_physical_key_pressed(KEY_ESCAPE) or event.is_physical_key_pressed(KEY_TAB):
		if main_ref != null and main_ref.has_method("toggle_backpack_ui"):
			main_ref.toggle_backpack_ui()
	elif event.is_physical_key_pressed(KEY_E):
		_use_selected_item()
	elif event.is_physical_key_pressed(KEY_X):
		_discard_selected_item()
	elif event.is_action_just_pressed("ui_accept") or event.is_physical_key_pressed(KEY_SPACE):
		_move_selected_item()


func _use_selected_item() -> void:
	var player: Node = _player()
	if player == null:
		return

	var grid: Array = player.get("backpack_grid")
	var item: Variant = grid[cursor_r][cursor_c]
	if item != null:
		_use_item(item)


func _discard_selected_item() -> void:
	var player: Node = _player()
	if player == null:
		return

	var grid: Array = player.get("backpack_grid")
	var item: Variant = grid[cursor_r][cursor_c]
	if item == null:
		return

	_remove_item_from_grid(player, item)
	if main_ref != null and main_ref.has_method("play_sfx"):
		main_ref.play_sfx("hit")
	_update_grid_ui()


func _move_selected_item() -> void:
	var player: Node = _player()
	if player == null:
		return

	var grid: Array = player.get("backpack_grid")
	if selected_item_ref == null:
		selected_item_ref = grid[cursor_r][cursor_c]
		_update_grid_ui()
		return

	var item: Variant = selected_item_ref
	_remove_item_from_grid(player, item)
	var item_w := _item_int(item, "w")
	var item_h := _item_int(item, "h")
	var fits := true
	for dr in range(item_h):
		for dc in range(item_w):
			var target_r := cursor_r + dr
			var target_c := cursor_c + dc
			if target_r >= 4 or target_c >= 4 or grid[target_r][target_c] != null:
				fits = false
				break
		if not fits:
			break

	if fits:
		for dr in range(item_h):
			for dc in range(item_w):
				grid[cursor_r + dr][cursor_c + dc] = {
					"type": _item_string(item, "type"),
					"root_r": cursor_r,
					"root_c": cursor_c,
					"w": item_w,
					"h": item_h,
				}
		_play("coin")
	else:
		var root_r := _item_int(item, "root_r")
		var root_c := _item_int(item, "root_c")
		for dr in range(item_h):
			for dc in range(item_w):
				grid[root_r + dr][root_c + dc] = item
		_play("hit")

	selected_item_ref = null
	_update_grid_ui()


func _remove_item_from_grid(player: Node, item: Variant) -> void:
	var grid: Array = player.get("backpack_grid")
	var root_r := _item_int(item, "root_r")
	var root_c := _item_int(item, "root_c")
	for r in range(4):
		for c in range(4):
			var val: Variant = grid[r][c]
			if val != null and _item_int(val, "root_r") == root_r and _item_int(val, "root_c") == root_c:
				grid[r][c] = null


func _use_item(item: Variant) -> void:
	var player: Node = _player()
	if player == null:
		return

	var item_type := _item_string(item, "type")
	if item_type == "potion":
		if player.has_method("heal"):
			player.heal(50)
		_remove_item_from_grid(player, item)
		_play("coin")
		_float_text("HEALED!", player, Color.GREEN)
	elif item_type in ["sword", "weapon_sword"]:
		player.set("has_sword", true)
		player.set("costume_tint", "default")
		_play("coin")
		_float_text("SWORD EQUIPPED!", player, Color.GOLD)
	elif item_type == "firesword":
		player.set("has_sword", true)
		player.set("costume_tint", "orange")
		_play("coin")
		_float_text("FIRE SWORD EQUIPPED!", player, Color.ORANGE)
	elif item_type in ["shield", "weapon_shield"]:
		player.set("shield_active", true)
		_remove_item_from_grid(player, item)
		_play("coin")
		_float_text("SHIELD EQUIPPED!", player, Color.CYAN)
	elif item_type == "weapon_boomerang":
		player.set("has_boomerang", true)
		_play("coin")
		_float_text("BOOMERANG EQUIPPED!", player, Color.AQUAMARINE)
	elif item_type == "weapon_bomb":
		player.set("has_bomb", true)
		_play("coin")
		_float_text("BOMBS EQUIPPED!", player, Color.CRIMSON)
	elif item_type == "weapon_paint_gun":
		player.set("has_paint_gun", true)
		_play("coin")
		_float_text("PAINT GUN EQUIPPED!", player, Color.MEDIUM_SPRING_GREEN)
	elif item_type == "tool_hammer":
		player.set("has_hammer", true)
		_play("coin")
		_float_text("HAMMER EQUIPPED!", player, Color.GOLDENROD)
	elif item_type == "tool_lantern":
		player.set("has_lantern", true)
		_play("coin")
		_float_text("LANTERN EQUIPPED!", player, Color.YELLOW)

	_update_grid_ui()


func _player() -> Node:
	if main_ref == null:
		return null
	return main_ref.get("active_player") as Node


func _play(sound: String) -> void:
	if main_ref != null and main_ref.has_method("play_sfx"):
		main_ref.play_sfx(sound)


func _float_text(text: String, player: Node, color: Color) -> void:
	var player_2d := player as Node2D
	if main_ref != null and player_2d != null and main_ref.has_method("spawn_floating_text"):
		main_ref.spawn_floating_text(text, player_2d.global_position, color)


func _item_string(item: Variant, key: String) -> String:
	return str((item as Dictionary).get(key, ""))


func _item_int(item: Variant, key: String) -> int:
	return int((item as Dictionary).get(key, 0))
