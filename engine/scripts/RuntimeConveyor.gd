extends StaticBody2D

var direction: float = 1.0
var time_passed: float = 0.0
var label: Label = null


func _ready() -> void:
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)
	_update_text()


func _process(delta: float) -> void:
	time_passed += delta
	var offset := int(time_passed * 8.0) % 4
	var arrows := ""
	if direction > 0:
		arrows = "   ".substr(0, offset) + "▶▶▶"
	else:
		arrows = "◀◀◀" + "   ".substr(0, 4 - offset)
	label.text = arrows


func _update_text() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D")
	if collision_shape != null and collision_shape.shape is RectangleShape2D:
		var size: Vector2 = collision_shape.shape.size
		label.size = size
		label.position = -size * 0.5
