extends RefCounted

const BACKPACK_PANEL_SCRIPT := preload("res://scripts/BackpackPanel.gd")
const CRAFTING_PANEL_SCRIPT := preload("res://scripts/CraftingPanel.gd")
const COOKING_PANEL_SCRIPT := preload("res://scripts/CookingPanel.gd")
const PANEL_LAYER := 150


static func create_backpack(parent: Node) -> CanvasLayer:
	var layer := _create_layer(parent)
	var panel := _create_panel(layer, Color(0.06, 0.08, 0.12, 0.95))
	_add_title(panel, "🎒 4x4 Grid Inventory 🎒", Color.WHITE)

	var desc := Label.new()
	desc.name = "DescLabel"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var desc_settings := LabelSettings.new()
	desc_settings.font_size = 14
	desc.label_settings = desc_settings
	desc.size = Vector2(400, 60)
	desc.position = Vector2(100, 360)
	panel.add_child(desc)

	panel.set_script(BACKPACK_PANEL_SCRIPT)
	return layer


static func create_crafting(parent: Node) -> CanvasLayer:
	var layer := _create_layer(parent)
	var panel := _create_panel(layer, Color(0.08, 0.12, 0.2, 0.9))
	_add_title(panel, "🔨 Dynamic Crafting Bench 🔨", Color.WHITE)
	panel.set_script(CRAFTING_PANEL_SCRIPT)
	return layer


static func create_cooking(parent: Node) -> CanvasLayer:
	var layer := _create_layer(parent)
	var panel := _create_panel(layer, Color(0.12, 0.08, 0.08, 0.9))
	_add_title(panel, "🍖 BBQ Spit Master Mini-game 🍖", Color.ORANGE)

	var meat := Label.new()
	meat.text = "🥩"
	meat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var meat_settings := LabelSettings.new()
	meat_settings.font_size = 72
	meat.label_settings = meat_settings
	meat.size = Vector2(200, 100)
	meat.position = Vector2(220, 120)
	panel.add_child(meat)

	panel.set_script(COOKING_PANEL_SCRIPT)
	return layer


static func create_shop(parent: Node, shop_node: Node2D, coin_count: int) -> CanvasLayer:
	var overlay := _create_named_layer(parent, "ShopOverlay")
	var panel := _create_bordered_panel(overlay, Color(0.08, 0.12, 0.22, 0.9), Color(0.2, 0.6, 0.9))
	_add_centered_title(panel, "🧸 Toy Shopkeeper's Stall 🪙", Color(0.3, 0.8, 1.0), 40.0)
	_add_centered_label(panel, "Your Coins: 🪙 " + str(coin_count), 24, Color.GOLD, 100.0, 35.0, 400.0)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.anchor_left = 0.5
	grid.anchor_right = 0.5
	grid.anchor_top = 0.5
	grid.anchor_bottom = 0.5
	grid.grow_horizontal = Control.GROW_DIRECTION_BOTH
	grid.grow_vertical = Control.GROW_DIRECTION_BOTH
	grid.offset_left = -330
	grid.offset_right = 330
	grid.offset_top = -80
	grid.offset_bottom = 140
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	panel.add_child(grid)

	for item in _shop_items(shop_node):
		var card := Button.new()
		card.custom_minimum_size = Vector2(210, 120)
		card.text = str(item.get("name", "Toy")) + "\nCost: " + str(item.get("cost", 0)) + " Coins\n(" + str(item.get("desc", "")) + ")"
		card.pressed.connect(func() -> void:
			parent.call("_attempt_shop_purchase", item, overlay)
		)
		grid.add_child(card)

	_add_close_button(panel, overlay, 0.9)
	return overlay


static func create_anvil(parent: Node, active_player: Node) -> CanvasLayer:
	var overlay := _create_named_layer(parent, "AnvilOverlay")
	var panel := _create_bordered_panel(overlay, Color(0.12, 0.12, 0.15, 0.9), Color(0.6, 0.6, 0.7))
	_add_centered_title(panel, "⚒️ Weapon Upgrade Anvil ⚒️", Color(0.8, 0.8, 0.9), 60.0)

	var scrap_count: int = int(active_player.get("metal_scrap")) if active_player != null else 0
	var powder_count: int = int(active_player.get("fire_powder")) if active_player != null else 0
	_add_centered_label(panel, "Materials: 🔩 " + str(scrap_count) + " Scrap / 🌶️ " + str(powder_count) + " Powder", 20, Color.LIGHT_GRAY, 130.0, 30.0, 500.0)

	var weapon_level: int = int(active_player.get("weapon_level")) if active_player != null else 1
	var desc := Label.new()
	desc.text = "Current Weapon Level: Lv. " + str(weapon_level) + "\nCost: 1x Metal Scrap 🔩 + 1x Fire Powder 🌶️\nUpgrade yields +5 damage per strike & fiery visual slash trail!"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var desc_settings := LabelSettings.new()
	desc_settings.font_size = 16
	desc.label_settings = desc_settings
	desc.anchor_left = 0.5
	desc.anchor_right = 0.5
	desc.offset_left = -250
	desc.offset_right = 250
	desc.offset_top = 200
	desc.offset_bottom = 280
	panel.add_child(desc)

	var btn_upgrade := Button.new()
	btn_upgrade.text = "UPGRADE WEAPON ⚒️"
	btn_upgrade.custom_minimum_size = Vector2(240, 60)
	btn_upgrade.anchor_left = 0.5
	btn_upgrade.anchor_right = 0.5
	btn_upgrade.anchor_top = 0.65
	btn_upgrade.anchor_bottom = 0.65
	btn_upgrade.offset_left = -120
	btn_upgrade.offset_right = 120
	btn_upgrade.offset_top = -30
	btn_upgrade.offset_bottom = 30
	btn_upgrade.pressed.connect(func() -> void:
		parent.call("_attempt_anvil_upgrade", overlay, weapon_level)
	)
	panel.add_child(btn_upgrade)

	_add_close_button(panel, overlay, 0.85)
	return overlay


