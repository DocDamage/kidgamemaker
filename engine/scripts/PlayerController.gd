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
var hero_class: String = "warrior"
var max_mana: float = 100.0
var mana_points: float = 100.0
var dashes_spent: int = 0
var archer_shoot_cooldown: float = 0.0

# Powerup states
var speed_boost_timer: float = 0.0
var shield_active: bool = false
var double_jump_enabled: bool = false
var _jumps_remaining: int = 1
var giant_timer: float = 0.0
var is_giant: bool = false
var gravity_inverted: bool = false
var costume_tint: String = ""

# Phase A: Traversal & Combat State variables
var dash_timer: float = 0.0
var dash_cooldown: float = 0.0
var is_dashing: bool = false
var dash_direction: float = 1.0
var facing_direction: float = 1.0
var is_ground_pounding: bool = false

var has_sword: bool = false
var combo_step: int = 0
var combo_timer: float = 0.0
var attack_cooldown: float = 0.0
var charge_timer: float = 0.0
var is_charging: bool = false
var is_blocking: bool = false
var parry_window_timer: float = 0.0



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
	if hero_class == "warrior":
		max_health += 30
	elif hero_class == "rogue":
		movement_speed *= 1.25

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
		"sword":
			has_sword = true
			print("Player acquired Toy Sword!")
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

	if is_blocking:
		if parry_window_timer > 0.0:
			# Parry success!
			var main := get_tree().get_root().get_node_or_null("Main")
			if main != null:
				if main.has_method("play_sfx"): main.play_sfx("coin")
				if main.has_method("spawn_floating_text"):
					main.spawn_floating_text("🛡️ PARRY!", global_position, Color.GOLD)
			
			_stun_closest_enemy()
			
			_invincible = true
			var t := create_tween()
			t.tween_property(self, "modulate:a", 0.5, 0.05)
			t.tween_property(self, "modulate:a", 1.0, 0.05)
			t.chain().tween_callback(func(): _invincible = false)
			return
		else:
			# Standard Block
			var reduction = 0.1 if hero_class == "warrior" else 0.3
			amount = int(max(1.0, float(amount) * reduction))
			var main := get_tree().get_root().get_node_or_null("Main")
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("🛡️ BLOCKED!", global_position, Color.CYAN)

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
	if hero_class == "mage":
		mana_points = min(mana_points + 10.0 * delta, max_mana)
	if archer_shoot_cooldown > 0.0:
		archer_shoot_cooldown -= delta

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


	# Update timers
	if dash_timer > 0.0:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	if dash_cooldown > 0.0:
		dash_cooldown -= delta
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_step = 0
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if parry_window_timer > 0.0:
		parry_window_timer -= delta

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
	if input_dir != 0.0:
		facing_direction = sign(input_dir)

	# Handle Dash Input
	var can_dash_rogue = (hero_class == "rogue" and dashes_spent < 2 and not is_dashing)
	var can_dash_normal = (dash_cooldown <= 0.0 and not is_dashing)
	if (Input.is_physical_key_pressed(KEY_SHIFT) or Input.is_action_just_pressed("ui_select")) and (can_dash_normal or can_dash_rogue) and not is_blocking:
		is_dashing = true
		dash_timer = 0.2
		dash_direction = facing_direction
		velocity.y = 0.0
		
		if hero_class == "rogue":
			dashes_spent += 1
			if dashes_spent == 2:
				dash_cooldown = 0.5
			else:
				dash_cooldown = 0.15
		else:
			dash_cooldown = 1.2
			
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("jump")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("💨 DASH!", global_position, Color.CYAN)

	# Handle Ground Pound Input
	if not is_on_floor() and not inside_water and not is_creative and (Input.is_action_just_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)):
		if not is_ground_pounding:
			is_ground_pounding = true
			velocity.x = 0.0
			velocity.y = 650.0 if not gravity_inverted else -650.0
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("⬇️ SLAM!", global_position, Color.ORANGE)

	# Handle Shield Block & Parry Input
	if Input.is_physical_key_pressed(KEY_Z) and is_on_floor() and not is_dashing:
		if not is_blocking:
			is_blocking = true
			parry_window_timer = 0.18 # 180ms parry window
		active_speed = active_speed * 0.3
	else:
		is_blocking = false
		parry_window_timer = 0.0

	# Handle Melee Attack Input
	if Input.is_physical_key_pressed(KEY_X) and attack_cooldown <= 0.0 and not is_dashing and not is_blocking:
		if hero_class == "mage":
			attack_cooldown = 0.22
			_fire_mage_wand_bolt()
		elif has_sword:
			combo_timer = 1.0
			combo_step = (combo_step % 3) + 1
			var w_factor := 1.0
			if hero_class == "warrior":
				w_factor = 0.8
			attack_cooldown = (0.4 if combo_step == 3 else 0.25) * w_factor
			_execute_melee_strike(combo_step)

	# Handle Ranged / Special Input
	if Input.is_physical_key_pressed(KEY_C) and not is_dashing and not is_blocking:
		if hero_class == "archer":
			if archer_shoot_cooldown <= 0.0:
				_fire_archer_arrow()
				archer_shoot_cooldown = 0.3
		elif hero_class == "mage":
			if archer_shoot_cooldown <= 0.0:
				if mana_points >= 15.0:
					_fire_mage_magic_blast()
					mana_points -= 15.0
					archer_shoot_cooldown = 0.4
				else:
					if main != null and main.has_method("spawn_floating_text") and randf() < delta * 4.0:
						main.spawn_floating_text("NO MP! 🔮", global_position, Color.PURPLE)
		else:
			if not is_charging:
				is_charging = true
				charge_timer = 0.0
			charge_timer += delta
			var val = sin(charge_timer * 20.0) * 0.4 + 0.6
			modulate = Color(val, val, 1.0) if charge_timer < 1.0 else Color(1.0, val, val)
	else:
		if is_charging:
			is_charging = false
			_fire_projectile(charge_timer)
			charge_timer = 0.0

	# Apply Velocity
	if is_dashing:
		velocity.x = dash_direction * movement_speed * 3.2
		velocity.y = 0.0
	elif is_blocking:
		velocity.x = input_dir * active_speed
	elif is_ground_pounding:
		velocity.x = 0.0
	else:
		velocity.x = input_dir * active_speed + conveyor_velocity.x

	# Apply speed boost pad impulse vector if active
	if speed_pad_velocity.length_squared() > 10.0:
		velocity += speed_pad_velocity
		speed_pad_velocity = speed_pad_velocity.move_toward(Vector2.ZERO, delta * 900.0)

	# Water buoyancy, jetpack thrust, glider cape glide, or standard gravity
	if is_dashing or is_ground_pounding:
		pass
	elif is_creative:
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
		is_ground_pounding = false
		dashes_spent = 0

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
		elif is_on_wall():
			# WALL JUMP!
			var wall_normal := get_wall_normal()
			velocity.y = jump_force * 0.95
			velocity.x = wall_normal.x * movement_speed * 1.3
			_jumps_remaining = 1 if double_jump_enabled else 0
			did_jump = true
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("🧗 WALL JUMP!", global_position, Color.CHARTREUSE)
		elif _jumps_remaining > 0:
			velocity.y = jump_force * 0.9 if not gravity_inverted else -jump_force * 0.9
			_jumps_remaining -= 1
			did_jump = true
			if hero_class == "archer":
				dash_cooldown = 0.0
			scale = Vector2(0.8, 1.3)
			var t := create_tween()
			t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

		if did_jump:
			if main != null and main.has_method("play_custom_sfx"):
				main.play_custom_sfx(asset_id, "jump")

	move_and_slide()

	if is_ground_pounding and is_on_floor():
		is_ground_pounding = false
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("hit")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("💥 BOOM!", global_position, Color.GOLD)
		_execute_ground_pound_damage()

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


