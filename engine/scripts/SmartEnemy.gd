extends CharacterBody2D

const EnemyProjectileScript = preload("res://scripts/EnemyProjectile.gd")

@export var patrol_speed: float = 70.0
@export var gravity_scale: float = 1.0
@export var ledge_probe_distance: float = 28.0
@export var ledge_probe_depth: float = 48.0
@export var damage_value: int = 10
@export var boss_mode: bool = false
@export var behavior_type: String = "patrol"
@export var shoot_projectiles: bool = false
@export var projectile_speed: float = 250.0
@export var projectile_interval: float = 1.5

@export var projectile_type: String = "slime_spit"

var direction: int = -1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var floor_probe: RayCast2D
var _damage_area: Area2D = null
var _time_passed: float = 0.0
var _jump_cooldown: float = 2.0
var _shoot_timer: float = 0.0
var max_health: int = 20
var current_health: int = max_health
var stun_timer: float = 0.0
var knockback_timer: float = 0.0
var _stun_spinner: Node2D = null

# Chemistry and companion variables
var is_burning: bool = false
var burn_timer: float = 0.0
var is_frozen: bool = false
var freeze_timer: float = 0.0
var is_shocked: bool = false
var shock_timer: float = 0.0
var latched_pikmin: Array = []
var boss_hud_style: String = "retro"
var boss_phases_count: int = 2

# Sleeping state — set externally by RuntimeTutorialWhisperer after hotspot deaths
var is_sleeping: bool = false
var _sleep_zzz_particles: CPUParticles2D = null
var current_phase: int = 1
var phase_hp_thresholds: Array = []
var tail_health: int = 60
var horn_health: int = 60
var tail_broken: bool = false
var horn_broken: bool = false


func _ready() -> void:
	if has_meta("asset_id"):
		var a_id = str(get_meta("asset_id"))
		if a_id == "cactus_hazard" or a_id == "spike_hazard":
			projectile_type = "needle_shot"
		elif a_id == "boss_dragon" or a_id == "boss_demon":
			projectile_type = "fireball"
		else:
			projectile_type = "slime_spit"

	floor_probe = RayCast2D.new()
	floor_probe.enabled = true
	add_child(floor_probe)
	_update_probe()
	_shoot_timer = projectile_interval

	# Boss: scale up and move faster
	if boss_mode:
		scale = Vector2(1.8, 1.8)
		patrol_speed *= 1.5
		max_health = max(max_health, 300)
		current_health = max_health
		if boss_phases_count == 2:
			phase_hp_thresholds = [int(max_health * 0.5)]
		elif boss_phases_count == 3:
			phase_hp_thresholds = [int(max_health * 0.66), int(max_health * 0.33)]
		else:
			phase_hp_thresholds = []

	# Difficulty adjustment: easy mode makes enemies 50% slower
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.get("difficulty") == "easy":
		patrol_speed *= 0.5

	# Damage hitbox — slightly smaller than collision box so it feels fair
	_damage_area = Area2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28, 28)
	var col := CollisionShape2D.new()
	col.shape = shape
	_damage_area.add_child(col)
	_damage_area.collision_layer = 0
	_damage_area.collision_mask = 1   # layer 1 = player CharacterBody2D
	_damage_area.body_entered.connect(_on_damage_area_body_entered)
	add_child(_damage_area)


func _exit_tree() -> void:
	if _damage_area != null:
		if _damage_area.body_entered.is_connected(_on_damage_area_body_entered):
			_damage_area.body_entered.disconnect(_on_damage_area_body_entered)
		_damage_area = null
	floor_probe = null
	_stun_spinner = null
	latched_pikmin.clear()


func _on_damage_area_body_entered(body: Node) -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.get("calm_mode") == true:
		return # Enemies are friendly in Calm Mode!
	if body == self:
		return
	if main != null and main.get("active_player") != null and body != main.get("active_player"):
		return

	if body.has_method("take_damage"):
		if body is CharacterBody2D:
			var diff_y = body.global_position.y - global_position.y
			var gravity_inv = body.get("gravity_inverted") if "gravity_inverted" in body else false
			var is_on_top = diff_y < -12.0 if not gravity_inv else diff_y > 12.0
			if is_on_top and body.velocity.y * (1.0 if not gravity_inv else -1.0) >= 0.0:
				return # Player is stomping us, don't damage them
		body.take_damage(damage_value)


