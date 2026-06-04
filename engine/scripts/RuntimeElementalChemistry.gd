extends RefCounted


static func process(main: Node2D, active_player: Node2D) -> void:
	var fires := []
	var waters := []
	var ices := []
	var lightnings := []
	var blocks := []

	for ent in main.get_children():
		if is_instance_valid(ent) and ent.has_meta("asset_id"):
			var asset_id = ent.get_meta("asset_id")
			if asset_id == "chemistry_fire":
				fires.append(ent)
			elif asset_id == "chemistry_water":
				waters.append(ent)
			elif asset_id == "chemistry_ice":
				ices.append(ent)
			elif asset_id == "chemistry_lightning":
				lightnings.append(ent)

	for ent in main.get_children():
		if is_instance_valid(ent) and ent.has_meta("chemistry_material"):
			blocks.append(ent)
			if ent.get_meta("is_burning", false):
				fires.append(ent)
			if ent.get_meta("is_shocked", false):
				lightnings.append(ent)

	for ent in main.get_children():
		if is_instance_valid(ent) and ent.name.begins_with("water_block"):
			waters.append(ent)

	_process_ignition(main, fires, blocks)
	_process_extinguishing(main, waters, blocks)
	_process_freezing(main, ices, waters)
	var shocked_blocks := _find_shocked_blocks(lightnings, blocks)
	_apply_conduction(main, blocks, shocked_blocks)
	_apply_shock_to_nearby_bodies(main, active_player, blocks)
	_tick_burning_blocks(main, blocks)


static func _process_ignition(main: Node2D, fires: Array, blocks: Array) -> void:
	for fire in fires:
		for block in blocks:
			if block.get_meta("is_flammable", false) and not block.get_meta("is_burning", false):
				if fire.global_position.distance_to(block.global_position) < 64.0:
					block.set_meta("is_burning", true)
					block.modulate = Color.ORANGE_RED
					_add_status_label(block, "FireEmoji", "🔥")
					_spawn_text(main, "🔥 IGNITE!", block.global_position, Color.ORANGE)


static func _process_extinguishing(main: Node2D, waters: Array, blocks: Array) -> void:
	for water in waters:
		for fire_block in blocks:
			if fire_block.get_meta("is_burning", false):
				if water.global_position.distance_to(fire_block.global_position) < 80.0:
					fire_block.set_meta("is_burning", false)
					fire_block.set_meta("burn_timer", 4.0)
					fire_block.modulate = Color.WHITE
					var lbl = fire_block.get_node_or_null("FireEmoji")
					if lbl:
						lbl.queue_free()
					_spawn_text(main, "💧 EXTINGUISHED", fire_block.global_position, Color.CYAN)


static func _process_freezing(main: Node2D, ices: Array, waters: Array) -> void:
	for ice in ices:
		for water in waters:
			if water.name.begins_with("water_block") and not water.get_meta("is_ice", false):
				if ice.global_position.distance_to(water.global_position) < 120.0:
					water.set_meta("is_ice", true)
					_spawn_text(main, "❄️ FROZEN!", water.global_position, Color.CYAN)
					_add_frozen_block(main, water)


static func _find_shocked_blocks(lightnings: Array, blocks: Array) -> Dictionary:
	var shocked_nodes := []
	var visited := {}

	for lightning in lightnings:
		for block in blocks:
			if block.get_meta("is_conductive", false) and not visited.has(block):
				if lightning.global_position.distance_to(block.global_position) < 70.0:
					shocked_nodes.append(block)
					visited[block] = true

	var index := 0
	while index < shocked_nodes.size():
		var current = shocked_nodes[index]
		index += 1
		for block in blocks:
			if block.get_meta("is_conductive", false) and not visited.has(block):
				if current.global_position.distance_to(block.global_position) < 64.0:
					shocked_nodes.append(block)
					visited[block] = true

	return visited


static func _apply_conduction(main: Node2D, blocks: Array, shocked_blocks: Dictionary) -> void:
	for block in blocks:
		if block.get_meta("is_conductive", false):
			if shocked_blocks.has(block):
				if not block.get_meta("is_shocked", false):
					block.set_meta("is_shocked", true)
					block.set_meta("shock_timer", 1.5)
					block.modulate = Color.YELLOW
					_add_status_label(block, "ShockEmoji", "⚡")
					_spawn_text(main, "⚡ CONDUCT!", block.global_position, Color.YELLOW)
			else:
				if block.get_meta("is_shocked", false):
					block.set_meta("is_shocked", false)
					block.modulate = Color.WHITE
					var lbl = block.get_node_or_null("ShockEmoji")
					if lbl:
						lbl.queue_free()


static func _apply_shock_to_nearby_bodies(main: Node2D, active_player: Node2D, blocks: Array) -> void:
	if active_player != null and is_instance_valid(active_player):
		for block in blocks:
			if block.get_meta("is_shocked", false):
				if active_player.global_position.distance_to(block.global_position) < 48.0:
					if active_player.has_method("set_shocked"):
						active_player.set_shocked(1.5)

	for ent in main.get_children():
		if is_instance_valid(ent) and ent.has_method("set_shocked") and not ent.name.begins_with("Player"):
			for block in blocks:
				if block.get_meta("is_shocked", false):
					if ent.global_position.distance_to(block.global_position) < 48.0:
						ent.set_shocked(1.5)


static func _tick_burning_blocks(main: Node2D, blocks: Array) -> void:
	for block in blocks:
		if block.get_meta("is_burning", false):
			var burn_time = block.get_meta("burn_timer") - 0.1
			block.set_meta("burn_timer", burn_time)
			if burn_time <= 0.0:
				_spawn_text(main, "🪵 ASH!", block.global_position, Color.DARK_GRAY)
				block.queue_free()


static func _add_frozen_block(main: Node2D, water: Node2D) -> void:
	var ice_block := StaticBody2D.new()
	ice_block.name = "FrozenIceBlock"
	ice_block.global_position = water.global_position
	ice_block.set_meta("is_ice", true)
	var rect = water.get_node_or_null("ColorRect")
	var water_size = rect.size if rect else Vector2(128, 128)
	_add_box_collision(ice_block, water_size)

	var ice_rect := ColorRect.new()
	ice_rect.color = Color(0.4, 0.8, 1.0, 0.8)
	ice_rect.size = water_size
	ice_rect.position = -water_size * 0.5
	ice_block.add_child(ice_rect)

	main.add_child(ice_block)
	water.visible = false
	water.set_deferred("monitoring", false)
	water.set_deferred("monitorable", false)


static func _add_box_collision(parent: Node, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	parent.add_child(collision)


static func _add_status_label(parent: Node, label_name: String, text: String) -> void:
	var label := Label.new()
	label.name = label_name
	label.text = text
	label.size = Vector2(40, 40)
	label.position = Vector2(-20, -35)
	parent.add_child(label)


static func _spawn_text(main: Node2D, text: String, position: Vector2, color: Color) -> void:
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text(text, position, color)
