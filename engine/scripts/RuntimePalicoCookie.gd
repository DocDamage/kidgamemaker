extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D or not body.name.begins_with("Player"):
		return
	if not body.has_method("heal"):
		return

	body.heal(15)
	var main: Node = get_parent()
	if main != null and main.has_method("spawn_floating_text"):
		main.spawn_floating_text("YUM! +15 HP", global_position, Color.BISQUE)
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("coin")
	queue_free()
