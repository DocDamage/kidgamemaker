extends CharacterBody2D

const COOKIE_SCRIPT := preload("res://scripts/RuntimePalicoCookie.gd")

var palico_color: String = "calico"
var gravity: float = 800.0
var speed: float = 140.0
var jump_force: float = -300.0
var attack_cooldown: float = 0.0
var cookie_cooldown: float = 0.0
var followers := []


func _ready() -> void:
	if palico_color == "calico":
		modulate = Color(1.0, 0.7, 0.4)
	elif palico_color == "black":
		modulate = Color(0.3, 0.3, 0.35)
	elif palico_color == "pink":
		modulate = Color(1.0, 0.5, 0.7)
	elif palico_color == "green":
		modulate = Color(0.4, 0.8, 0.4)

	# Spawn 5 mini followers trailing in a chain
	for i in range(5):
		var follower = _spawn_mini_follower("kitten", i)
		followers.append(follower)

	var label := Label.new()
	label.text = "CAT"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 22
	label.label_settings = settings
	label.size = Vector2(32, 32)
	label.position = -Vector2(16, 16)
	add_child(label)


func _physics_process(delta: float) -> void:
	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var player: Node2D = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return

	_follow_player(player, delta)
	attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		_attack_nearby_enemy(main, player)

	cookie_cooldown -= delta
	if cookie_cooldown <= 0.0 and player.has_method("heal"):
		var current_hp: float = float(player.get("current_health"))
		var max_hp: float = max(1.0, float(player.get("max_health")))
		if current_hp > 0.0 and current_hp / max_hp < 0.5:
			cookie_cooldown = 12.0
			_spawn_healing_cookie()


func _follow_player(player: Node2D, delta: float) -> void:
	velocity.y += gravity * delta
	var dist := global_position.distance_to(player.global_position)
	if dist > 350.0:
		global_position = player.global_position + Vector2(-15, -10)
	elif dist > 60.0:
		var dir: float = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 2.5 * delta)
	move_and_slide()


func _attack_nearby_enemy(main: Node, player: Node2D) -> void:
	var closest_enemy: Node2D = null
	var min_dist := 80.0
	for child in main.get_children():
		var candidate := child as Node2D
		if candidate == null or candidate == player or candidate == self:
			continue
		if not candidate.has_method("take_damage"):
			continue
		if candidate.name.begins_with("Player") or candidate.name.begins_with("RecoveryGhost") or candidate.name.begins_with("Area2D"):
			continue
		var dist := global_position.distance_to(candidate.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_enemy = candidate

	if closest_enemy == null:
		return

	attack_cooldown = 1.5
	closest_enemy.take_damage(8)
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("CLAW!", closest_enemy.global_position, Color.ORANGE)


func _spawn_healing_cookie() -> void:
	var main := get_parent()
	if main == null:
		return

	var cookie := Area2D.new()
	cookie.global_position = global_position + Vector2(sign(velocity.x) * 20.0, -10.0)
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	collision.shape = circle
	cookie.add_child(collision)

	var label := Label.new()
	label.text = "COOKIE"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 18
	label.label_settings = settings
	label.size = Vector2(56, 24)
	label.position = -Vector2(28, 12)
	cookie.add_child(label)

	cookie.set_script(COOKIE_SCRIPT)
	main.add_child(cookie)

	var tween := main.create_tween()
	tween.tween_property(cookie, "position:y", cookie.position.y - 30.0, 0.35).set_ease(Tween.EASE_OUT)
	tween.tween_property(cookie, "position:y", cookie.position.y, 0.35).set_ease(Tween.EASE_IN)


func _spawn_mini_follower(type: String, index: int) -> CharacterBody2D:
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return null
	
	var follower := CharacterBody2D.new()
	follower.name = "%s_follower_%d" % [name, index]
	
	var script = load("res://scripts/RuntimeSwarmFollower.gd")
	follower.set_script(script)
	follower.set("follower_type", type)
	follower.set("follower_index", index)
	
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	collision.shape = circle
	follower.add_child(collision)
	
	var label := Label.new()
	label.text = "🐱"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 14
	label.label_settings = settings
	label.size = Vector2(16, 16)
	label.position = -Vector2(8, 8)
	label.pivot_offset = Vector2(8, 8)
	follower.add_child(label)
	
	if index == 0:
		follower.set("leader", self)
	else:
		var prev = followers[index - 1]
		follower.set("leader", prev)
		
	main.call_deferred("add_child", follower)
	follower.global_position = global_position + Vector2(-16 * (index + 1), 0)
	
	var spawned = main.get("spawned_entities")
	if spawned is Array:
		spawned.append(follower)
		
	return follower
