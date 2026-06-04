extends Area2D

var speech_text: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D:
		return
	var label := get_node_or_null("SpeechBubble/SpeechLabel")
	var bubble := get_node_or_null("SpeechBubble")
	if label != null and bubble != null:
		label.text = speech_text
		bubble.visible = true
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("play_sfx"):
			main.play_sfx("jump")


func _on_body_exited(body: Node) -> void:
	var bubble := get_node_or_null("SpeechBubble")
	if bubble != null:
		bubble.visible = false
