extends Panel

var selected_idx: int = 0
var main_ref: Node = null
var recipes: Array = [
	{"name": "Toy Sword", "result": "sword", "materials": {"mat_metal_scrap": 2, "mat_green_herb": 1}},
	{"name": "Fire Sword", "result": "firesword", "materials": {"sword": 1, "mat_fire_powder": 2}},
	{"name": "Shield", "result": "shield", "materials": {"mat_metal_scrap": 3, "mat_sweet_honey": 1}},
	{"name": "Potion", "result": "potion", "materials": {"mat_green_herb": 2, "mat_sweet_honey": 1}},
]
var recipe_labels: Array = []
var mat_label: Label = null


func _ready() -> void:
	main_ref = get_tree().get_root().get_node_or_null("Main")
	for i in range(recipes.size()):
		var label := Label.new()
		label.size = Vector2(500, 40)
		label.position = Vector2(100, 90 + i * 50)
		var settings := LabelSettings.new()
		settings.font_size = 18
		label.label_settings = settings
		add_child(label)
		recipe_labels.append(label)

	mat_label = Label.new()
	mat_label.position = Vector2(100, 300)
	var mat_settings := LabelSettings.new()
	mat_settings.font_size = 16
	mat_settings.font_color = Color.GOLD
	mat_label.label_settings = mat_settings
	add_child(mat_label)

	var help := Label.new()
	help.text = "[W/S] Choose Recipe | [Space/Enter] Craft Item | [Esc/Tab] Close"
	help.position = Vector2(100, 350)
	var help_settings := LabelSettings.new()
	help_settings.font_size = 14
	help.label_settings = help_settings
	add_child(help)

	_update_ui()


func _update_ui() -> void:
	var player := _player()
	if player == null or mat_label == null:
		return

	mat_label.text = "Materials: Scrap: %d | Fire Powder: %d | Green Herb: %d | Sweet Honey: %d" % [
		int(player.get("metal_scrap")),
		int(player.get("fire_powder")),
		int(player.get("green_herb")),
		int(player.get("sweet_honey")),
	]

	for i in range(recipes.size()):
		var recipe := recipes[i] as Dictionary
		var materials := recipe.get("materials", {}) as Dictionary
		var req_text := ""
		for mat in materials:
			var needed := int(materials[mat])
			req_text += " " + str(mat).replace("mat_", "").capitalize() + " x" + str(needed)

		var prefix := "> " if i == selected_idx else "  "
		var label := recipe_labels[i] as Label
		label.text = prefix + str(recipe.get("name", "")) + " (Requires:" + req_text + ")"
		label.label_settings.font_color = Color.YELLOW if i == selected_idx else Color.WHITE


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if event.is_action_pressed("ui_up") or event.is_physical_key_pressed(KEY_W):
		selected_idx = posmod(selected_idx - 1, recipes.size())
		_update_ui()
		_play("pop")
	elif event.is_action_pressed("ui_down") or event.is_physical_key_pressed(KEY_S):
		selected_idx = posmod(selected_idx + 1, recipes.size())
		_update_ui()
		_play("pop")
	elif event.is_physical_key_pressed(KEY_ESCAPE) or event.is_physical_key_pressed(KEY_TAB):
		if main_ref != null and main_ref.has_method("close_crafting_ui"):
			main_ref.close_crafting_ui()
	elif event.is_action_just_pressed("ui_accept") or event.is_physical_key_pressed(KEY_SPACE):
		_attempt_craft()


func _attempt_craft() -> void:
	var player := _player()
	if player == null:
		return

	var recipe := recipes[selected_idx] as Dictionary
	var materials := recipe.get("materials", {}) as Dictionary
	if not _has_materials(player, materials):
		_play("hit")
		_float_text("MISSING MATERIALS!", player, Color.RED)
		return

	if player.has_method("add_to_backpack"):
		var ok := bool(player.add_to_backpack(str(recipe.get("result", ""))))
		if not ok:
			_play("hit")
			_float_text("BACKPACK FULL!", player, Color.ORANGE)
			return

	for mat in materials:
		var needed := int(materials[mat])
		if str(mat) == "sword":
			_remove_from_backpack(player, "sword")
		else:
			var inventory_field := str(mat).replace("mat_", "")
			player.set(inventory_field, int(player.get(inventory_field)) - needed)

	_play("coin")
	_float_text("CRAFTED " + str(recipe.get("name", "")), player, Color.GOLD)
	_update_ui()


func _has_materials(player: Node, materials: Dictionary) -> bool:
	for mat in materials:
		var needed := int(materials[mat])
		if str(mat) == "sword":
			if not _has_in_backpack(player, "sword"):
				return false
		else:
			var inventory_field := str(mat).replace("mat_", "")
			if int(player.get(inventory_field)) < needed:
				return false
	return true


func _has_in_backpack(player: Node, item_type: String) -> bool:
	var grid: Array = player.get("backpack_grid")
	for r in range(4):
		for c in range(4):
			var item: Variant = grid[r][c]
			if item != null and str((item as Dictionary).get("type", "")) == item_type:
				return true
	return false


func _remove_from_backpack(player: Node, item_type: String) -> void:
	var grid: Array = player.get("backpack_grid")
	for r in range(4):
		for c in range(4):
			var item: Variant = grid[r][c]
			if item == null or str((item as Dictionary).get("type", "")) != item_type:
				continue
			var root_r := int((item as Dictionary).get("root_r", 0))
			var root_c := int((item as Dictionary).get("root_c", 0))
			for row in range(4):
				for col in range(4):
					var slot: Variant = grid[row][col]
					if slot != null and int((slot as Dictionary).get("root_r", 0)) == root_r and int((slot as Dictionary).get("root_c", 0)) == root_c:
						grid[row][col] = null
			return


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
