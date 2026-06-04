extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	var parent := get_parent()
	if parent == null or not body is CharacterBody2D:
		return

	var launch_dir := parent.get("launch_direction") as Vector2
	var launch_force := float(parent.get("launch_force"))
	var character := body as CharacterBody2D
	character.velocity = launch_dir * launch_force
	if "is_ground_pounding" in character:
		character.set("is_ground_pounding", false)

	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return
	if main.has_method("play_sfx"):
		main.play_sfx("jump")
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text("BOING!", character.global_position, Color.SPRING_GREEN)
