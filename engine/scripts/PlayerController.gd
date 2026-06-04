extends CharacterBody2D

const PlayerVisualEffects = preload("res://scripts/PlayerVisualEffects.gd")
const PlayerProjectileFactory = preload("res://scripts/PlayerProjectileFactory.gd")
const PlayerClearPipe = preload("res://scripts/PlayerClearPipe.gd")
const PlayerInventory = preload("res://scripts/PlayerInventory.gd")
const PlayerPowerups = preload("res://scripts/PlayerPowerups.gd")
const PlayerDamage = preload("res://scripts/PlayerDamage.gd")
const PlayerStatusEffects = preload("res://scripts/PlayerStatusEffects.gd")
const PlayerInputActions = preload("res://scripts/PlayerInputActions.gd")
const PlayerLedgeGrab = preload("res://scripts/PlayerLedgeGrab.gd")
const PlayerRopeClimb = preload("res://scripts/PlayerRopeClimb.gd")
const PlayerGrapplingHook = preload("res://scripts/PlayerGrapplingHook.gd")
const PlayerSpecialMoves = preload("res://scripts/PlayerSpecialMoves.gd")
const PlayerCrouchSlide = preload("res://scripts/PlayerCrouchSlide.gd")
const PlayerWallCeilingRun = preload("res://scripts/PlayerWallCeilingRun.gd")
const PlayerCombat = preload("res://scripts/PlayerCombat.gd")

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
var physics_preset: String = "kidfriendly"
var max_mana: float = 100.0
var mana_points: float = 100.0
var dashes_spent: int = 0
var archer_shoot_cooldown: float = 0.0

# Subsystems inventory
var metal_scrap: int = 0
var fire_powder: int = 0
var green_herb: int = 0
var sweet_honey: int = 0

# Chemistry states
var is_burning: bool = false
var burn_timer: float = 0.0
var is_shocked: bool = false
var shock_timer: float = 0.0

# Backpack UI state
var backpack_open: bool = false
var backpack_grid: Array = [
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null]
]

# Powerup states
var speed_boost_timer: float = 0.0
var shield_active: bool = false
var double_jump_enabled: bool = false
var charge_jump_enabled: bool = false
var is_charge_jump_charging: bool = false
var charge_jump_timer: float = 0.0
var charge_jump_time_per_level: float = 0.8
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

# Phase 2 Traversal & Combat Subsystems
var coyote_time_duration: float = 0.15
var coyote_timer: float = 0.0
var jump_buffer_duration: float = 0.15
var jump_buffer_timer: float = 0.0

# Ledge hanging
var is_ledge_hanging: bool = false
var ledge_pos: Vector2 = Vector2.ZERO

# Rope/Vine swinging
var is_rope_climbing: bool = false
var current_rope: Node2D = null
var swing_angle: float = 0.0
var swing_speed: float = 0.0
var rope_length: float = 120.0

# Grappling Hook
var is_grappling: bool = false
var grapple_target_pos: Vector2 = Vector2.ZERO
var current_grapple_range: float = 180.0

# Spin Dash
var is_spindashing: bool = false
var spindash_charge: float = 0.0
var is_spindash_rolling: bool = false
var spindash_roll_timer: float = 0.0

# Speed Booster & Shinespark
var run_timer: float = 0.0
var speed_booster_active: bool = false
var shinespark_stored: bool = false
var shinespark_store_timer: float = 0.0
var is_shinesparking: bool = false
var shinespark_direction: Vector2 = Vector2.UP
var shinespark_flight_timer: float = 0.0

# Wall & Ceiling Run
var is_wall_running: bool = false
var is_ceiling_running: bool = false
var magnet_meter: float = 3.0
var wall_run_dir: float = 1.0

# Crouching/Sliding
var is_crouching: bool = false
var is_sliding: bool = false
var slide_boost_timer: float = 0.0
var original_collision_height: float = 48.0
var original_collision_y: float = 0.0
var collision_shape: CollisionShape2D = null

