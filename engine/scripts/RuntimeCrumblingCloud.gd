extends StaticBody2D

var crumble_delay: float = 0.5
var respawn_time: float = 3.0
var is_crumbled: bool = false


func _ready() -> void:
	var sensor := get_child(get_child_count() - 1)
	sensor.body_entered.connect(_on_player_step)


func _on_player_step(body: Node) -> void:
	if is_crumbled or not body is CharacterBody2D:
		return
	is_crumbled = true
	var tween := create_tween()
	var pos_y := position.y
	tween.tween_property(self, "position:y", pos_y + 4.0, 0.05)
	tween.tween_property(self, "position:y", pos_y - 4.0, 0.05)
	tween.set_loops(int(crumble_delay / 0.1))
	await get_tree().create_timer(crumble_delay).timeout
	collision_layer = 0
	collision_mask = 0
	var fade_tween := create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("hit")
	await get_tree().create_timer(respawn_time).timeout
	collision_layer = 1
	collision_mask = 1
	var restore_tween := create_tween()
	restore_tween.tween_property(self, "modulate:a", 1.0, 0.25)
	is_crumbled = false
