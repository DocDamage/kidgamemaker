extends CharacterBody2D

var rush_color: String = "red"
var gravity: float = 800.0
var speed: float = 130.0
var jump_force: float = -280.0
var active_form: String = "follow"
var jet_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	if rush_color == "red":
		modulate = Color(1.0, 0.3, 0.3)
	elif rush_color == "blue":
		modulate = Color(0.3, 0.5, 1.0)
	elif rush_color == "gold":
		modulate = Color(1.0, 0.85, 0.2)
	_update_visuals()


func _update_visuals() -> void:
	var label := get_node_or_null("Label") as Label
	if label == null:
		label = Label.new()
		label.name = "Label"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var settings := LabelSettings.new()
		settings.font_size = 22
		label.label_settings = settings
		label.size = Vector2(36, 32)
		label.position = -Vector2(18, 16)
		add_child(label)

	match active_form:
		"follow":
			label.text = "DOG"
		"coil":
			label.text = "COIL"
		"jet":
			label.text = "JET"


func toggle_form() -> void:
	active_form = "coil" if active_form == "follow" else ("jet" if active_form == "coil" else "follow")
	_update_visuals()

	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var player: Node2D = main.get("active_player") as Node2D
	if main.has_method("spawn_floating_text") and player != null:
		main.spawn_floating_text("RUSH: " + active_form.to_upper() + "!", player.global_position, Color.AQUAMARINE)
	if main.has_method("play_sfx"):
		main.play_sfx("jump")


func _physics_process(delta: float) -> void:
	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var player: Node2D = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return

	match active_form:
		"follow":
			_follow_player(player, delta)
		"coil":
			_act_as_coil(player, main, delta)
		"jet":
			_act_as_jet(player, delta)


func _follow_player(player: Node2D, delta: float) -> void:
	velocity.y += gravity * delta
	var dist := global_position.distance_to(player.global_position)
	if dist > 350.0:
		global_position = player.global_position + Vector2(-15, -10)
	elif dist > 65.0:
		var dir: float = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 2.5 * delta)
	move_and_slide()


func _act_as_coil(player: Node2D, main: Node, delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = 0.0
	move_and_slide()

	var player_dist := global_position.distance_to(player.global_position)
	if player_dist >= 40.0 or player.global_position.y >= global_position.y - 12.0:
		return

	var player_velocity := player.get("velocity") as Vector2
	player_velocity.y = -620.0
	player.set("velocity", player_velocity)

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 0.6), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	if main.has_method("play_sfx"):
		main.play_sfx("jump")
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("RUSH BOUNCE!", player.global_position, Color.GOLD)


func _act_as_jet(player: Node2D, delta: float) -> void:
	velocity = Vector2.ZERO
	var player_dist := global_position.distance_to(player.global_position)
	var player_on_jet := player_dist < 45.0 and player.global_position.y < global_position.y - 8.0
	if player_on_jet:
		var horizontal_dir := Input.get_axis("ui_left", "ui_right")
		if horizontal_dir == 0.0 and Input.is_physical_key_pressed(KEY_A):
			horizontal_dir = -1.0
		elif horizontal_dir == 0.0 and Input.is_physical_key_pressed(KEY_D):
			horizontal_dir = 1.0
		velocity.x = horizontal_dir * speed * 1.5
		player.global_position.x += velocity.x * delta
	else:
		var target_y := player.global_position.y + 24.0
		global_position.y = move_toward(global_position.y, target_y, speed * 0.5 * delta)
		var dir: float = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed * 0.4
	global_position += velocity * delta