# Weapons & Focus
var has_boomerang: bool = false
var has_bomb: bool = false
var has_focus_amulet: bool = false
var focus_active: bool = false
var focus_timer: float = 0.0
var current_time_slow_factor: float = 0.2

# Clear Pipes
var is_in_clear_pipe: bool = false
var pipe_current_block: Node2D = null
var pipe_previous_block: Node2D = null
var pipe_direction: Vector2 = Vector2.ZERO

# Paint Gun & Squid Form
var has_paint_gun: bool = false
var is_squid_form: bool = false

# Phase 4 Economy, Companions & Star Mode
var star_pieces: int = 0
var is_star_mode: bool = false
var star_timer: float = 0.0
var copied_enemy_projectile: String = ""
var weapon_level: int = 1



func _ready() -> void:
	_apply_physics_preset()

	if hero_class == "warrior":
		max_health += 30
	elif hero_class == "rogue":
		movement_speed *= 1.25

	current_health = max_health
	_ready_trail_particles()

	# Initialize collision shape reference and dimensions
	for child in get_children():
		if child is CollisionShape2D:
			collision_shape = child
			break
	if collision_shape != null and collision_shape.shape is RectangleShape2D:
		original_collision_height = collision_shape.shape.size.y
		original_collision_y = collision_shape.position.y


func _apply_physics_preset() -> void:
	match physics_preset:
		"mario":
			movement_speed = 180.0
			jump_force = -520.0
			gravity_scale = 1.3
			coyote_time_duration = 0.08
			jump_buffer_duration = 0.12
		"sonic":
			movement_speed = 360.0
			jump_force = -440.0
			gravity_scale = 0.95
			coyote_time_duration = 0.05
			jump_buffer_duration = 0.08
		"hollow":
			movement_speed = 240.0
			jump_force = -450.0
			gravity_scale = 1.55
			coyote_time_duration = 0.05
			jump_buffer_duration = 0.05
		"kirby":
			movement_speed = 140.0
			jump_force = -380.0
			gravity_scale = 0.65
			coyote_time_duration = 0.20
			jump_buffer_duration = 0.20
		_: # "kidfriendly"
			movement_speed = 220.0
			jump_force = -460.0
			gravity_scale = 1.0
			coyote_time_duration = 0.15
			jump_buffer_duration = 0.15



func _ready_trail_particles() -> void:
	trail_particles = PlayerVisualEffects.create_hero_trail(self)


func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Player healed by %d HP. HP now: %d/%d" % [amount, current_health, max_health])
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("+%d HP" % amount, global_position, Color.GREEN)


func apply_powerup(type: String) -> void:
	PlayerPowerups.apply(self, type)


func take_damage(amount: int) -> void:
	PlayerDamage.apply_damage(self, amount)


