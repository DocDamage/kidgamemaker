extends ColorRect

var rising_speed: float = 20.0
var hazard_type: String = "water"
var damage_timer: float = 0.0
var label_node: Label = null


func _ready() -> void:
	label_node = get_child(0) as Label


func _physics_process(delta: float) -> void:
	position.y -= rising_speed * delta

	var main: Node = get_parent()
	if main == null:
		return

	var player: Node2D = main.get("active_player") as Node2D
	if player == null or not is_instance_valid(player):
		return

	if label_node != null:
		label_node.global_position.x = player.global_position.x - 500.0

	if player.global_position.y < global_position.y:
		return

	damage_timer += delta
	if damage_timer < 0.5:
		return

	damage_timer = 0.0
	var damage := 8 if hazard_type == "water" else 20
	if player.has_method("take_damage"):
		player.take_damage(damage)
	if main.has_method("spawn_floating_text"):
		var text := "DROWNING!" if hazard_type == "water" else "BURNING!"
		main.spawn_floating_text(text, player.global_position, Color.RED)