static func _create_layer(parent: Node) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = PANEL_LAYER
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	parent.add_child(layer)
	return layer


static func _create_named_layer(parent: Node, layer_name: String) -> CanvasLayer:
	var layer := _create_layer(parent)
	layer.name = layer_name
	return layer


static func _create_panel(layer: CanvasLayer, color: Color) -> Panel:
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	return panel


static func _create_bordered_panel(layer: CanvasLayer, color: Color, border_color: Color) -> Panel:
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 6
	style.border_width_top = 6
	style.border_width_right = 6
	style.border_width_bottom = 6
	style.border_color = border_color
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	return panel


static func _add_title(panel: Panel, text: String, color: Color) -> void:
	var title := Label.new()
	title.text = text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title_settings := LabelSettings.new()
	title_settings.font_size = 28
	title_settings.font_color = color
	title.label_settings = title_settings
	title.position = Vector2(100, 20)
	panel.add_child(title)


static func _add_centered_title(panel: Panel, text: String, color: Color, top: float) -> void:
	var label := _add_centered_label(panel, text, 36, color, top, 50.0, 600.0)
	label.label_settings.outline_size = 6
	label.label_settings.outline_color = Color.BLACK


static func _add_centered_label(panel: Panel, text: String, font_size: int, color: Color, top: float, height: float, width: float) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	label.label_settings = settings
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.offset_left = -width * 0.5
	label.offset_right = width * 0.5
	label.offset_top = top
	label.offset_bottom = top + height
	panel.add_child(label)
	return label


static func _add_close_button(panel: Panel, overlay: CanvasLayer, anchor_top: float) -> void:
	var btn_close := Button.new()
	btn_close.text = "Back to Game ❌"
	btn_close.custom_minimum_size = Vector2(160, 45)
	btn_close.anchor_left = 0.5
	btn_close.anchor_right = 0.5
	btn_close.anchor_top = anchor_top
	btn_close.anchor_bottom = anchor_top
	btn_close.offset_left = -80
	btn_close.offset_right = 80
	btn_close.offset_top = -22
	btn_close.offset_bottom = 22
	btn_close.pressed.connect(func() -> void:
		overlay.get_tree().paused = false
		overlay.queue_free()
	)
	panel.add_child(btn_close)


static func _shop_items(shop_node: Node2D) -> Array:
	if shop_node != null and shop_node.has_meta("shop_item_1"):
		var item1 := str(shop_node.get_meta("shop_item_1"))
		var price1 := int(shop_node.get_meta("shop_price_1"))
		var item2 := str(shop_node.get_meta("shop_item_2"))
		var price2 := int(shop_node.get_meta("shop_price_2"))
		var details1 := _describe_shop_item(item1, "Speed Potion 🧪", "Run fast!")
		var details2 := _describe_shop_item(item2, "Toy Hammer 🔨", "Break blocks!")
		var items := [
			{"id": item1, "name": details1.get("name", item1), "cost": price1, "desc": details1.get("desc", "")},
			{"id": item2, "name": details2.get("name", item2), "cost": price2, "desc": details2.get("desc", "")}
		]
		if shop_node.has_meta("shop_item_3"):
			var item3 := str(shop_node.get_meta("shop_item_3"))
			var price3 := int(shop_node.get_meta("shop_price_3") if shop_node.has_meta("shop_price_3") else 20)
			var details3 := _describe_shop_item(item3, "Toy Sword ⚔️", "Fight slimes!")
			items.append({"id": item3, "name": details3.get("name", item3), "cost": price3, "desc": details3.get("desc", "")})
		return items

	return [
		{"id": "alchemy_potion_speed", "name": "Speed Potion 🧪", "cost": 10, "desc": "Run super fast!"},
		{"id": "tool_hammer", "name": "Toy Hammer 🔨", "cost": 15, "desc": "Break blocks!"},
		{"id": "weapon_sword", "name": "Toy Sword ⚔️", "cost": 20, "desc": "3-hit strike combo!"}
	]


static func _describe_shop_item(item_id: String, fallback_name: String, fallback_desc: String) -> Dictionary:
	match item_id:
		"alchemy_potion_speed":
			return {"name": "Speed Potion 🧪", "desc": "Run fast!"}
		"alchemy_potion_jump":
			return {"name": "Jump Potion 🥤", "desc": "Jump higher!"}
		"tool_hammer":
			return {"name": "Toy Hammer 🔨", "desc": "Break blocks!"}
		"weapon_sword":
			return {"name": "Toy Sword ⚔️", "desc": "Fight slimes!"}
		"weapon_boomerang":
			return {"name": "Boomerang 🪃", "desc": "Throw and return!"}
		_:
			return {"name": fallback_name, "desc": fallback_desc}
