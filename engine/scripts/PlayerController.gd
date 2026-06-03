extends CharacterBody2D

@export var max_health: int = 100
@export var movement_speed: float = 220.0
@export var jump_force: float = -460.0
@export var gravity_scale: float = 1.0
@export var invincibility_duration: float = 0.8
@export var asset_id: String = ""

var current_health: int = max_health
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _invincible := false
var trail_particles: CPUParticles2D = null

# Powerup states
var speed_boost_timer: float = 0.0
var shield_active: bool = false
var double_jump_enabled: bool = false
var _jumps_remaining: int = 1
var giant_timer: float = 0.0
var is_giant: bool = false
var gravity_inverted: bool = false
var costume_tint: String = ""


# Water & Speed pad physics states
var inside_water: bool = false
var water_buoyancy: float = 0.5
var water_type: String = "normal"
var water_hurt_timer: float = 0.0
var speed_pad_velocity: Vector2 = Vector2.ZERO

# Gadget states
var has_glider: bool = false
var has_jetpack: bool = false
var jetpack_fuel: float = 0.0
var has_hammer: bool = false
var has_lantern: bool = false
var lantern_light: PointLight2D = null



func _ready() -> void:
	current_health = max_health
	_ready_trail_particles()


func _ready_trail_particles() -> void:
	trail_particles = CPUParticles2D.new()
	trail_particles.name = "HeroTrailParticles"
	trail_particles.amount = 15
	trail_particles.lifetime = 0.4
	trail_particles.speed_scale = 1.0
	trail_particles.explosiveness = 0.0
	trail_particles.randomness = 0.2
	trail_particles.direction = Vector2(-1, 0)
	trail_particles.spread = 15.0
	trail_particles.gravity = Vector2.ZERO
	trail_particles.initial_velocity_min = 20.0
	trail_particles.initial_velocity_max = 50.0
	
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	trail_particles.scale_amount_curve = curve
	trail_particles.scale_amount_min = 4.0
	trail_particles.scale_amount_max = 8.0
	
	trail_particles.color = Color(0.2, 0.6, 1.0, 0.6)
	trail_particles.emitting = false
	add_child(trail_particles)


func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Player healed by %d HP. HP now: %d/%d" % [amount, current_health, max_health])
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("+%d HP" % amount, global_position, Color.GREEN)