func _physics_process(delta: float) -> void:
	# Sleeping: the enemy dozes off — Zzz particles, 30% speed, no attacks
	if is_sleeping:
		velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
		if not is_on_floor():
			velocity.y += gravity * gravity_scale * delta
		move_and_slide()
		return

	if is_frozen:
		freeze_timer -= delta
		velocity = Vector2.ZERO
		modulate = Color.CYAN
		if freeze_timer <= 0.0:
			is_frozen = false
			modulate = Color.WHITE
		move_and_slide()
		return

	if is_shocked:
		shock_timer -= delta
		velocity = Vector2.ZERO
		modulate = Color.YELLOW if Engine.get_physics_frames() % 4 < 2 else Color.WHITE
		if shock_timer <= 0.0:
			is_shocked = false
			modulate = Color.WHITE
		move_and_slide()
		return

	if is_burning:
		burn_timer -= delta
		modulate = Color.ORANGE_RED if Engine.get_physics_frames() % 6 < 3 else Color.WHITE
		if int(burn_timer * 10) % 10 == 0:
			take_damage(2)
		if burn_timer <= 0.0:
			is_burning = false
			modulate = Color.WHITE

	if _stun_spinner != null:
		if stun_timer > 0.0:
			_stun_spinner.visible = true
			_stun_spinner.rotation += 5.0 * delta
		else:
			_stun_spinner.visible = false

	if shoot_projectiles:
		# Disable shooting when stunned
		if stun_timer <= 0.0:
			_shoot_timer -= delta
			if _shoot_timer <= 0.0:
				_shoot_projectile()
				_shoot_timer = projectile_interval

	if behavior_type != "fly":
		if not is_on_floor():
			velocity.y += gravity * gravity_scale * delta
	else:
		if stun_timer <= 0.0 and knockback_timer <= 0.0:
			_time_passed += delta
			velocity.y = cos(_time_passed * 4.0) * 80.0

	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
		if behavior_type == "fly":
			velocity.y = move_toward(velocity.y, 0.0, 500.0 * delta)
	elif stun_timer > 0.0:
		stun_timer -= delta
		velocity.x = 0.0
		if behavior_type == "fly":
			velocity.y = 0.0
	else:
		var active_speed = patrol_speed
		var main_node = get_tree().get_root().get_node_or_null("Main")
		if main_node != null and "enemy_speed_multiplier" in main_node:
			active_speed *= float(main_node.get("enemy_speed_multiplier"))
		if latched_pikmin.size() > 0:
			active_speed *= 0.5

		match behavior_type:
			"chase":
				var main = get_tree().get_root().get_node_or_null("Main")
				var player = main.active_player if main != null else null
				if player != null:
					var diff = player.global_position.x - global_position.x
					if abs(diff) < 240.0:
						direction = 1 if diff > 0 else -1
						velocity.x = float(direction) * active_speed * 1.4
					else:
						velocity.x = float(direction) * active_speed
				else:
					velocity.x = float(direction) * active_speed

			"jump":
				velocity.x = float(direction) * active_speed
				if is_on_floor():
					_jump_cooldown -= delta
					if _jump_cooldown <= 0.0:
						velocity.y = -350.0
						_jump_cooldown = randf_range(1.5, 3.0)

			"fly":
				velocity.x = float(direction) * active_speed

			_: # patrol
				velocity.x = float(direction) * active_speed

	# Apply conveyor belt movement to enemy velocity
	var conveyor_velocity := Vector2.ZERO
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.has_meta("is_conveyor") and collider.get_meta("is_conveyor") == true:
				var dir: float = collider.get_meta("conveyor_direction")
				var spd: float = collider.get_meta("conveyor_speed")
				conveyor_velocity.x = dir * spd

	velocity.x += conveyor_velocity.x

	move_and_slide()

	if stun_timer <= 0.0 and knockback_timer <= 0.0:
		if behavior_type == "fly" or behavior_type == "chase":
			if is_on_wall():
				direction *= -1
				_update_probe()
		else:
			if is_on_wall() or not _has_floor_ahead():
				direction *= -1
				_update_probe()


