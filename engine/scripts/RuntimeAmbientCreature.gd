extends CharacterBody2D

var creature_type: String = "butterfly"
var gravity: float = 600.0
var speed: float = 80.0
var _timer: float = 0.0
var _idle_timer: float = 0.0
var _panic_mode: bool = false
var _panic_timer: float = 0.0
var _dir: float = 1.0

func _ready() -> void:
	if has_meta("creature_type"):
		creature_type = str(get_meta("creature_type"))
	_dir = 1.0 if randf() > 0.5 else -1.0
	
	# Add Label visual if not present
	var label = get_node_or_null("Label")
	if label == null:
		label = Label.new()
		label.name = "Label"
		label.text = "🦋" if creature_type == "butterfly" else "🐿️"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var settings = LabelSettings.new()
		settings.font_size = 20
		label.label_settings = settings
		label.size = Vector2(24, 24)
		label.position = -Vector2(12, 12)
		label.pivot_offset = Vector2(12, 12)
		add_child(label)

func _physics_process(delta: float) -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	
	var player = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return
		
	# 1. Panic checks (Approaching player or nearby hazards)
	var player_dist = global_position.distance_to(player.global_position)
	var panic_trigger_dist = 70.0 if creature_type == "butterfly" else 90.0
	var is_player_near = player_dist < panic_trigger_dist
	
	var is_hazard_near := false
	var spawned = main.get("spawned_entities")
	if spawned is Array:
		for ent in spawned:
			var node = ent as Node2D
			if node != null and is_instance_valid(node) and node != self:
				var asset_id = str(node.get_meta("asset_id")) if node.has_meta("asset_id") else ""
				if "hazard" in asset_id or "fire" in asset_id or "chemistry_fire" in asset_id:
					if global_position.distance_to(node.global_position) < 80.0:
						is_hazard_near = true
						break
						
	if is_player_near or is_hazard_near:
		if not _panic_mode:
			_panic_mode = true
			_panic_timer = 2.0
			# Choose panic direction away from threat
			var threat_pos = player.global_position
			_dir = sign(global_position.x - threat_pos.x)
			if _dir == 0.0: _dir = 1.0 if randf() > 0.5 else -1.0
			if main.has_method("spawn_floating_text") and randf() < 0.05:
				main.spawn_floating_text("❓ Panic!", global_position, Color.GOLDENROD)
	
	if _panic_mode:
		_panic_timer -= delta
		if _panic_timer <= 0.0:
			_panic_mode = false
			
	# 2. Movement logic based on type
	if creature_type == "butterfly":
		_process_butterfly(delta)
	else:
		_process_squirrel(delta)
		
	var label = get_node_or_null("Label")
	if label != null:
		label.scale.x = _dir
		if _panic_mode:
			label.modulate = Color(1.0, 0.5, 0.5)
		else:
			label.modulate = Color(1.0, 1.0, 1.0)

	move_and_slide()

func _process_butterfly(delta: float) -> void:
	_timer += delta
	if _panic_mode:
		# Fly up and away rapidly
		velocity.x = _dir * speed * 2.2
		velocity.y = -speed * 1.5
	else:
		# Flutter in gentle sine waves
		velocity.x = _dir * speed * 0.5
		velocity.y = sin(_timer * 4.0) * 30.0
		# Occasionally switch horizontal direction
		if randf() < delta * 0.15:
			_dir *= -1.0

func _process_squirrel(delta: float) -> void:
	# Squirrel experiences gravity
	velocity.y += gravity * delta
	
	if _panic_mode:
		# Run and bound away
		velocity.x = _dir * speed * 2.5
		if is_on_floor() and (is_on_wall() or randf() < 0.05):
			velocity.y = -220.0 # jump over obstacles
	else:
		# Idle or walk pacing
		_idle_timer -= delta
		if _idle_timer <= 0.0:
			_idle_timer = randf_range(1.5, 4.0)
			# 35% chance to pace, 65% chance to sit idle
			if randf() < 0.35:
				_dir = 1.0 if randf() > 0.5 else -1.0
				velocity.x = _dir * speed * 0.4
			else:
				velocity.x = 0.0
				
		if velocity.x != 0.0 and is_on_floor() and is_on_wall():
			velocity.y = -150.0 # jump if hitting a wall
