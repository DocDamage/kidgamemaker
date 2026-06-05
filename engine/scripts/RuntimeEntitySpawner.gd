extends RefCounted


static func spawn(app: Node2D, data: Dictionary) -> Node2D:
	var asset_id := str(data.get("asset_id", ""))
	if asset_id == "":
		push_warning("Entity missing asset_id.")
		return null

	var sidecar: Dictionary = app._load_sidecar(asset_id, str(data.get("category", "")))
	var runtime_template := str(sidecar.get("runtime_template", data.get("type", "decoration")))
	var type_str := str(data.get("type", ""))
	if (runtime_template == "" or runtime_template == "decoration") and type_str != "":
		runtime_template = type_str

	var node := _create_node(app, data, sidecar, asset_id, runtime_template)
	_prepare_node(app, node, data, sidecar, asset_id)
	_register_node(app, node, data, sidecar, runtime_template, asset_id)

	print("Spawned ", asset_id, " as ", runtime_template, " at ", node.global_position)
	return node


static func _create_node(
	app: Node2D,
	data: Dictionary,
	sidecar: Dictionary,
	asset_id: String,
	runtime_template: String
) -> Node2D:
	match runtime_template:
		"player":
			return app._make_player(data, sidecar)
		"terrain":
			return app._make_terrain(data, sidecar)
		"enemy":
			return app._make_enemy(data, sidecar)
		"collectible":
			return app._make_collectible(data, sidecar)
		"key_collectible":
			return app._make_key_collectible(data, sidecar)
		"checkpoint":
			return app._make_checkpoint(data, sidecar)
		"portal":
			return app._make_portal(data, sidecar)
		"locked_door":
			return app._make_locked_door(data, sidecar)
		"particles":
			return app._make_particles(data, sidecar)
		"trigger":
			if asset_id == "trigger_pressure_plate":
				return app._make_pressure_plate(data, sidecar)
			return app._make_trigger(data, sidecar)
		"gate":
			return app._make_gate(data, sidecar)
		"jelly":
			return app._make_jelly(data, sidecar)
		"speed_pad":
			return app._make_speed_pad(data, sidecar)
		"speech_sign":
			return app._make_speech_sign(data, sidecar)
		"water_block":
			return app._make_water_block(data, sidecar)
		"pet":
			return app._make_pet(data, sidecar)
		"crumbling_cloud":
			return app._make_crumbling_cloud(data, sidecar)
		"hazard":
			return app._make_hazard(data, sidecar)
		"destructible_terrain":
			return app._make_destructible_terrain(data, sidecar)
		"shopkeeper":
			return app._make_shopkeeper(data, sidecar)
		"conveyor":
			return app._make_conveyor(data, sidecar)
		"mystery_box":
			return app._make_mystery_box(data, sidecar)
		"gravity_zone":
			return app._make_gravity_zone(data, sidecar)
		"wind_zone":
			return app._make_wind_zone(data, sidecar)
		"target_practice":
			return app._make_target_practice(data, sidecar)
		"wood_block":
			return app._make_chemistry_block(data, sidecar, "wood")
		"grass_block":
			return app._make_chemistry_block(data, sidecar, "grass")
		"metal_block":
			return app._make_chemistry_block(data, sidecar, "metal")
		"zonai_fan":
			return app._make_zonai_device(data, sidecar, "zonai_fan")
		"zonai_rocket":
			return app._make_zonai_device(data, sidecar, "zonai_rocket")
		"zonai_balloon":
			return app._make_zonai_device(data, sidecar, "zonai_balloon")
		"zonai_spring":
			return app._make_zonai_device(data, sidecar, "zonai_spring")
		"zonai_beam":
			return app._make_zonai_device(data, sidecar, "zonai_beam")
		"zonai_battery":
			return app._make_zonai_device(data, sidecar, "zonai_battery")
		"zonai_steering_stick":
			return app._make_zonai_device(data, sidecar, "zonai_steering_stick")
		"zonai_stabilizer":
			return app._make_zonai_device(data, sidecar, "zonai_stabilizer")
		"zonai_flamethrower":
			return app._make_zonai_device(data, sidecar, "zonai_flamethrower")
		"companion_pikmin":
			return app._make_pikmin(data, sidecar)
		"companion_ghost":
			return app._make_ghost(data, sidecar)
		"companion_palico":
			return app._make_palico(data, sidecar)
		"companion_rush":
			return app._make_rush_adapter(data, sidecar)
		"anvil_upgrade":
			return app._make_anvil(data, sidecar)
		"crafting_bench":
			return app._make_crafting_bench(data, sidecar)
		"bbq_spit":
			return app._make_bbq_spit(data, sidecar)
		"wall_run_surface":
			return app._make_wall_run_surface(data, sidecar)
		"ceiling_run_surface":
			return app._make_ceiling_run_surface(data, sidecar)
		"speed_booster_block":
			return app._make_speed_booster_block(data, sidecar)
		"grapple_ring":
			return app._make_grapple_ring(data, sidecar)
		"climbable_vine":
			return app._make_climbable_vine(data, sidecar)
		"climbable_rope":
			return app._make_climbable_rope(data, sidecar)
		"clear_pipe":
			return app._make_clear_pipe(data, sidecar)
		"logic_and":
			return app._make_logic_gate(data, sidecar, "and")
		"logic_or":
			return app._make_logic_gate(data, sidecar, "or")
		"logic_not":
			return app._make_logic_gate(data, sidecar, "not")
		"compass":
			return app._make_compass(data, sidecar)
		"ambient_creature":
			return app._make_ambient_creature(data, sidecar)
		_:
			return app._make_decoration(data, sidecar)


