extends Area2D

@export var score_value: int = 0

var collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if collected:
		return

	if body is CharacterBody2D:
		collected = true
		print("Collected item for score: ", score_value)
		queue_free()
