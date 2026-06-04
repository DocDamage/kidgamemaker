extends Area2D

var cooldown: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= delta


func _on_body_entered(body: Node) -> void:
	if cooldown <= 0.0 and body is CharacterBody2D and body.name.begins_with("Player"):
		cooldown = 1.0
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("open_shop_ui"):
			main.call_deferred("open_shop_ui")
