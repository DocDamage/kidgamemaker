extends CharacterBody2D

var pikmin_color: String = "red"
var state: String = "follow"
var latched_enemy: CharacterBody2D = null
var carried_item: Area2D = null
var gravity: float = 800.0
var speed: float = 120.0
var jump_force: float = -280.0
var damage_cooldown: float = 0.0


func _ready() -> void:
	if pikmin_color == "red":
		modulate = Color(1.0, 0.3, 0.3)
	elif pikmin_color == "blue":
		modulate = Color(0.3, 0.5, 1.0)
	elif pikmin_color == "yellow":
		modulate = Color(1.0, 0.9, 0.3)


func is_following() -> bool:
	return state == "follow" or state == "carrying"


func throw(direction: float) -> void:
	if state == "latched":
		unlatch()
	state = "thrown"
	velocity = Vector2(direction * 350.0, -320.0)


func recall() -> void:
	if state == "latched":
		unlatch()
	carried_item = null
	state = "follow"


func unlatch() -> void:
	if latched_enemy != null and is_instance_valid(latched_enemy):
		if latched_enemy.has_method("unregister_pikmin_latch"):
			latched_enemy.unregister_pikmin_latch(self)
	latched_enemy = null
	state = "follow"
	reparent_to_level()


func reparent_to_level() -> void:
	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var old_pos := global_position
	if get_parent() != null:
		get_parent().remove_child(self)
	main.add_child(self)
	global_position = old_pos


func _physics_process(delta: float) -> void:
	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return

	var player: Node2D = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return

	if state != "latched":
		velocity.y += gravity * delta

	match state:
		"follow":
			_follow_player(player, main, delta)
		"carrying":
			_carry_item(player, delta)
		"thrown":
			_handle_thrown(main)
		"stay":
			_wait_for_player(player)
		"latched":
			_damage_latched_enemy(main, delta)

	if state != "latched":
		move_and_slide()


func _follow_player(player: Node2D, main: Node, delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)
	if dist > 300.0:
		global_position = player.global_position + Vector2(-20, -10)
	elif dist > 50.0:
		var dir: float = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 2.0 * delta)

	var spawned: Variant = main.get("spawned_entities")
	if not spawned is Array:
		return

	for ent: Variant in spawned:
		var item := ent as Area2D
		if item == null or not is_instance_valid(item) or not item.has_meta("is_collectible"):
			continue
		if item.get("monitoring") == false:
			continue
		if global_position.distance_to(item.global_position) < 80.0:
			carried_item = item
			state = "carrying"
			break


func _carry_item(player: Node2D, delta: float) -> void:
	if carried_item == null or not is_instance_valid(carried_item):
		state = "follow"
		return

	carried_item.global_position = global_position + Vector2(0, -20)
	var dist := global_position.distance_to(player.global_position)
	if dist > 20.0:
		var dir: float = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		if carried_item.has_method("_on_body_entered"):
			carried_item._on_body_entered(player)
		carried_item = null
		state = "follow"


func _handle_thrown(main: Node) -> void:
	var spawned: Variant = main.get("spawned_entities")
	if spawned is Array:
		for ent: Variant in spawned:
			var enemy := ent as CharacterBody2D
			if enemy == null or not is_instance_valid(enemy):
				continue
			if not enemy.name.begins_with("slime_patrol") and not enemy.has_method("register_pikmin_latch"):
				continue
			if global_position.distance_to(enemy.global_position) < 40.0:
				_latch_to_enemy(enemy)
				break

	if is_on_floor():
		state = "stay"
		velocity.x = 0.0


func _latch_to_enemy(enemy: CharacterBody2D) -> void:
	latched_enemy = enemy
	state = "latched"
	velocity = Vector2.ZERO
	if enemy.has_method("register_pikmin_latch"):
		enemy.register_pikmin_latch(self)

	var old_pos := global_position
	if get_parent() != null:
		get_parent().remove_child(self)
	enemy.add_child(self)
	global_position = old_pos


func _wait_for_player(player: Node2D) -> void:
	velocity.x = 0.0
	if global_position.distance_to(player.global_position) < 40.0:
		state = "follow"


func _damage_latched_enemy(main: Node, delta: float) -> void:
	if latched_enemy == null or not is_instance_valid(latched_enemy):
		unlatch()
		return

	global_position = latched_enemy.global_position + Vector2(0, -15)
	damage_cooldown -= delta
	if damage_cooldown > 0.0:
		return

	damage_cooldown = 1.0
	latched_enemy.take_damage(5)
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("TICK!", global_position, Color.GREEN)
