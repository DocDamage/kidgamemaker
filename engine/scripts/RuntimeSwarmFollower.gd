extends CharacterBody2D

var follower_type: String = "pikmin"
var follower_index: int = 0
var leader: Node2D = null
var target_item: Area2D = null
var carried_item: Area2D = null
var target_enemy: CharacterBody2D = null
var state: String = "follow" # follow, fetch, carry, attack, return
var speed: float = 150.0
var gravity: float = 800.0
var jump_force: float = -260.0
var search_cooldown: float = 0.0
var attack_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(leader):
		queue_free()
		return
		
	var main = get_tree().get_root().get_node_or_null("Main")
	if main == null: return
	
	var player = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return
		
	# Apply gravity
	if state != "latched":
		velocity.y += gravity * delta
		
	match state:
		"follow":
			_process_follow(delta)
			_search_targets(main, delta)
		"fetch":
			_process_fetch(player, delta)
		"carry":
			_process_carry(player, delta)
		"attack":
			_process_attack(main, delta)
		"return":
			_process_return(delta)

	# Flip label based on horizontal movement
	var label = get_node_or_null("Label")
	if label != null and velocity.x != 0.0:
		label.scale.x = sign(velocity.x)

	if state != "latched":
		move_and_slide()

func _process_follow(delta: float) -> void:
	var target_pos = leader.global_position
	var dist = global_position.distance_to(target_pos)
	if dist > 250.0:
		# Teleport if too far
		global_position = target_pos + Vector2(-15, 0)
	elif dist > 32.0:
		var dir = sign(target_pos.x - global_position.x)
		velocity.x = dir * speed
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 3.0 * delta)

func _search_targets(main: Node, delta: float) -> void:
	search_cooldown -= delta
	if search_cooldown > 0.0: return
	search_cooldown = 0.3 # search every 0.3s
	
	var spawned = main.get("spawned_entities")
	if not spawned is Array: return
	
	# 1. Search for nearby collectibles first
	var closest_item: Area2D = null
	var min_item_dist := 120.0
	for ent in spawned:
		var item = ent as Area2D
		if item != null and is_instance_valid(item) and item.has_meta("is_collectible"):
			if item.get("monitoring") == true:
				var dist = global_position.distance_to(item.global_position)
				if dist < min_item_dist:
					min_item_dist = dist
					closest_item = item
					
	if closest_item != null:
		target_item = closest_item
		state = "fetch"
		return
		
	# 2. Search for nearby enemies to attack
	var closest_enemy: CharacterBody2D = null
	var min_enemy_dist := 100.0
	for ent in spawned:
		var enemy = ent as CharacterBody2D
		if enemy != null and is_instance_valid(enemy) and not enemy.name.begins_with("Player") and not enemy.name.contains("follower"):
			if enemy.has_method("take_damage"):
				var dist = global_position.distance_to(enemy.global_position)
				if dist < min_enemy_dist:
					min_enemy_dist = dist
					closest_enemy = enemy
					
	if closest_enemy != null:
		target_enemy = closest_enemy
		state = "attack"
		attack_cooldown = 1.0

func _process_fetch(player: Node2D, delta: float) -> void:
	if not is_instance_valid(target_item) or target_item.get("monitoring") == false:
		state = "return"
		return
		
	var dist = global_position.distance_to(target_item.global_position)
	if dist > 15.0:
		var dir = sign(target_item.global_position.x - global_position.x)
		velocity.x = dir * speed * 1.3
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		# Start carrying!
		carried_item = target_item
		target_item = null
		state = "carry"

func _process_carry(player: Node2D, delta: float) -> void:
	if not is_instance_valid(carried_item) or carried_item.get("monitoring") == false:
		carried_item = null
		state = "return"
		return
		
	carried_item.global_position = global_position + Vector2(0, -16)
	
	var dist = global_position.distance_to(player.global_position)
	if dist > 24.0:
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed * 1.2
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		# Deliver to player!
		if carried_item.has_method("_on_body_entered"):
			carried_item._on_body_entered(player)
		carried_item = null
		state = "follow"

func _process_attack(main: Node, delta: float) -> void:
	if not is_instance_valid(target_enemy):
		state = "return"
		return
		
	var dist = global_position.distance_to(target_enemy.global_position)
	if dist > 20.0:
		var dir = sign(target_enemy.global_position.x - global_position.x)
		velocity.x = dir * speed * 1.4
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
	else:
		# Attack!
		target_enemy.take_damage(4)
		if main.has_method("spawn_floating_text"):
			main.spawn_floating_text("💥 TICK!", target_enemy.global_position, Color.GREEN_YELLOW)
		state = "return"

func _process_return(delta: float) -> void:
	var target_pos = leader.global_position
	var dist = global_position.distance_to(target_pos)
	if dist < 24.0:
		state = "follow"
	else:
		var dir = sign(target_pos.x - global_position.x)
		velocity.x = dir * speed * 1.2
		if is_on_wall() and is_on_floor():
			velocity.y = jump_force
