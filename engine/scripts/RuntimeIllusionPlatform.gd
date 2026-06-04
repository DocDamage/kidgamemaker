extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.3, 0.25)


func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.25)
