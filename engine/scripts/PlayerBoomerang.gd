extends Area2D

var player: Node2D = null
var start_pos: Vector2 = Vector2.ZERO
var fly_direction: Vector2 = Vector2.RIGHT
var damage_val: float = 15.0

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
