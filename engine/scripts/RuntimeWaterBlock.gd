extends Area2D

var buoyancy: float = 0.5
var flavor: String = "normal"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and "inside_water" in body:
		body.inside_water = true
		body.water_buoyancy = buoyancy
		body.water_type = flavor
		body.water_hurt_timer = 0.0
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text"):
			main.spawn_floating_text("SPLASH!", global_position, Color.CYAN)


func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D and "inside_water" in body:
		body.inside_water = false
