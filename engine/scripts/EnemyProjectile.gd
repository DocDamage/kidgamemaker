extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage_value: int = 10


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(3.0).timeout.connect(_expire)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta


func _on_body_entered(body: Node) -> void:
	var main_ref := get_tree().get_root().get_node_or_null("Main")
	if main_ref != null and main_ref.get("calm_mode") == true:
		queue_free()
		return
	if body.has_method("take_damage"):
		body.take_damage(damage_value)
	queue_free()


func _expire() -> void:
	if is_instance_valid(self):
		queue_free()