func _execute_melee_strike(step: int) -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	var text = "⚔️ SWING!"
	var dmg = 15
	var kback = 200.0
	if step == 2:
		text = "⚔️ SLASH!"
		dmg = 15
		kback = 220.0
	elif step == 3:
		text = "🔥 FINISHER!"
		dmg = 30
		kback = 450.0
		
	if hero_class == "warrior":
		dmg = int(dmg * 1.2)
		
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("hit")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text(text, global_position + Vector2(facing_direction * 24, -20), Color.RED if step == 3 else Color.WHITE)

	# Visual Slash effect: create a small ColorRect arc in front of player
	var slash := ColorRect.new()
	slash.color = Color(1.0, 1.0, 1.0, 0.7) if step < 3 else Color(1.0, 0.3, 0.1, 0.8)
	slash.size = Vector2(36, 12) if step < 3 else Vector2(48, 20)
	slash.position = Vector2(facing_direction * 16 - slash.size.x * 0.5, -12)
	add_child(slash)
	
	var tween = create_tween()
	tween.tween_property(slash, "scale:y", 0.0, 0.15)
	tween.chain().tween_callback(slash.queue_free)

	# Check collision with enemies on common layer (layer 1)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(48, 36) if step < 3 else Vector2(64, 48)
	query.shape = rect
	query.transform = Transform2D(0, global_position + Vector2(facing_direction * 28, 0))
	query.collision_mask = 1 # hits enemies
	
	var hits = space_state.intersect_shape(query)
	for hit in hits:
		var node = hit.get("collider")
		if node != null and node != self and node.has_method("take_damage"):
			node.take_damage(dmg)
			if "velocity" in node:
				node.velocity += Vector2(facing_direction * kback, -100.0)