func _has_floor_ahead() -> bool:
	_update_probe()
	floor_probe.force_raycast_update()
	return floor_probe.is_colliding()


func _update_probe() -> void:
	if floor_probe == null:
		return
	floor_probe.position = Vector2(float(direction) * ledge_probe_distance, 0)
	floor_probe.target_position = Vector2(0, ledge_probe_depth)


func _shoot_projectile() -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var shoot_dir := Vector2(float(direction), 0)
	var player = main.active_player
	if player != null:
		var diff = player.global_position - global_position
		if diff.length() < 320.0:
			shoot_dir = diff.normalized()

	var bullet := Area2D.new()
	bullet.name = "EnemyProjectile"

	var visual := ColorRect.new()
	visual.color = Color(1.0, 0.35, 0.15, 1.0)
	visual.size = Vector2(10, 10)
	visual.position = -visual.size * 0.5
	bullet.add_child(visual)

	var shape := CircleShape2D.new()
	shape.radius = 6.0
	var col := CollisionShape2D.new()
	col.shape = shape
	bullet.add_child(col)

	bullet.collision_layer = 0
	bullet.collision_mask = 1 # player

	bullet.set_script(EnemyProjectileScript)

	bullet.set("velocity", shoot_dir * projectile_speed)
	bullet.set("damage_value", damage_value)
	bullet.global_position = global_position

	main.add_child(bullet)



func take_damage(amount: int, element: String = "") -> void:
	var final_amount := amount
	var weakness = str(get_meta("weakness_element")).to_lower() if has_meta("weakness_element") else ""
	
	var is_weak_hit := false
	if weakness != "":
		if element.to_lower() == weakness:
			is_weak_hit = true
		elif weakness == "fire" and is_burning:
			is_weak_hit = true
		elif weakness == "ice" and is_frozen:
			is_weak_hit = true
		elif weakness == "water" and water_type != "normal" and inside_water:
			is_weak_hit = true
			
	if is_weak_hit:
		final_amount *= 3
		var main = get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("🎯 WEAKNESS HIT! 3x DAMAGE! 🎯", global_position, Color.GOLD)

	# Boss Part Breaking logic
	if boss_mode:
		if not tail_broken:
			tail_health -= final_amount
			if tail_health <= 0:
				tail_broken = true
				patrol_speed *= 0.6 # Slow down boss because tail is broken!
				var main = get_tree().get_root().get_node_or_null("Main")
				if main != null and main.has_method("spawn_floating_text"):
					main.spawn_floating_text("💥 BOSS TAIL BROKEN (Speed Reduced!)", global_position + Vector2(0, -60), Color.ORANGE)
				if main != null and main.has_method("play_sfx"):
					main.play_sfx("hit")
		elif not horn_broken:
			horn_health -= final_amount
			if horn_health <= 0:
				horn_broken = true
				shoot_projectiles = false # Stop shooting because horn is broken!
				var main = get_tree().get_root().get_node_or_null("Main")
				if main != null and main.has_method("spawn_floating_text"):
					main.spawn_floating_text("💥 BOSS HORN BROKEN (Projectiles Disabled!)", global_position + Vector2(0, -60), Color.RED)
				if main != null and main.has_method("play_sfx"):
					main.play_sfx("hit")

	current_health -= final_amount
	knockback_timer = 0.25

	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null:
		if main.has_method("spawn_floating_text"):
			main.spawn_floating_text(str(-amount), global_position, Color.RED)
		if main.has_method("play_custom_sfx"):
			main.play_custom_sfx(str(get_meta("asset_id")) if has_meta("asset_id") else "slime_patrol", "hit")
		elif main.has_method("play_sfx"):
			main.play_sfx("hurt")
		if main.has_method("trigger_screen_shake"):
			main.trigger_screen_shake(4.0 if not boss_mode else 10.0, 0.15 if not boss_mode else 0.3)
		if main.has_method("trigger_hit_stop"):
			main.trigger_hit_stop(0.08 if not boss_mode else 0.2)

	# Wobble Scale Animation using Tween
	var base_scale = scale
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(base_scale.x * 1.4, base_scale.y * 0.6), 0.08)
	tween.tween_property(self, "scale", Vector2(base_scale.x * 0.8, base_scale.y * 1.3), 0.08)
	tween.tween_property(self, "scale", base_scale, 0.1)

	if boss_mode and current_health > 0:
		var next_phase := 1
		if boss_phases_count == 2:
			if current_health <= phase_hp_thresholds[0]:
				next_phase = 2
		elif boss_phases_count == 3:
			if current_health <= phase_hp_thresholds[1]:
				next_phase = 3
			elif current_health <= phase_hp_thresholds[0]:
				next_phase = 2

		if next_phase > current_phase:
			current_phase = next_phase
			_trigger_phase_transition()

	if current_health <= 0:
		current_health = 0
		die()