func _physics_process(delta: float) -> void:
	# ─── BLUE MAGE remains check ───
	if hero_class == "mage" and get_parent() != null:
		var main_ref = get_parent()
		for child in main_ref.get_children():
			if child.name.begins_with("Remains_") or (child.has_meta("is_defeated_remains") and child.get_meta("is_defeated_remains")):
				if global_position.distance_to(child.global_position) < 40.0:
					var p_type = str(child.get_meta("projectile_type"))
					if p_type != "" and copied_enemy_projectile != p_type:
						copied_enemy_projectile = p_type
						if main_ref.has_method("spawn_floating_text"):
							main_ref.spawn_floating_text("🧬 COPY: " + p_type.to_upper() + "! 🧬", global_position, Color.DEEP_SKY_BLUE)
						if main_ref.has_method("play_sfx"):
							main_ref.play_sfx("coin")
					child.queue_free()

	# ─── CLEAR PIPE TRAVEL OVERRIDE ───
	if PlayerClearPipe.process_travel(self):
		return

	# ─── SQUID WALL SWIM OVERRIDE ───
	if is_squid_form and is_on_wall():
		var touching_painted_wall := false
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			var collider = col.get_collider()
			if collider != null and collider.has_meta("paint_color") and collider.get_meta("paint_color") == "green":
				touching_painted_wall = true
				break
		if touching_painted_wall:
			var v_in := Input.get_axis("ui_up", "ui_down")
			if v_in == 0.0 and Input.is_physical_key_pressed(KEY_W):
				v_in = -1.0
			elif v_in == 0.0 and Input.is_physical_key_pressed(KEY_S):
				v_in = 1.0
			velocity.y = v_in * movement_speed * 1.5
			velocity.x = 0.0
			move_and_slide()
			return

	if PlayerStatusEffects.update_status_effects(self, delta):
		return

	if hero_class == "mage":
		mana_points = min(mana_points + 10.0 * delta, max_mana)
	if archer_shoot_cooldown > 0.0:
		archer_shoot_cooldown -= delta

	var is_creative := false
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.get("difficulty") == "creative":
		is_creative = true

	# Focus Amulet / Time Slow tick
	if has_focus_amulet and focus_active:
		focus_timer -= delta / Engine.time_scale
		if focus_timer <= 0.0:
			focus_active = false
			Engine.time_scale = 1.0
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("TIME NORMAL", global_position, Color.CYAN)

	# Traversal and Special Moves Overrides
	if PlayerSpecialMoves.process_shinespark(self, delta):
		return
	if PlayerGrapplingHook.process_grapple(self, delta):
		return
	if PlayerRopeClimb.process_climb(self, delta):
		return
	if PlayerLedgeGrab.process_ledge_grab(self, delta):
		return
	if PlayerSpecialMoves.process_spindash(self, delta):
		return
	if PlayerSpecialMoves.process_spindash_roll(self, delta):
		return

	# Wall / Ceiling Run mechanics
	var input_dir := Input.get_axis("ui_left", "ui_right")
	if PlayerWallCeilingRun.process_wall_run(self, delta, input_dir):
		return
	if PlayerWallCeilingRun.process_ceiling_run(self, delta, input_dir):
		return

	# Ledge Grab check
	PlayerLedgeGrab.check_ledge_grab(self)

	# Rope swing / climb detection trigger
	PlayerRopeClimb.check_climb_trigger(self)

	# Clear Pipe Entrance Check
	if PlayerClearPipe.try_enter(self):
		return

	# Grapple ring target check E key
	PlayerGrapplingHook.check_grapple_trigger(self)

	# Coyote Time & Jump Buffer ticks
	if is_on_floor() or inside_water:
		coyote_timer = coyote_time_duration
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		jump_buffer_timer = jump_buffer_duration
	else:
		jump_buffer_timer -= delta

	var charge_jump_held := Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")
	var charge_jump_pressed := Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")
	var charge_jump_down_held := Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)
	if charge_jump_enabled and is_on_floor() and charge_jump_pressed and not charge_jump_down_held and not is_charge_jump_charging:
		is_charge_jump_charging = true
		charge_jump_timer = 0.0
		jump_buffer_timer = 0.0
		velocity = Vector2.ZERO
		queue_redraw()
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("HOLD...", global_position, Color.GOLD)
		move_and_slide()
		return

	if is_charge_jump_charging:
		if not is_on_floor() or charge_jump_down_held:
			is_charge_jump_charging = false
			charge_jump_timer = 0.0
			scale = Vector2.ONE
			queue_redraw()
		elif charge_jump_held:
			charge_jump_timer = min(charge_jump_timer + delta, charge_jump_time_per_level * 3.0)
			var charge_ratio = clamp(charge_jump_timer / max(charge_jump_time_per_level * 3.0, 0.1), 0.0, 1.0)
			velocity.x = input_dir * movement_speed * 0.25
			velocity.y = 0.0
			scale = Vector2(1.0 + charge_ratio * 0.18, 1.0 - charge_ratio * 0.25)
			modulate = Color(1.0, 0.9 + charge_ratio * 0.1, 0.45 + charge_ratio * 0.35)
			queue_redraw()
			move_and_slide()
			return
		else:
			var level: int = clamp(int(ceil(charge_jump_timer / max(charge_jump_time_per_level, 0.1))), 1, 3)
			var jump_multiplier: float = 1.0
			match level:
				2:
					jump_multiplier = 1.45
				3:
					jump_multiplier = 1.9
				_:
					jump_multiplier = 1.0
			is_charge_jump_charging = false
			charge_jump_timer = 0.0
			scale = Vector2.ONE
			velocity.y = jump_force * jump_multiplier if not gravity_inverted else -jump_force * jump_multiplier
			velocity.x += input_dir * movement_speed * 0.35
			_jumps_remaining = 1 if double_jump_enabled else 0
			coyote_timer = 0.0
			jump_buffer_timer = 0.0
			if main != null and main.has_method("play_custom_sfx"):
				main.play_custom_sfx(asset_id, "jump")
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("SPRING x%d!" % level, global_position, Color.GOLD)
			queue_redraw()
			move_and_slide()
			return

	# Crouching, Sliding & Squid Form Logic
	PlayerCrouchSlide.update_crouch_slide(self, delta)
	var down_input_pressed := Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)

	# Speed Booster & Shinespark mechanics
	PlayerSpecialMoves.update_speed_booster(self, input_dir, down_input_pressed, delta)

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
			water_hurt_timer = 0.8

	# Handle giant timer
	if giant_timer > 0.0:
		giant_timer -= delta
		is_giant = true
		scale = Vector2(2.0, 2.0)
	elif is_giant:
		is_giant = false
		scale = Vector2(1.0, 1.0)

	# Determine final active speed
	var active_speed := movement_speed
	if is_star_mode:
		active_speed = movement_speed * 1.6
	elif is_squid_form:
		active_speed = movement_speed * 1.8
	elif is_sliding:
		active_speed = movement_speed * 1.5
	elif is_crouching:
		active_speed = movement_speed * 0.5
	elif speed_booster_active:
		active_speed = movement_speed * 1.8

	if is_star_mode:
		star_timer -= delta
		queue_redraw()
		var frame = Engine.get_physics_frames() % 9
		if frame < 3: modulate = Color(1.3, 1.3, 0.5)
		elif frame < 6: modulate = Color(0.5, 1.3, 1.3)
		else: modulate = Color(1.3, 0.5, 1.3)

		if Engine.get_physics_frames() % 4 == 0:
			var star_fx_main = get_parent()
			if star_fx_main != null:
				var p = CPUParticles2D.new()
				p.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
				p.amount = 4
				p.one_shot = true
				p.lifetime = 0.3
				p.initial_velocity_min = 20.0
				p.initial_velocity_max = 50.0
				p.spread = 180.0
				p.color = Color.GOLD
				p.scale_amount_min = 2.0
				p.scale_amount_max = 4.0
				star_fx_main.add_child(p)
				p.emitting = true
				get_tree().create_timer(0.4).timeout.connect(p.queue_free)

		if star_timer <= 0.0:
			is_star_mode = false
			modulate = Color.WHITE
			var star_expire_main = get_parent()
			if star_expire_main != null and star_expire_main.has_method("spawn_floating_text"):
				star_expire_main.spawn_floating_text("Star Mode Expired! 🌟", global_position, Color.WHITE)
	elif is_creative:
		modulate = Color(1.0, 0.9, 0.4)
	elif shinespark_stored:
		modulate = Color.YELLOW if Engine.get_physics_frames() % 4 < 2 else Color.ORANGE
	elif speed_booster_active:
		modulate = Color.CYAN if Engine.get_physics_frames() % 6 < 3 else Color.YELLOW
	elif speed_boost_timer > 0.0:
		speed_boost_timer -= delta
		active_speed = movement_speed * 1.6
		modulate = Color(0.4, 1.0, 1.0)
	elif shield_active:
		modulate = Color(1.0, 0.5, 1.0)
	elif is_giant:
		modulate = Color(1.0, 0.8, 0.2)
	elif gravity_inverted:
		modulate = Color(0.6, 0.4, 1.0)
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

	if input_dir != 0.0:
		facing_direction = sign(input_dir)

	# Spin Dash charge trigger (holding Down and pressing Jump on floor)
	if is_on_floor() and down_input_pressed and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")):
		is_spindashing = true
		spindash_charge = 0.0
		velocity = Vector2.ZERO
		return

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
	var standing_on_ice := false
	if is_on_floor():
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			var collider = col.get_collider()
			if collider != null and (collider.get_meta("is_ice", false) or collider.name.to_lower().contains("ice")):
				standing_on_ice = true
				break

	if is_dashing:
		velocity.x = dash_direction * movement_speed * 3.2
		velocity.y = 0.0
	elif is_blocking:
		if standing_on_ice:
			velocity.x = lerp(velocity.x, input_dir * active_speed, delta * 2.0)
		else:
			velocity.x = input_dir * active_speed
	elif is_ground_pounding:
		velocity.x = 0.0
	else:
		if standing_on_ice:
			velocity.x = lerp(velocity.x, input_dir * active_speed + conveyor_velocity.x, delta * 2.0)
		else:
			velocity.x = input_dir * active_speed + conveyor_velocity.x

	# Apply speed boost pad impulse vector if active
	if speed_pad_velocity.length_squared() > 10.0:
		velocity += speed_pad_velocity
		speed_pad_velocity = speed_pad_velocity.move_toward(Vector2.ZERO, delta * 900.0)

	# Water buoyancy, jetpack thrust, glider cape glide, or standard gravity
	if not is_dashing and not is_ground_pounding:
		if is_creative or is_star_mode:
			var v_input := Input.get_axis("ui_up", "ui_down")
			if v_input == 0.0 and Input.is_physical_key_pressed(KEY_W):
				v_input = -1.0
			elif v_input == 0.0 and Input.is_physical_key_pressed(KEY_S):
				v_input = 1.0
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

	if not is_creative and jump_buffer_timer > 0.0:
		var did_jump := false
		if inside_water:
			# Swim stroke
			velocity.y = -220.0 if not gravity_inverted else 220.0
			did_jump = true
			jump_buffer_timer = 0.0
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("jump")
		elif is_on_floor() or coyote_timer > 0.0:
			velocity.y = jump_force if not gravity_inverted else -jump_force
			_jumps_remaining = 1 if double_jump_enabled else 0
			did_jump = true
			coyote_timer = 0.0
			jump_buffer_timer = 0.0
		elif is_on_wall():
			# WALL JUMP!
			var wall_normal := get_wall_normal()
			velocity.y = jump_force * 0.95
			velocity.x = wall_normal.x * movement_speed * 1.3
			_jumps_remaining = 1 if double_jump_enabled else 0
			did_jump = true
			jump_buffer_timer = 0.0
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("🧗 WALL JUMP!", global_position, Color.CHARTREUSE)
		elif _jumps_remaining > 0:
			velocity.y = jump_force * 0.9 if not gravity_inverted else -jump_force * 0.9
			_jumps_remaining -= 1
			did_jump = true
			jump_buffer_timer = 0.0
			if hero_class == "archer":
				dash_cooldown = 0.0
			scale = Vector2(0.8, 1.3)
			var t := create_tween()
			t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

		if did_jump:
			if main != null and main.has_method("play_custom_sfx"):
				main.play_custom_sfx(asset_id, "jump")

	# Variable jump cancel (jump cut on release)
	if not is_on_floor() and ((velocity.y < 0.0 and not gravity_inverted) or (velocity.y > 0.0 and gravity_inverted)):
		var jump_released := Input.is_action_just_released("ui_accept") or Input.is_action_just_released("ui_up")
		if jump_released:
			if physics_preset == "hollow":
				velocity.y = 0.0
			else:
				velocity.y *= 0.5

	# Auto-Edge Jump (Calm/Mellow mode only)
	var is_mellow_or_calm := false
	if main != null:
		var diff = main.get("difficulty")
		var calm = main.get("calm_mode")
		if diff == "calm" or calm == true:
			is_mellow_or_calm = true

	if is_mellow_or_calm and is_on_floor() and input_dir != 0.0 and abs(velocity.x) > 10.0:
		var ahead_offset = 12.0 * sign(velocity.x)
		var ahead_transform = global_transform.translated(Vector2(ahead_offset, 0))
		if not test_move(ahead_transform, Vector2(0, 20.0)):
			velocity.y = jump_force * 0.65 if not gravity_inverted else -jump_force * 0.65
			coyote_timer = 0.0
			jump_buffer_timer = 0.0
			if main != null and main.has_method("play_sfx"):
				main.play_sfx("jump")
			if main != null and main.has_method("spawn_floating_text"):
				main.spawn_floating_text("🎈 UP!", global_position, Color.SKY_BLUE)

	# Ceiling Corner Correction
	if (velocity.y < 0.0 and not gravity_inverted) or (velocity.y > 0.0 and gravity_inverted):
		var up_motion = Vector2(0, velocity.y * delta)
		if test_move(global_transform, up_motion):
			var max_nudge := 8.0
			var cleared := false
			for nudge in range(1, int(max_nudge) + 1):
				var test_transform = global_transform.translated(Vector2(-nudge, 0))
				if not test_move(test_transform, up_motion):
					global_position.x -= nudge
					cleared = true
					break
			if not cleared:
				for nudge in range(1, int(max_nudge) + 1):
					var test_transform = global_transform.translated(Vector2(nudge, 0))
					if not test_move(test_transform, up_motion):
						global_position.x += nudge
						cleared = true
						break

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
		PlayerVisualEffects.update_hero_trail(trail_particles, velocity, modulate)


