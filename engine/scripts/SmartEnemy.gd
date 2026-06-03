extends CharacterBody2D

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

var direction: int = -1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var floor_probe: RayCast2D
var _damage_area: Area2D = null
var _time_passed: float = 0.0
var _jump_cooldown: float = 2.0
var _shoot_timer: float = 0.0
var max_health: int = 20
var current_health: int = max_health


func _ready() -> void:
	floor_probe = RayCast2D.new()
	floor_probe.enabled = true
	add_child(floor_probe)
	_update_probe()
	_shoot_timer = projectile_interval

	# Boss: scale up and move faster
	if boss_mode:
		scale = Vector2(1.8, 1.8)
		patrol_speed *= 1.5

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


func _on_damage_area_body_entered(body: Node) -> void:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.get("calm_mode") == true:
		return # Enemies are friendly in Calm Mode!

	if body.has_method("take_damage"):
		if body is CharacterBody2D:
			var diff_y = body.global_position.y - global_position.y
			var gravity_inv = body.get("gravity_inverted") if "gravity_inverted" in body else false
			var is_on_top = diff_y < -12.0 if not gravity_inv else diff_y > 12.0
			if is_on_top and body.velocity.y * (1.0 if not gravity_inv else -1.0) >= 0.0:
				return # Player is stomping us, don't damage them
		body.take_damage(damage_value)


func _physics_process(delta: float) -> void:
	if shoot_projectiles:
		_shoot_timer -= delta
		if _shoot_timer <= 0.0:
			_shoot_projectile()
			_shoot_timer = projectile_interval

	if behavior_type != "fly":
		if not is_on_floor():
			velocity.y += gravity * gravity_scale * delta
	else:
		_time_passed += delta
		velocity.y = cos(_time_passed * 4.0) * 80.0

	match behavior_type:
		"chase":
			var main = get_tree().get_root().get_node_or_null("Main")
			var player = main.active_player if main != null else null
			if player != null:
				var diff = player.global_position.x - global_position.x
				if abs(diff) < 240.0:
					direction = 1 if diff > 0 else -1
					velocity.x = float(direction) * patrol_speed * 1.4
				else:
					velocity.x = float(direction) * patrol_speed
			else:
				velocity.x = float(direction) * patrol_speed

		"jump":
			velocity.x = float(direction) * patrol_speed
			if is_on_floor():
				_jump_cooldown -= delta
				if _jump_cooldown <= 0.0:
					velocity.y = -350.0
					_jump_cooldown = randf_range(1.5, 3.0)

		"fly":
			velocity.x = float(direction) * patrol_speed

		_: # patrol
			velocity.x = float(direction) * patrol_speed

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

	var bullet_script := GDScript.new()
	bullet_script.source_code = "extends Area2D\nvar velocity := Vector2.ZERO\nfunc _physics_process(delta: float) -> void:\n\tglobal_position += velocity * delta\n"
	bullet_script.reload()
	bullet.set_script(bullet_script)

	bullet.set("velocity", shoot_dir * projectile_speed)
	bullet.global_position = global_position

	bullet.body_entered.connect(func(body):
		var main_ref = get_tree().get_root().get_node_or_null("Main")
		if main_ref != null and main_ref.get("calm_mode") == true:
			bullet.queue_free()
			return
		if body.has_method("take_damage"):
			body.take_damage(damage_value)
		bullet.queue_free()
	)

	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		if is_instance_valid(bullet):
			bullet.queue_free()
	)

	main.add_child(bullet)
	


func take_damage(amount: int) -> void:
	current_health -= amount
	
	var main = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text(str(-amount), global_position, Color.RED)
	if main != null and main.has_method("play_custom_sfx"):
		main.play_custom_sfx(str(get_meta("asset_id")) if has_meta("asset_id") else "slime_patrol", "hit")
	elif main != null and main.has_method("play_sfx"):
		main.play_sfx("hurt")

	# Wobble Scale Animation using Tween
	var base_scale = scale
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(base_scale.x * 1.4, base_scale.y * 0.6), 0.08)
	tween.tween_property(self, "scale", Vector2(base_scale.x * 0.8, base_scale.y * 1.3), 0.08)
	tween.tween_property(self, "scale", base_scale, 0.1)

	if current_health <= 0:
		current_health = 0
		die()


func die() -> void:
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
	
	queue_free()
	if main != null and main.has_method("check_victory_conditions"):
		main.call_deferred("check_victory_conditions")
