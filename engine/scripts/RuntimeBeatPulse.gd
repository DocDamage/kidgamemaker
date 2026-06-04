extends RefCounted


static func update(root: Node, pulse_timer: float, delta: float) -> float:
	pulse_timer += delta
	var beat_wave := (sin(pulse_timer * PI * 4.0) + 1.0) * 0.5
	for child in root.get_children():
		if child.has_meta("emits_light") and child.get_meta("emits_light") == true:
			var light = child.get_node_or_null("PointLight2D")
			if light != null:
				var base_energy = float(child.get_meta("light_energy"))
				light.energy = base_energy + beat_wave * 0.5
	return pulse_timer
