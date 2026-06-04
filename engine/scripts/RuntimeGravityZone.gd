extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage") and body is CharacterBody2D:
		body.set("gravity_inverted", true)
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("GRAVITY FLIP! 🌀", body.global_position, Color.PURPLE)
			main.play_sfx("jump")


func _on_body_exited(body: Node) -> void:
	if body.has_method("take_damage") and body is CharacterBody2D:
		body.set("gravity_inverted", false)
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("GRAVITY NORMAL! 🌀", body.global_position, Color.CYAN)
			main.play_sfx("jump")
