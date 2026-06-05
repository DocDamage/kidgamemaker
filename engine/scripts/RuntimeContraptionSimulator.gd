extends RefCounted


static func update(contraptions: Array, delta: float) -> void:
	for contraption in contraptions:
		if not is_instance_valid(contraption):
			continue

		var power_state := _collect_power_state(contraption)
		_apply_power_state(power_state, delta)
		_apply_forces(contraption, delta)


static func _collect_power_state(contraption: Node) -> Dictionary:
	var batteries := []
	var active_consumers := []
	var total_energy := 0.0

	for child in contraption.get_children():
		if child.has_meta("asset_id"):
			var asset_id = child.get_meta("asset_id")
			if asset_id == "zonai_battery":
				total_energy += child.get("energy")
				batteries.append(child)
			elif asset_id in ["zonai_fan", "zonai_rocket", "zonai_beam", "zonai_flamethrower", "zonai_stabilizer"]:
				if asset_id == "zonai_rocket":
					if child.get("active"):
						active_consumers.append(child)
				else:
					active_consumers.append(child)

	return {
		"batteries": batteries,
		"active_consumers": active_consumers,
		"total_energy": total_energy,
	}


static func _apply_power_state(power_state: Dictionary, delta: float) -> void:
	var active_consumers: Array = power_state["active_consumers"]
	var batteries: Array = power_state["batteries"]
	var total_energy: float = power_state["total_energy"]
	var drain_rate := _consumer_drain_rate(active_consumers, delta)

	if drain_rate > 0.0:
		if total_energy > 0.0:
			_drain_batteries(batteries, drain_rate)
			for child in active_consumers:
				child.set("powered", true)
		else:
			for child in active_consumers:
				_power_down_consumer(child)
	else:
		for child in active_consumers:
			child.set("powered", true)


static func _consumer_drain_rate(active_consumers: Array, delta: float) -> float:
	var drain_rate := 0.0
	for child in active_consumers:
		var asset_id = child.get_meta("asset_id")
		if asset_id == "zonai_fan":
			drain_rate += 10.0 * delta
		elif asset_id == "zonai_rocket":
			drain_rate += 50.0 * delta
		elif asset_id == "zonai_beam":
			drain_rate += 15.0 * delta
		elif asset_id == "zonai_flamethrower":
			drain_rate += 20.0 * delta
		elif asset_id == "zonai_stabilizer":
			drain_rate += 5.0 * delta
	return drain_rate


static func _drain_batteries(batteries: Array, drain_rate: float) -> void:
	var remaining_drain := drain_rate
	for battery in batteries:
		var energy = battery.get("energy")
		var drained = min(energy, remaining_drain)
		battery.set("energy", energy - drained)
		remaining_drain -= drained
		if remaining_drain <= 0.0:
			break


static func _power_down_consumer(child: Node) -> void:
	child.set("powered", false)
	var wind_particles = child.get_node_or_null("WindParticles")
	if wind_particles:
		wind_particles.emitting = false
	var fire_particles = child.get_node_or_null("FireParticles")
	if fire_particles:
		fire_particles.emitting = false


static func _apply_forces(contraption: RigidBody2D, delta: float) -> void:
	for child in contraption.get_children():
		var asset_id = ""
		if child.has_meta("asset_id"):
			asset_id = child.get_meta("asset_id")
		
		# 1. Stabilizer check (keeps contraption upright)
		if child.has_meta("is_stabilizer") and child.get("powered"):
			var restore_torque = -contraption.rotation * 50000.0 - contraption.angular_velocity * 10000.0
			contraption.apply_torque(restore_torque)

		# 2. Steering Stick check
		if child.has_meta("is_steering_stick") and child.get("powered"):
			var main = contraption.get_parent()
			if main != null and main.has_method("get"):
				var player = main.get("active_player")
				if player != null and is_instance_valid(player):
					var dismount_timer: float = child.get_meta("dismount_timer") if child.has_meta("dismount_timer") else 0.0
					if dismount_timer > 0.0:
						child.set_meta("dismount_timer", dismount_timer - delta)
						continue

					var dist = child.global_position.distance_to(player.global_position)
					if dist < 45.0:
						player.global_position = child.global_position
						player.velocity = Vector2.ZERO
						
						if player.has_method("is_jump_just_pressed") and player.is_jump_just_pressed():
							child.set_meta("dismount_timer", 1.0)
							player.velocity = Vector2(0, -400.0)
							continue
						
						var thrust := 0.0
						var torque := 0.0
						if player.has_method("is_up_pressed") and player.is_up_pressed():
							thrust = 1000.0
						elif player.has_method("is_down_pressed") and player.is_down_pressed():
							thrust = -600.0
						
						if player.has_method("is_left_pressed") and player.is_left_pressed():
							torque = -15000.0
						elif player.has_method("is_right_pressed") and player.is_right_pressed():
							torque = 15000.0
							
						if thrust != 0.0:
							var force_dir = Vector2.RIGHT.rotated(contraption.rotation)
							contraption.apply_central_force(force_dir * thrust)
						if torque != 0.0:
							contraption.apply_torque(torque)

		# 3. Flamethrower check
		if asset_id == "zonai_flamethrower" and child.get("powered"):
			var fire = child.get_node_or_null("FireParticles")
			if fire and not fire.emitting:
				fire.emitting = true
				
			var main = contraption.get_parent()
			if main != null and main.has_method("get"):
				var entities = main.get("spawned_entities")
				if typeof(entities) == TYPE_ARRAY:
					var dir = child.get("force_direction").rotated(contraption.rotation)
					for entity in entities:
						if is_instance_valid(entity) and entity != contraption and entity.has_method("take_damage"):
							var dist = child.global_position.distance_to(entity.global_position)
							if dist < 90.0:
								var to_entity = (entity.global_position - child.global_position).normalized()
								if dir.dot(to_entity) > 0.65:
									entity.take_damage(2)

		if asset_id == "zonai_fan" and child.get("powered"):
			_apply_directional_force(contraption, child, "force_direction", "force_magnitude")
		elif asset_id == "zonai_rocket" and child.get("powered") and child.get("active"):
			_apply_rocket_force(contraption, child, delta)
		elif asset_id == "zonai_balloon":
			var magnitude = child.get("buoyancy_force")
			var offset = child.position.rotated(contraption.rotation)
			contraption.apply_force(Vector2.UP * magnitude, offset)


static func _apply_rocket_force(contraption: RigidBody2D, child: Node2D, delta: float) -> void:
	_apply_directional_force(contraption, child, "force_direction", "force_magnitude")
	var active_time = child.get("active_time") - delta
	child.set("active_time", active_time)
	if active_time <= 0.0:
		child.set("active", false)
		var fire_particles = child.get_node_or_null("FireParticles")
		if fire_particles:
			fire_particles.emitting = false


static func _apply_directional_force(contraption: RigidBody2D, child: Node2D, direction_prop: String, magnitude_prop: String) -> void:
	var direction = child.get(direction_prop)
	var magnitude = child.get(magnitude_prop)
	var offset = child.position.rotated(contraption.rotation)
	var force_direction = direction.rotated(contraption.rotation)
	contraption.apply_force(force_direction * magnitude, offset)
