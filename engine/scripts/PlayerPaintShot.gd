extends Area2D

var dir: float = 1.0
var speed: float = 450.0
var shooter: Node = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(2.0).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position.x += dir * speed * delta


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return

	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null:
		for ent in main.get("spawned_entities"):
			if is_instance_valid(ent) and ent is StaticBody2D:
				if ent.global_position.distance_to(global_position) < 80.0:
					ent.set_meta("paint_color", "green")
					ent.modulate = Color(0.2, 1.0, 0.2)
		_spawn_paint_burst(main)

	if body.has_method("take_damage") and not body.name.begins_with("Player"):
		body.take_damage(10)
		body.set_meta("paint_color", "green")
		body.modulate = Color(0.2, 1.0, 0.2)

	queue_free()


func _spawn_paint_burst(parent: Node) -> void:
	var particles := CPUParticles2D.new()
	particles.global_position = global_position
	particles.amount = 12
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.4
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.spread = 180.0
	particles.color = Color(0.2, 1.0, 0.2)
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	parent.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(0.4).timeout.connect(particles.queue_free)
