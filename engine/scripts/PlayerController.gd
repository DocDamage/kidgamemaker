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

# Powerup states
var speed_boost_timer: float = 0.0
var shield_active: bool = false
var double_jump_enabled: bool = false
var _jumps_remaining: int = 1


func _ready() -> void:
	current_health = max_health


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

	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text(type.replace("_", " ").to_upper() + "!", global_position, Color.CYAN)


func take_damage(amount: int) -> void:
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
		if main != null and main.has_method("_respawn_player"):
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
	var active_speed := movement_speed
	if speed_boost_timer > 0.0:
		speed_boost_timer -= delta
		active_speed = movement_speed * 1.6
		modulate = Color(0.4, 1.0, 1.0) # Cyan modulation for speed
	elif shield_active:
		modulate = Color(1.0, 0.5, 1.0) # Pink modulation for shield
	else:
		if not _invincible:
			modulate = Color(1.0, 1.0, 1.0)

	var input_dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * active_speed

	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
	
	if is_on_floor():
		_jumps_remaining = 2 if double_jump_enabled else 1

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		var did_jump := false
		if is_on_floor():
			velocity.y = jump_force
			_jumps_remaining = 1 if double_jump_enabled else 0
			did_jump = true
		elif _jumps_remaining > 0:
			velocity.y = jump_force * 0.9
			_jumps_remaining -= 1
			did_jump = true
			scale = Vector2(0.8, 1.3)
			var t := create_tween()
			t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

		if did_jump:
			var main := get_tree().get_root().get_node_or_null("Main")
			if main != null and main.has_method("play_custom_sfx"):
				main.play_custom_sfx(asset_id, "jump")

	move_and_slide()
