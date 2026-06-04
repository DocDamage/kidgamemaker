extends Area2D

var damage_value: int = 15


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage") and body is CharacterBody2D:
		body.take_damage(damage_value)
