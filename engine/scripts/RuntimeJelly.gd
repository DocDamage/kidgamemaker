extends Area2D

var bounce_force: float = 500.0
var scale_multiplier: float = 1.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.has_method("take_damage") or not body is CharacterBody2D:
		return
	body.velocity.y = -bounce_force
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null:
		if main.has_method("play_sfx"):
			main.play_sfx("jump")
		if main.has_method("spawn_floating_text"):
			main.spawn_floating_text("BOING!", global_position, Color.YELLOW)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.3 * scale_multiplier, 0.6 * scale_multiplier), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0 * scale_multiplier, 1.0 * scale_multiplier), 0.12)