func _trigger_phase_transition() -> void:
	stun_timer = max(stun_timer, 1.2) # Invulnerability stun
	knockback_timer = 0.25

	var text := "🔥 PHASE 2!"
	if current_phase == 3:
		text = "⚡ FINAL ENRAGED PHASE! ⚡"

	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null:
		if main.has_method("play_sfx"): main.play_sfx("coin")
		if main.has_method("spawn_floating_text"):
			main.spawn_floating_text(text, global_position + Vector2(0, -40), Color.RED if current_phase == 3 else Color.ORANGE)

	# Wobble Scale Animation using Tween
	var base_scale = scale
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(base_scale.x * 1.6, base_scale.y * 0.5), 0.1)
	tween.tween_property(self, "scale", Vector2(base_scale.x * 0.5, base_scale.y * 1.6), 0.1)
	tween.tween_property(self, "scale", base_scale, 0.1)

	# Phase Stats boost:
	if current_phase == 2:
		patrol_speed *= 1.3
		projectile_interval *= 0.8
		modulate = Color(1.0, 0.6, 0.3) # orange aura
	elif current_phase == 3:
		patrol_speed *= 1.6
		projectile_interval *= 0.5
		modulate = Color(1.0, 0.3, 0.3) # red aura

		# Spawn Rage steam particles
		var p := CPUParticles2D.new()
		p.name = "RageParticles"
		p.amount = 15
		p.lifetime = 0.6
		p.direction = Vector2.UP
		p.gravity = Vector2(0, -150)
		p.initial_velocity_min = 40.0
		p.initial_velocity_max = 80.0
		p.color = Color(1.0, 0.2, 0.2, 0.8)
		p.emitting = true
		p.position = Vector2(0, 0)
		add_child(p)


func stun(duration: float) -> void:
	stun_timer = max(stun_timer, duration)
	knockback_timer = 0.25 # Stun also stops normal movement

	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("💫 STUNNED!", global_position + Vector2(0, -30), Color.YELLOW)

	if _stun_spinner == null:
		_stun_spinner = Node2D.new()
		_stun_spinner.name = "StunSpinner"
		add_child(_stun_spinner)

		for i in range(3):
			var star = Label.new()
			star.text = "⭐"
			star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			var settings = LabelSettings.new()
			settings.font_size = 16
			star.label_settings = settings
			var angle = i * (2.0 * PI / 3.0)
			star.position = Vector2(cos(angle), sin(angle)) * 20.0 - Vector2(10, 10)
			_stun_spinner.add_child(star)

		_stun_spinner.position = Vector2(0, -40)
	else:
		_stun_spinner.visible = true


