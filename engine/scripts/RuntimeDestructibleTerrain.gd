extends StaticBody2D

var block_type: String = "brick"
var is_speed_block: bool = false


func _ready() -> void:
	set_meta("is_destructible", true)
	set_meta("block_type", block_type)
	if is_speed_block:
		set_meta("is_speed_block", true)


func shatter() -> void:
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null:
		if main.has_method("spawn_floating_text"):
			main.spawn_floating_text(_shatter_text(), global_position, _shatter_color())
		var particles := CPUParticles2D.new()
		particles.global_position = global_position
		particles.amount = 16 if is_speed_block else 12
		particles.one_shot = true
		particles.explosiveness = 1.0
		particles.lifetime = 0.5 if is_speed_block else 0.6
		particles.spread = 180.0
		particles.initial_velocity_min = 150.0 if is_speed_block else 120.0
		particles.initial_velocity_max = 280.0 if is_speed_block else 240.0
		particles.scale_amount_min = 5.0 if is_speed_block else 4.0
		particles.scale_amount_max = 9.0 if is_speed_block else 8.0
		particles.color = _particle_color()
		main.add_child(particles)
		particles.emitting = true
		get_tree().create_timer(particles.lifetime).timeout.connect(particles.queue_free)
	queue_free()


func _shatter_text() -> String:
	return "💥 SPEED CRASH!" if is_speed_block else "💥 CRASH!"


func _shatter_color() -> Color:
	if is_speed_block:
		return Color.GOLD
	return Color(0.6, 0.85, 1.0) if block_type == "ice" else Color(0.9, 0.4, 0.2)


func _particle_color() -> Color:
	if is_speed_block:
		return Color(1.0, 0.85, 0.2, 0.95)
	return Color(0.6, 0.85, 1.0, 0.9) if block_type == "ice" else Color(0.7, 0.3, 0.2, 0.9)
