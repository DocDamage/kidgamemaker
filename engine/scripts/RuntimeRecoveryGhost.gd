extends Area2D

var coins: int = 0
var emeralds: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D or not body.name.begins_with("Player"):
		return

	var main: Node = get_tree().get_root().get_node_or_null("Main")
	if main != null:
		var current_score := int(main.get("score"))
		main.set("score", current_score + coins)
		if main.has_method("_update_hud"):
			main._update_hud()
		
		if "emeralds_collected" in body:
			body.emeralds_collected += emeralds
			
		if main.has_method("play_sfx"):
			main.play_sfx("coin")
		if main.has_method("spawn_floating_text"):
			var txt = "RECOVERED "
			if coins > 0 and emeralds > 0:
				txt += str(coins) + " COINS & " + str(emeralds) + " EMERALDS!"
			elif emeralds > 0:
				txt += str(emeralds) + " EMERALDS!"
			else:
				txt += str(coins) + " COINS!"
			main.spawn_floating_text(txt, global_position, Color.GOLD)

	queue_free()
