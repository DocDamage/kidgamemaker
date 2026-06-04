extends Area2D

var boost_direction: float = 1.0
var boost_force: float = 550.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and "speed_pad_velocity" in body:
		body.speed_pad_velocity = Vector2(boost_direction * boost_force, 0.0)
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null:
			if main.has_method("play_sfx"):
				main.play_sfx("coin")
			if main.has_method("spawn_floating_text"):
				main.spawn_floating_text("ZOOM!", global_position, Color.CYAN)
