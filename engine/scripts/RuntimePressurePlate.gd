extends Area2D

var target_id: String = ""
var active_bodies: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D:
		return
	active_bodies += 1
	if active_bodies != 1:
		return
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null:
		if main.has_method("play_sfx"):
			main.play_sfx("coin")
		if main.has_method("notify_pressure_plate"):
			main.notify_pressure_plate(name, true)
	_toggle_target()


func _on_body_exited(body: Node) -> void:
	if not body is CharacterBody2D:
		return
	active_bodies = max(0, active_bodies - 1)
	if active_bodies != 0:
		return
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("notify_pressure_plate"):
		main.notify_pressure_plate(name, false)
	_toggle_target()


func _toggle_target() -> void:
	var target := get_parent().get_node_or_null(target_id)
	if target != null and target.has_method("toggle_gate"):
		target.toggle_gate()
