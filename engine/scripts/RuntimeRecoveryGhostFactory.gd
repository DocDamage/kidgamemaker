extends RefCounted


static func remove_existing(root: Node) -> void:
	for child in root.get_children():
		if child.name.begins_with("RecoveryGhost"):
			child.queue_free()


static func create(pos: Vector2, lost_coins: int, lost_emeralds: int, behavior_script: Script) -> Area2D:
	var area := Area2D.new()
	area.name = "RecoveryGhost"
	area.global_position = pos

	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	collision.shape = circle
	area.add_child(collision)

	var label := Label.new()
	label.text = "👻"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 28
	settings.outline_size = 3
	settings.outline_color = Color.BLACK
	label.label_settings = settings
	label.size = Vector2(40, 40)
	label.position = -Vector2(20, 20)
	area.add_child(label)

	area.set_script(behavior_script)
	area.set("coins", lost_coins)
	area.set("emeralds", lost_emeralds)
	return area


static func animate(root: Node, recovery_ghost: Area2D) -> void:
	var label = recovery_ghost.get_child(1) if recovery_ghost.get_child_count() > 1 else null
	if label == null:
		return
	var tween = root.create_tween().set_loops()
	tween.tween_property(label, "position:y", -28.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "position:y", -12.0, 0.8).set_trans(Tween.TRANS_SINE)
