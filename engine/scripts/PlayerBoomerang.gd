extends Area2D

var player: Node2D = null
var start_pos: Vector2 = Vector2.ZERO
var fly_direction: Vector2 = Vector2.RIGHT
var damage_val: float = 15.0
var is_explosive: bool = false

var _state := "forward"
var _time_passed := 0.0
var _hit_enemies: Array = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_time_passed += delta
	rotation += 15.0 * delta
	if _state == "forward":
		global_position += fly_direction * 350.0 * delta
		if _time_passed >= 0.5:
			_state = "returning"
	else:
		if is_instance_valid(player):
			var to_player := (player.global_position - global_position).normalized()
			global_position += to_player * 400.0 * delta
			if global_position.distance_to(player.global_position) < 20.0:
				queue_free()
		else:
			queue_free()


func _on_body_entered(body: Node) -> void:
	if body == player:
		return
	if body.has_method("take_damage") and not body.name.begins_with("Player"):
		if not body in _hit_enemies:
			_hit_enemies.append(body)
			body.take_damage(int(damage_val))
			if "velocity" in body and player != null:
				var facing_direction := float(player.get("facing_direction"))
				body.velocity += Vector2(facing_direction * 120.0, -80.0)
				
			if is_explosive:
				_explode()

func _explode() -> void:
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("💥 BOOM!", global_position, Color.ORANGE)
		if main.has_method("play_sfx"):
			main.play_sfx("hit")
		if main.has_method("trigger_screen_shake"):
			main.trigger_screen_shake(8.0, 0.25)
	
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 60.0
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 1 | 2

	var hits := space_state.intersect_shape(query)
	for hit in hits:
		var collider = hit.get("collider")
		if collider == null or collider == self:
			continue
		if collider.has_method("take_damage") and not collider.name.begins_with("Player"):
			var dist := global_position.distance_to(collider.global_position)
			var falloff: float = 1.0 - clamp(dist / 60.0, 0.0, 0.8)
			collider.take_damage(int(35.0 * falloff))
		if collider.has_meta("is_destructible") and collider.get_meta("is_destructible") == true:
			collider.call_deferred("shatter")
	
	queue_free()