func _unhandled_input(event: InputEvent) -> void:
	PlayerInputActions.handle(self, event)


func show_emote(emoji: String) -> void:
	PlayerVisualEffects.show_emote(self, emoji)


func _execute_melee_strike(step: int) -> void:
	PlayerCombat.execute_melee_strike(self, step)


func _configure_linear_projectile(
	projectile: Area2D,
	projectile_velocity: Vector2,
	projectile_damage: int,
	projectile_lifetime: float,
	rotate_to_velocity: bool = false,
	pierce: bool = false,
	gravity_y: float = 0.0,
	applies_burn: bool = false
) -> void:
	PlayerProjectileFactory._configure_linear_projectile(
		projectile,
		self,
		projectile_velocity,
		projectile_damage,
		projectile_lifetime,
		rotate_to_velocity,
		pierce,
		gravity_y,
		applies_burn
	)


func _fire_projectile(charge: float) -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return
	PlayerProjectileFactory.fire_projectile(self, main, charge)


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
	PlayerCombat.execute_ground_pound_damage(self)


func _fire_archer_arrow() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	PlayerProjectileFactory.fire_archer_arrow(self, main)


func _fire_mage_wand_bolt() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	PlayerProjectileFactory.fire_mage_wand_bolt(self, main, copied_enemy_projectile)


