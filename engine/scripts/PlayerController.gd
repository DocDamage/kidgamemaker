extends CharacterBody2D

@export var max_health: int = 100
@export var movement_speed: float = 220.0
@export var jump_force: float = -460.0
@export var gravity_scale: float = 1.0
@export var invincibility_duration: float = 0.8

var current_health: int = max_health
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _invincible := false


func _ready() -> void:
	current_health = max_health


func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Player healed by %d HP. HP now: %d/%d" % [amount, current_health, max_health])


func take_damage(amount: int) -> void:
	if _invincible:
		return

	current_health -= amount
	print("Player took %d damage! HP now: %d/%d" % [amount, current_health, max_health])

	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("hit")

	if current_health <= 0:
		current_health = 0
		print("Player has died!")
		# Notify Main to respawn
		if main != null and main.has_method("_respawn_player"):
			main.call_deferred("_respawn_player")
		return

	# Brief invincibility flash after taking damage
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
	var input_dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * movement_speed

	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_force
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("jump")

	move_and_slide()
