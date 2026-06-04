extends Area2D

var action_method: String = ""
var cooldown: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= delta


func _on_body_entered(body: Node) -> void:
	if cooldown > 0.0 or action_method.is_empty():
		return
	if not body is CharacterBody2D or not body.name.begins_with("Player"):
		return

	cooldown = 1.0
	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main != null and main.has_method(action_method):
		main.call_deferred(action_method, self)