func _fire_projectile(charge: float) -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var is_mega = charge >= 1.0
	var text = "⚡ MEGA BLAST!" if is_mega else "🔫 PEW!"
	var dmg = 40 if is_mega else 10
	var speed = 180.0 if is_mega else 300.0
	var size_vec = Vector2(24, 24) if is_mega else Vector2(10, 6)
	var color_tint = Color(1.0, 0.85, 0.1, 1.0) if is_mega else Color(0.1, 0.85, 1.0, 1.0)

	if main.has_method("play_sfx"):
		main.play_sfx("jump")
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text(text, global_position, Color.GOLD if is_mega else Color.CYAN)

	var bullet := Area2D.new()
	bullet.name = "PlayerProjectile"

	var visual := ColorRect.new()
	visual.color = color_tint
	visual.size = size_vec
	visual.position = -visual.size * 0.5
	bullet.add_child(visual)

	var shape := CircleShape2D.new()
	shape.radius = size_vec.x * 0.5
	var col := CollisionShape2D.new()
	col.shape = shape
	bullet.add_child(col)

	bullet.collision_layer = 0
	bullet.collision_mask = 1 # hits enemies

	var bullet_script := GDScript.new()
	bullet_script.source_code = "extends Area2D\nvar velocity := Vector2.ZERO\nfunc _physics_process(delta: float) -> void:\n\tglobal_position += velocity * delta\n"
	bullet_script.reload()
	bullet.set_script(bullet_script)

	bullet.set("velocity", Vector2(facing_direction * speed, 0.0))
	bullet.global_position = global_position + Vector2(facing_direction * 16, -10)

	bullet.body_entered.connect(func(body):
		if body == self:
			return
		if body.has_method("take_damage") and not body.name.begins_with("Player"):
			body.take_damage(dmg)
			bullet.queue_free()
	)

	var timer = get_tree().create_timer(4.0)
	timer.timeout.connect(func():
		if is_instance_valid(bullet):
			bullet.queue_free()
	)

	main.add_child(bullet)


