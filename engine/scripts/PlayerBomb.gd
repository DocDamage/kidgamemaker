extends CharacterBody2D

var player: Node = null
var fuse := 2.0
var blast_radius := 80.0
var gravity: float = 600.0


func _ready() -> void:
	if player != null:
		velocity = Vector2(float(player.get("facing_direction")) * 220.0, -200.0)


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()
	fuse -= delta

	var spark_node := get_child(1)
	spark_node.visible = Engine.get_physics_frames() % 6 < 3
	if fuse <= 0.0:
		explode()


func explode() -> void:
	var main := get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return
	if main.has_method("play_sfx"):
		main.play_sfx("hit")
	if main.has_method("trigger_screen_shake"):
		main.trigger_screen_shake(10.0, 0.35)
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("💥 BOOM!", global_position, Color.RED)

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = blast_radius
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
			var falloff: float = 1.0 - clamp(dist / blast_radius, 0.0, 0.8)
			collider.take_damage(int(45.0 * falloff))
			if "velocity" in collider:
				var dir: Vector2 = (collider.global_position - global_position).normalized()
				collider.velocity += dir * 350.0 * falloff
		if collider.has_meta("is_destructible") and collider.get_meta("is_destructible") == true:
			collider.call_deferred("shatter")

	queue_free()