static func _prepare_node(
	app: Node2D,
	node: Node2D,
	data: Dictionary,
	sidecar: Dictionary,
	asset_id: String
) -> void:
	node.name = str(data.get("instance_id", asset_id))
	node.global_position = app._read_position(data.get("position", {"x": 0, "y": 0}))
	node.z_index = app._z_index_for_bucket(app._placement_bucket(sidecar))
	node.set_meta("asset_id", asset_id)

	var modifiers: Dictionary = data.get("modifiers", {})
	node.set_meta("modifiers", modifiers)
	for key in modifiers:
		node.set_meta(key, modifiers[key])
	var scale_multiplier := float(modifiers.get("scale_multiplier", 1.0))
	node.scale = Vector2(scale_multiplier, scale_multiplier)


static func _register_node(
	app: Node2D,
	node: Node2D,
	data: Dictionary,
	sidecar: Dictionary,
	runtime_template: String,
	_asset_id: String
) -> void:
	node.set_meta("runtime_template", runtime_template)
	app.add_child(node)
	app.spawned_entities.append(node)

	if runtime_template == "player":
		app.spawn_point = node.global_position
		if app.get("active_player_1") == null:
			app.active_player_1 = node
			node.set("player_index", 1)
			app.active_player = node
			app._attach_camera(node)
		else:
			app.active_player_2 = node
			node.set("player_index", 2)
			node.modulate = Color(0.5, 0.8, 1.0, 1.0)
		
		# Pre-populate starting backpack items if configured in modifiers
		var modifiers: Dictionary = data.get("modifiers", {})
		if modifiers.has("starting_items"):
			var items = modifiers.get("starting_items")
			if typeof(items) == TYPE_ARRAY:
				for item in items:
					if node.has_method("add_to_backpack"):
						node.add_to_backpack(str(item))

		if app.get("turf_war_enabled") == true:
			node.set("has_paint_gun", true)
			if node.has_method("add_to_backpack"):
				node.add_to_backpack("weapon_paint_gun")

		# Attach visual progression tracker
		if app.has_method("_attach_visual_progression"):
			app._attach_visual_progression(node)
	elif runtime_template == "checkpoint":
		if node is Area2D:
			node.body_entered.connect(func(body):
				if body == app.active_player:
					app._on_checkpoint_activated(node.global_position)
			)
	elif runtime_template == "portal":
		if node is Area2D:
			node.body_entered.connect(func(body):
				if body == app.active_player:
					app._on_portal_entered(node, data)
			)
			if str(data.get("instance_id", "")) == app.target_spawn_portal_id:
				app.found_spawn_portal_pos = node.global_position
	elif runtime_template == "locked_door":
		if node is Area2D:
			node.body_entered.connect(func(body):
				if body == app.active_player:
					app._on_locked_door_entered(node, data)
			)

	app._apply_lighting_if_needed(node, sidecar)
	app._apply_audio_if_needed(node, sidecar)