func _stun_closest_enemy() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	var closest_enemy: Node2D = null
	var closest_dist := 300.0
	for child in main.get_children():
		if child.has_method("take_damage") and not child.name.begins_with("Player"):
			var dist = global_position.distance_to(child.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_enemy = child
	if closest_enemy != null and closest_enemy.has_method("stun"):
		closest_enemy.call("stun", 1.5)


func _execute_ground_pound_damage() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(96, 32)
	query.shape = rect
	query.transform = Transform2D(0, global_position + Vector2(0, 10))
	query.collision_mask = 1 # hits enemies
	
	var hits = space_state.intersect_shape(query)
	for hit in hits:
		var node = hit.get("collider")
		if node != null and node != self and node.has_method("take_damage"):
			node.take_damage(30)
			if "velocity" in node:
				node.velocity += Vector2(sign(node.global_position.x - global_position.x) * 300.0, -150.0)


func _fire_archer_arrow() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	
	if main.has_method("play_sfx"): main.play_sfx("jump")
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("🏹 ARROW!", global_position, Color.GREEN)
		
	var shoot_dir := Vector2(facing_direction, 0.0)
	var closest_enemy: Node2D = null
	var closest_dist := 300.0
	for child in main.get_children():
		if child.has_method("take_damage") and not child.name.begins_with("Player"):
			var dist = global_position.distance_to(child.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_enemy = child
	if closest_enemy != null:
		shoot_dir = (closest_enemy.global_position - global_position).normalized()
		
	var bullet := Area2D.new()
	bullet.name = "ArcherArrow"
	
	var visual := ColorRect.new()
	visual.color = Color.GREEN
	visual.size = Vector2(16, 4)
	visual.position = -visual.size * 0.5
	bullet.add_child(visual)
	
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	var col := CollisionShape2D.new()
	col.shape = shape
	bullet.add_child(col)
	
	bullet.collision_layer = 0
	bullet.collision_mask = 1 # hits enemies
	
	var bullet_script := GDScript.new()
	bullet_script.source_code = "extends Area2D\nvar velocity := Vector2.ZERO\nfunc _physics_process(delta: float) -> void:\n\tglobal_position += velocity * delta\n\trotation = velocity.angle()\n"
	bullet_script.reload()
	bullet.set_script(bullet_script)
	
	bullet.set("velocity", shoot_dir * 450.0)
	bullet.global_position = global_position + Vector2(facing_direction * 16, -10)
	
	bullet.body_entered.connect(func(body):
		if body == self: return
		if body.has_method("take_damage") and not body.name.begins_with("Player"):
			body.take_damage(12)
			bullet.queue_free()
	)
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		if is_instance_valid(bullet): bullet.queue_free()
	)
	main.add_child(bullet)


func _fire_mage_wand_bolt() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	
	if main.has_method("play_sfx"): main.play_sfx("hit")
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("🔮 WAND!", global_position, Color.PURPLE)
		
	var bullet := Area2D.new()
	bullet.name = "MageWandBolt"
	
	var visual := ColorRect.new()
	visual.color = Color(0.8, 0.4, 1.0)
	visual.size = Vector2(8, 8)
	visual.position = -visual.size * 0.5
	bullet.add_child(visual)
	
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	var col := CollisionShape2D.new()
	col.shape = shape
	bullet.add_child(col)
	
	bullet.collision_layer = 0
	bullet.collision_mask = 1
	
	var bullet_script := GDScript.new()
	bullet_script.source_code = "extends Area2D\nvar velocity := Vector2.ZERO\nfunc _physics_process(delta: float) -> void:\n\tglobal_position += velocity * delta\n"
	bullet_script.reload()
	bullet.set_script(bullet_script)
	
	bullet.set("velocity", Vector2(facing_direction * 350.0, 0.0))
	bullet.global_position = global_position + Vector2(facing_direction * 16, -10)
	
	bullet.body_entered.connect(func(body):
		if body == self: return
		if body.has_method("take_damage") and not body.name.begins_with("Player"):
			body.take_damage(8)
			bullet.queue_free()
	)
	
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		if is_instance_valid(bullet): bullet.queue_free()
	)
	main.add_child(bullet)


func _fire_mage_magic_blast() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	
	if main.has_method("play_sfx"): main.play_sfx("jump")
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("⚡ MAGIC BLAST!", global_position, Color.MAGENTA)
		
	var bullet := Area2D.new()
	bullet.name = "MageMagicBlast"
	
	var visual := ColorRect.new()
	visual.color = Color(1.0, 0.2, 0.8)
	visual.size = Vector2(20, 20)
	visual.position = -visual.size * 0.5
	bullet.add_child(visual)
	
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	var col := CollisionShape2D.new()
	col.shape = shape
	bullet.add_child(col)
	
	bullet.collision_layer = 0
	bullet.collision_mask = 1
	
	var bullet_script := GDScript.new()
	bullet_script.source_code = "extends Area2D\nvar velocity := Vector2.ZERO\nfunc _physics_process(delta: float) -> void:\n\tglobal_position += velocity * delta\n"
	bullet_script.reload()
	bullet.set_script(bullet_script)
	
	bullet.set("velocity", Vector2(facing_direction * 220.0, 0.0))
	bullet.global_position = global_position + Vector2(facing_direction * 16, -10)
	
	var hit_entities: Array = []
	bullet.body_entered.connect(func(body):
		if body == self: return
		if body.has_method("take_damage") and not body.name.begins_with("Player"):
			if not body in hit_entities:
				hit_entities.append(body)
				body.take_damage(25)
	)
	
	var timer = get_tree().create_timer(3.5)
	timer.timeout.connect(func():
		if is_instance_valid(bullet): bullet.queue_free()
	)
	main.add_child(bullet)