func die() -> void:
	for p in latched_pikmin:
		if is_instance_valid(p) and p.has_method("unlatch"):
			p.unlatch()
	latched_pikmin.clear()

	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("DEFEATED! 🏆", global_position, Color.GOLD)

	# Spawn a smoke puff particles block programmatically
	if main != null:
		var smoke_data = {
			"asset_id": "effects_smoke",
			"category": "particles",
			"position": {"x": global_position.x, "y": global_position.y},
			"modifiers": {"particle_theme": "default", "particle_intensity": "normal"}
		}
		var p_node = main.spawn_entity(smoke_data)
		if p_node != null:
			var timer = get_tree().create_timer(1.2)
			timer.timeout.connect(func():
				if is_instance_valid(p_node):
					p_node.queue_free()
			)

	if main != null and main.has_method("check_victory_conditions"):
		main.call_deferred("check_victory_conditions")

	# Visual progression: advance player's tier when an enemy is defeated
	if main != null and main.has_method("notify_enemy_defeated"):
		main.call_deferred("notify_enemy_defeated")

	# Transition to remains state
	name = "Remains_" + name
	set_meta("is_defeated_remains", true)
	set_meta("projectile_type", projectile_type)

	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	set_process(false)

	if main != null:
		var prompt := Label.new()
		prompt.text = "🧬 COPY"
		prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var p_settings := LabelSettings.new()
		p_settings.font_size = 11
		p_settings.font_color = Color.DEEP_SKY_BLUE
		p_settings.outline_size = 2
		p_settings.outline_color = Color.BLACK
		prompt.label_settings = p_settings
		prompt.size = Vector2(50, 15)
		prompt.position = Vector2(-25, -45)
		add_child(prompt)

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "modulate:a", 0.1, 1.5)
		tween.tween_property(prompt, "position:y", -60.0, 1.5)
		tween.chain().tween_callback(queue_free)
	else:
		get_tree().create_timer(1.5).timeout.connect(queue_free)


func register_pikmin_latch(pikmin: Node2D) -> void:
	if not pikmin in latched_pikmin:
		latched_pikmin.append(pikmin)


func unregister_pikmin_latch(pikmin: Node2D) -> void:
	latched_pikmin.erase(pikmin)


func set_frozen(duration: float) -> void:
	is_frozen = true
	freeze_timer = max(freeze_timer, duration)


func set_burning(duration: float) -> void:
	is_burning = true
	burn_timer = max(burn_timer, duration)


func set_shocked(duration: float) -> void:
	is_shocked = true
	shock_timer = max(shock_timer, duration)


## put_to_sleep — called by Main after detecting 3+ deaths near this enemy.
## The enemy stays on-screen but stops attacking and slows dramatically.
func put_to_sleep() -> void:
	if is_sleeping:
		return
	is_sleeping = true
	patrol_speed *= 0.3
	shoot_projectiles = false
	modulate = Color(0.7, 0.75, 1.0, 0.6)  # pale bluish tint

	# Disable damage hitbox
	if _damage_area != null and is_instance_valid(_damage_area):
		_damage_area.monitoring = false

	# Spawn Zzz particles above the enemy
	_sleep_zzz_particles = CPUParticles2D.new()
	_sleep_zzz_particles.name = "ZzzParticles"
	_sleep_zzz_particles.amount = 4
	_sleep_zzz_particles.lifetime = 1.8
	_sleep_zzz_particles.direction = Vector2(0.3, -1.0)
	_sleep_zzz_particles.gravity = Vector2(0, -40)
	_sleep_zzz_particles.initial_velocity_min = 20.0
	_sleep_zzz_particles.initial_velocity_max = 40.0
	_sleep_zzz_particles.color = Color(0.7, 0.85, 1.0, 0.8)
	_sleep_zzz_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_sleep_zzz_particles.emission_sphere_radius = 6.0
	_sleep_zzz_particles.position = Vector2(0, -40)
	add_child(_sleep_zzz_particles)

	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("💤 ZZZ...", global_position + Vector2(0, -50), Color(0.7, 0.85, 1.0))
