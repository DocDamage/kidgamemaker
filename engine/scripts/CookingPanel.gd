extends Panel

var timer: float = 0.0
var finished: bool = false
var main_ref: Node = null
var meat_lbl: Label = null
var status_lbl: Label = null


func _ready() -> void:
	main_ref = get_tree().get_root().get_node_or_null("Main")
	meat_lbl = get_child(1) as Label

	status_lbl = Label.new()
	status_lbl.text = "Cooking..."
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var status_settings := LabelSettings.new()
	status_settings.font_size = 24
	status_lbl.label_settings = status_settings
	status_lbl.size = Vector2(400, 40)
	status_lbl.position = Vector2(120, 240)
	add_child(status_lbl)

	var help := Label.new()
	help.text = "Press [Space] at the perfect Golden Brown moment!\n[Esc] Exit"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var help_settings := LabelSettings.new()
	help_settings.font_size = 16
	help.label_settings = help_settings
	help.size = Vector2(400, 50)
	help.position = Vector2(120, 310)
	add_child(help)


func _process(delta: float) -> void:
	if finished or meat_lbl == null or status_lbl == null:
		return

	timer += delta
	meat_lbl.rotation = timer * 4.0
	if timer < 1.5:
		meat_lbl.text = "RAW"
		status_lbl.text = "Raw (Keep cooking...)"
		status_lbl.label_settings.font_color = Color.PINK
	elif timer < 2.5:
		meat_lbl.text = "COOK"
		status_lbl.text = "Cooking (Getting closer...)"
		status_lbl.label_settings.font_color = Color.KHAKI
	elif timer < 3.5:
		meat_lbl.text = "PERFECT"
		status_lbl.text = "PERFECT GOLDEN BROWN!"
		status_lbl.label_settings.font_color = Color.YELLOW
		var wave := sin(timer * 20.0) * 0.15 + 1.0
		meat_lbl.scale = Vector2(wave, wave)
	else:
		meat_lbl.text = "BURNT"
		status_lbl.text = "BURNT!"
		status_lbl.label_settings.font_color = Color.DARK_SLATE_GRAY
		meat_lbl.scale = Vector2(1.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if event.is_physical_key_pressed(KEY_ESCAPE):
		if main_ref != null and main_ref.has_method("close_cooking_ui"):
			main_ref.close_cooking_ui()
	elif event.is_action_just_pressed("ui_accept") or event.is_physical_key_pressed(KEY_SPACE):
		if not finished:
			_complete_cooking()


func _complete_cooking() -> void:
	finished = true
	var player := _player()
	if player == null or status_lbl == null:
		return

	if timer >= 2.5 and timer < 3.5:
		_play("coin")
		status_lbl.text = "SO TASTY! (+20 Max HP!)"
		status_lbl.label_settings.font_color = Color.GOLD
		var max_health := int(player.get("max_health")) + 20
		player.set("max_health", max_health)
		if player.has_method("heal"):
			player.heal(max_health)
		_float_text("SO TASTY! +20 Max HP", player, Color.GOLD)
	else:
		_play("hit")
		if timer < 2.5:
			status_lbl.text = "Raw steak! (No HP)"
			status_lbl.label_settings.font_color = Color.RED
			_float_text("RAW! 0 HP", player, Color.RED)
		else:
			status_lbl.text = "Charcoal burnt! (No HP)"
			status_lbl.label_settings.font_color = Color.GRAY
			_float_text("BURNT! 0 HP", player, Color.DARK_GRAY)

	var close_timer := get_tree().create_timer(1.8)
	if main_ref != null and main_ref.has_method("close_cooking_ui"):
		close_timer.timeout.connect(main_ref.close_cooking_ui)


func _player() -> Node:
	if main_ref == null:
		return null
	return main_ref.get("active_player") as Node


func _play(sound: String) -> void:
	if main_ref != null and main_ref.has_method("play_sfx"):
		main_ref.play_sfx(sound)


func _float_text(text: String, player: Node, color: Color) -> void:
	var player_2d := player as Node2D
	if main_ref != null and player_2d != null and main_ref.has_method("spawn_floating_text"):
		main_ref.spawn_floating_text(text, player_2d.global_position, color)
