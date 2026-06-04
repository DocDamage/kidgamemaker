extends Node

const DEFAULT_SIZE := Vector2(100, 30)
const FLOAT_DISTANCE := 50.0
const FLOAT_DURATION := 0.8
const POP_DURATION := 0.15


func spawn_text(text: String, global_pos: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var settings := LabelSettings.new()
	settings.font_size = 20
	settings.font_color = color
	settings.outline_size = 4
	settings.outline_color = Color.BLACK
	label.label_settings = settings

	label.size = DEFAULT_SIZE
	label.position = global_pos - label.size * 0.5
	label.z_index = 200
	label.scale = Vector2(0.5, 0.5)
	label.pivot_offset = label.size * 0.5
	add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - FLOAT_DISTANCE, FLOAT_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, FLOAT_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), POP_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, POP_DURATION).set_delay(POP_DURATION)
	tween.chain().tween_callback(label.queue_free)
