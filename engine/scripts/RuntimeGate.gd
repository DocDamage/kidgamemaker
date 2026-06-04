extends AnimatableBody2D

var is_open: bool = false


func toggle_gate() -> void:
	is_open = not is_open
	var main := get_tree().get_root().get_node_or_null("Main")
	if is_open:
		collision_layer = 0
		collision_mask = 0
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.15, 0.3)
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("GATE OPENED!", global_position, Color.GREEN)
	else:
		collision_layer = 1
		collision_mask = 1
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.3)
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("GATE CLOSED!", global_position, Color.RED)
