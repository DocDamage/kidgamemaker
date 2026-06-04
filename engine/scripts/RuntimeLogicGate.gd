extends Node2D

var gate_type: String = ""
var input_1: bool = false
var input_2: bool = false
var output_state: bool = false


func _ready() -> void:
	gate_type = str(get_meta("gate_type"))
	_update_visuals()


func set_input(index: int, value: bool) -> void:
	if index == 1:
		input_1 = value
	else:
		input_2 = value
	_evaluate()


func _evaluate() -> void:
	var old_output := output_state
	match gate_type:
		"and":
			output_state = input_1 and input_2
		"or":
			output_state = input_1 or input_2
		"not":
			output_state = not input_1
	_update_visuals()
	if output_state != old_output:
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null:
			var trigger_event := "logic_gate_on" if output_state else "logic_gate_off"
			main.execute_rules(trigger_event, name)


func _update_visuals() -> void:
	modulate = Color(1.2, 1.2, 1.2) if output_state else Color(0.6, 0.6, 0.6)
	var label := get_node_or_null("Label")
	if label == null:
		label = Label.new()
		label.name = "Label"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var settings := LabelSettings.new()
		settings.font_size = 11
		settings.outline_size = 2
		settings.outline_color = Color.BLACK
		label.label_settings = settings
		label.size = Vector2(48, 48)
		label.position = -Vector2(24, 24)
		add_child(label)

	var in1_str := "●" if input_1 else "○"
	var in2_str := "●" if input_2 else "○"
	var out_str := "●" if output_state else "○"
	if gate_type == "not":
		label.text = "%s\nNOT\n%s" % [in1_str, out_str]
	else:
		label.text = "%s %s\n%s\n%s" % [in1_str, in2_str, gate_type.to_upper(), out_str]