func apply_powerup(type: String) -> void:
	var main := get_tree().get_root().get_node_or_null("Main")
	match type:
		"speed":
			speed_boost_timer = 5.0
			print("Player acquired Speed Boost!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"shield":
			shield_active = true
			print("Player acquired Shield!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"double_jump":
			double_jump_enabled = true
			print("Player acquired Double Jump Shoes!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"glider":
			has_glider = true
			print("Player acquired Glider Cape!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"jetpack":
			has_jetpack = true
			jetpack_fuel = 100.0
			print("Player acquired Jetpack!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"giant":
			giant_timer = 6.0
			is_giant = true
			scale = Vector2(2.0, 2.0)
			print("Player acquired Giant Growth!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"gravity":
			gravity_inverted = not gravity_inverted
			gravity_scale = -1.0 if gravity_inverted else 1.0
			print("Player toggled gravity!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"hammer":
			has_hammer = true
			print("Player acquired Toy Hammer!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")
		"lantern":
			has_lantern = true
			print("Player acquired Lantern!")
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("coin")

	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text(type.replace("_", " ").to_upper() + "!", global_position, Color.CYAN)


func take_damage(amount: int) -> void:
	var main_ref = get_tree().get_root().get_node_or_null("Main")
	if main_ref != null:
		var diff = main_ref.get("difficulty")
		if diff == "creative":
			return
		elif diff == "easy":
			amount = int(max(1.0, float(amount) * 0.5))

	if _invincible:
		return

	if shield_active:
		shield_active = false
		print("Shield absorbed damage!")
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("coin") # Chime on shield break
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("SHIELD BLOCK!", global_position, Color.MAGENTA)
		_invincible = true
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.5, 0.1)
		tween.tween_property(self, "modulate:a", 1.0, 0.1)
		tween.chain().tween_callback(func(): 
			_invincible = false
			modulate.a = 1.0
		)
		return

	current_health -= amount
	print("Player took %d damage! HP now: %d/%d" % [amount, current_health, max_health])

	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("-%d HP" % amount, global_position, Color.RED)

	if main != null and main.has_method("play_custom_sfx"):
		main.play_custom_sfx(asset_id, "hit")

	if current_health <= 0:
		current_health = 0
		print("Player has died!")
		if main != null:
			if main.has_method("handle_player_death"):
				main.call_deferred("handle_player_death")
			elif main.has_method("_respawn_player"):
				main.call_deferred("_respawn_player")
		return

	_invincible = true
	var tween := create_tween()
	tween.set_loops(int(invincibility_duration / 0.1))
	tween.tween_property(self, "modulate:a", 0.3, 0.05)
	tween.tween_property(self, "modulate:a", 1.0, 0.05)
	tween.chain().tween_callback(func():
		_invincible = false
		modulate.a = 1.0
	)


func _physics_process(delta: float) -> void:
	var is_creative := false
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.get("difficulty") == "creative":
		is_creative = true

	# Configure up direction dynamically
	if gravity_inverted:
		up_direction = Vector2.DOWN
	else:
		up_direction = Vector2.UP

	# Handle lantern illumination
	if has_lantern:
		if lantern_light == null:
			lantern_light = PointLight2D.new()
			var tex := GradientTexture2D.new()
			tex.fill = GradientTexture2D.FILL_RADIAL
			tex.fill_from = Vector2(0.5, 0.5)
			tex.fill_to = Vector2(1.0, 0.5)
			var grad := Gradient.new()
			grad.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
			tex.gradient = grad
			tex.width = 300
			tex.height = 300
			
			lantern_light.texture = tex
			lantern_light.energy = 1.3
			lantern_light.blend_mode = Light2D.BLEND_MODE_ADD
			add_child(lantern_light)

	# Handle water damage tick
	if inside_water and (water_type == "toxic" or water_type == "lava"):
		water_hurt_timer -= delta
		if water_hurt_timer <= 0.0:
			var dmg = 8 if water_type == "toxic" else 25
			take_damage(dmg)
			water_hurt_timer = 0.8 # tick every 0.8 seconds

	# Handle giant timer
	if giant_timer > 0.0:
		giant_timer -= delta
		is_giant = true
		scale = Vector2(2.0, 2.0)
	elif is_giant:
		is_giant = false
		scale = Vector2(1.0, 1.0)

	var active_speed := movement_speed
	if is_creative:
		modulate = Color(1.0, 0.9, 0.4) # Gold modulation for creative mode
	elif speed_boost_timer > 0.0:
		speed_boost_timer -= delta
		active_speed = movement_speed * 1.6
		modulate = Color(0.4, 1.0, 1.0) # Cyan modulation for speed
	elif shield_active:
		modulate = Color(1.0, 0.5, 1.0) # Pink modulation for shield
	elif is_giant:
		modulate = Color(1.0, 0.8, 0.2) # Orange/gold modulation for giant
	elif gravity_inverted:
		modulate = Color(0.6, 0.4, 1.0) # Purple modulation for gravity
	else:
		if not _invincible:
			if costume_tint != "" and costume_tint != "default":
				modulate = Color(costume_tint)
			else:
				modulate = Color(1.0, 1.0, 1.0)


	var conveyor_velocity := Vector2.ZERO
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.has_meta("is_conveyor") and collider.get_meta("is_conveyor") == true:
				var dir: float = collider.get_meta("conveyor_direction")
				var spd: float = collider.get_meta("conveyor_speed")
				conveyor_velocity.x = dir * spd

	var input_dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * active_speed + conveyor_velocity.x

	# Apply speed boost pad impulse vector if active
	if speed_pad_velocity.length_squared() > 10.0:
		velocity += speed_pad_velocity
		speed_pad_velocity = speed_pad_velocity.move_toward(Vector2.ZERO, delta * 900.0)

	# Water buoyancy, jetpack thrust, glider cape glide, or standard gravity
	if is_creative:
		var v_input := Input.get_axis("ui_up", "ui_down")
		velocity.y = v_input * active_speed
		if Input.is_action_pressed("ui_accept"):
			velocity.y = -active_speed if not gravity_inverted else active_speed
	elif inside_water:
		velocity.y += gravity * (1.0 - water_buoyancy) * delta
		velocity.y = clamp(velocity.y, -220.0, 180.0)
	elif has_jetpack and jetpack_fuel > 0.0 and (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")):
		velocity.y = -260.0 if not gravity_inverted else 260.0
		jetpack_fuel -= delta * 35.0
		modulate = Color(1.0, 0.5, 0.2) # Jetpack orange visual tint
		if main != null and main.has_method("spawn_floating_text") and randf() < delta * 4.0:
			main.spawn_floating_text("🔥", global_position, Color.ORANGE)
	elif has_glider and not is_on_floor() and (velocity.y > 0.0 if not gravity_inverted else velocity.y < 0.0) and (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")):
		if gravity_inverted:
			velocity.y = max(velocity.y, -45.0)
		else:
			velocity.y = min(velocity.y, 45.0)
		modulate = Color(1.0, 0.8, 0.5) # Glider yellow/peach visual tint
	elif not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
	
	if is_on_floor():
		_jumps_remaining = 2 if double_jump_enabled else 1

	if not is_creative and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")):
		var did_jump := false
		if inside_water:
			# Swim stroke
			velocity.y = -220.0 if not gravity_inverted else 220.0
			did_jump = true
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("jump")
		elif is_on_floor():
			velocity.y = jump_force if not gravity_inverted else -jump_force
			_jumps_remaining = 1 if double_jump_enabled else 0
			did_jump = true
		elif _jumps_remaining > 0:
			velocity.y = jump_force * 0.9 if not gravity_inverted else -jump_force * 0.9
			_jumps_remaining -= 1
			did_jump = true
			scale = Vector2(0.8, 1.3)
			var t := create_tween()
			t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

		if did_jump:
			if main != null and main.has_method("play_custom_sfx"):
				main.play_custom_sfx(asset_id, "jump")

	move_and_slide()

	# Destructible block check
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != null and collider.has_meta("is_destructible") and collider.get_meta("is_destructible") == true:
			if has_hammer:
				collider.call_deferred("shatter")
				if main != null and main.has_method("play_sfx"):
					main.play_sfx("hit")
			else:
				if main != null and main.has_method("spawn_floating_text") and randf() < delta * 1.5:
					main.spawn_floating_text("NEED HAMMER! 🔨", global_position, Color.GOLD)

	# Stomp check immediately after move_and_slide()
	var is_falling := velocity.y > 0.0 if not gravity_inverted else velocity.y < 0.0
	if not is_on_floor() and is_falling:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.has_method("take_damage") and not collider.name.begins_with("Player"):
				var normal = collision.get_normal()
				var is_stomp = normal.y < -0.7 if not gravity_inverted else normal.y > 0.7
				if is_stomp:
					var bounce = jump_force * 0.75
					velocity.y = bounce if not gravity_inverted else -bounce
					
					var stomp_dmg = 40 if is_giant else 20
					collider.take_damage(stomp_dmg)
					
					if main != null and main.has_method("play_sfx"):
						main.play_sfx("jump")
					break

	# Update trail particles
	if trail_particles != null:
		if velocity.length_squared() > 100.0:
			trail_particles.emitting = true
			trail_particles.direction = -velocity.normalized()
		else:
			trail_particles.emitting = false
		trail_particles.color = modulate
		trail_particles.color.a = 0.6


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var emoji := ""
		match event.keycode:
			KEY_1: emoji = "😊"
			KEY_2: emoji = "😡"
			KEY_3: emoji = "😱"
			KEY_4: emoji = "🎉"
			KEY_5: emoji = "💤"
		if emoji != "":
			show_emote(emoji)


func show_emote(emoji: String) -> void:
	var old_lbl = get_node_or_null("EmoteLabel")
	if old_lbl != null:
		old_lbl.queue_free()
		
	var label := Label.new()
	label.name = "EmoteLabel"
	label.text = emoji
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var settings := LabelSettings.new()
	settings.font_size = 28
	settings.outline_size = 4
	settings.outline_color = Color.BLACK
	label.label_settings = settings
	
	label.size = Vector2(80, 40)
	label.position = Vector2(-40, -60)
	add_child(label)
	
	label.scale = Vector2(0.2, 0.2)
	label.pivot_offset = Vector2(40, 20)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", -90.0, 1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.15)
	
	var fade_tween := create_tween()
	fade_tween.tween_interval(0.9)
	fade_tween.tween_property(label, "modulate:a", 0.0, 0.3)
	fade_tween.chain().tween_callback(label.queue_free)

