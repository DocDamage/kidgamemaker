extends Area2D

var target_id: String = ""
var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if triggered or not body is CharacterBody2D:
		return
	triggered = true
	var main := get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method("play_sfx"):
		main.play_sfx("coin")
	if main != null and main.has_method("notify_trigger"):
		main.notify_trigger(name)
	var target := get_parent().get_node_or_null(target_id)
	if target != null and target.has_method("toggle_gate"):
		target.toggle_gate()
