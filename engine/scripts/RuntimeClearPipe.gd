extends Node2D


func _draw() -> void:
	draw_rect(Rect2(-24, -24, 48, 48), Color(0.5, 0.8, 1.0, 0.25), true)
	draw_rect(Rect2(-24, -24, 48, 48), Color(0.5, 0.8, 1.0, 0.85), false, 3.0)
	draw_rect(Rect2(-18, -18, 36, 36), Color(0.7, 0.9, 1.0, 0.45), false, 1.0)