func _fire_copied_projectile() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	PlayerProjectileFactory.fire_copied_projectile(self, main, copied_enemy_projectile)


func _fire_mage_magic_blast() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	PlayerProjectileFactory.fire_mage_magic_blast(self, main)


func set_burning(duration: float) -> void:
	PlayerStatusEffects.set_burning(self, duration)


func set_shocked(duration: float) -> void:
	PlayerStatusEffects.set_shocked(self, duration)


func add_to_backpack(item_type: String) -> bool:
	return PlayerInventory.add_to_backpack_grid(backpack_grid, item_type)


func set_crouch_state(crouch: bool) -> bool:
	return PlayerCrouchSlide.set_crouch_state(self, crouch)


func _draw() -> void:
	PlayerVisualEffects.draw_player_overlays(self)


func _throw_boomerang() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	PlayerProjectileFactory.throw_boomerang(self, main)


func _throw_bomb() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	PlayerProjectileFactory.throw_bomb(self, main)


func _fire_paint_projectile() -> void:
	var main = get_parent()
	if main == null: return
	PlayerProjectileFactory.fire_paint_projectile(self, main)


func activate_star_mode() -> void:
	is_star_mode = true
	star_timer = 15.0
	var main = get_parent()
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("coin")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("🌟 STAR MODE INVINCIBILITY! 🌟", global_position, Color.GOLD)
