extends StaticBody2D

var damage_timer: float = 0.0


func _physics_process(delta: float) -> void:
	var line := get_node_or_null("LaserLine") as Line2D
	if not bool(get("powered")):
		if line != null:
			line.visible = false
		return

	if line != null:
		line.visible = true

	damage_timer += delta
	if damage_timer < 0.5:
		return

	damage_timer = 0.0
	var direction := get("force_direction") as Vector2
	var query := PhysicsRayQueryParameters2D.create(global_position, global_position + direction * 300.0)
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return

	var collider := result.get("collider") as Node
	if collider != null and collider.has_method("take_damage"):
		collider.take_damage(float(get("laser_damage")))
