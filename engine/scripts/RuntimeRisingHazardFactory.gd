extends RefCounted


static func spawn_from_settings(parent: Node, spawned_entities: Array, death_y_threshold: float, settings: Dictionary, hazard_script: Script) -> void:
	var hazard_type := str(settings.get("rising_hazard_type", ""))
	if hazard_type != "water" and hazard_type != "lava":
		return
	var speed := float(settings.get("rising_hazard_speed", 20.0))
	var hazard := create_hazard(hazard_type, speed, death_y_threshold, hazard_script)
	parent.add_child(hazard)
	spawned_entities.append(hazard)
	print("Spawned rising hazard type: ", hazard_type, " speed: ", speed)


static func create_hazard(type: String, speed: float, death_y_threshold: float, hazard_script: Script) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = "RisingDanger"

	var color := Color(0.2, 0.4, 0.8, 0.5)
	if type == "lava":
		color = Color(0.9, 0.25, 0.1, 0.6)
	rect.color = color

	rect.size = Vector2(80000.0, 1500.0)
	rect.position = Vector2(-40000.0, death_y_threshold - 50.0)

	var label := Label.new()
	label.text = "🌋 RISING MAGMA! CLIMB! 🌋" if type == "lava" else "🌊 FLOOD WARNING! SWIM! 🌊"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var label_settings := LabelSettings.new()
	label_settings.font_size = 32
	label_settings.font_color = Color.WHITE
	label_settings.outline_size = 6
	label_settings.outline_color = Color.BLACK
	label.label_settings = label_settings
	label.size = Vector2(1000, 50)
	label.position = Vector2(40000.0 - 500.0, 20.0)
	rect.add_child(label)

	rect.set_script(hazard_script)
	rect.set("rising_speed", speed)
	rect.set("hazard_type", type)
	return rect
