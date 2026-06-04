extends Area2D

var hit_cooldown: float = 0.0


func _ready() -> void:
	area_entered.connect(_on_something_entered)
	body_entered.connect(_on_something_entered)


func _process(delta: float) -> void:
	if hit_cooldown > 0.0:
		hit_cooldown -= delta


func _on_something_entered(node: Node) -> void:
	if hit_cooldown > 0.0:
		return
	if not _is_hit(node):
		return

	hit_cooldown = 0.5
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null:
		if main.has_method("play_sfx"):
			main.play_sfx("coin")
		if main.has_method("notify_trigger"):
			main.notify_trigger(name)
		if main.has_method("spawn_floating_text"):
			main.spawn_floating_text("🎯 TARGET HIT!", global_position, Color.GOLD)

	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", 360.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.0)


func _is_hit(node: Node) -> bool:
	if node.name.contains("Projectile") or node.name.contains("Bullet"):
		node.queue_free()
		return true
	if node is CharacterBody2D and node.name.begins_with("Player"):
		if node.get("has_hammer") == true:
			return true
		var diff_y: float = node.global_position.y - global_position.y
		if diff_y < -16.0:
			if "velocity" in node:
				node.velocity.y = -300.0
			return true
	return false
