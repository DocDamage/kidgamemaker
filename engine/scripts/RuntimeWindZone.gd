extends Area2D

var force_vector: Vector2 = Vector2.ZERO
var _affected_bodies: Array[Node] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	if body_exited.is_connected(_on_body_exited):
		body_exited.disconnect(_on_body_exited)
	_affected_bodies.clear()


func _physics_process(delta: float) -> void:
	for body in _affected_bodies.duplicate():
		if not is_instance_valid(body):
			_affected_bodies.erase(body)
			continue
		if body is CharacterBody2D:
			if "velocity" in body:
				body.velocity += force_vector * delta
		elif body is RigidBody2D:
			body.apply_central_force(force_vector)


func _on_body_entered(body: Node) -> void:
	if not _affected_bodies.has(body):
		_affected_bodies.append(body)
	if body is CharacterBody2D:
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text") and randf() < 0.3:
			main.spawn_floating_text("💨 WHOOSH!", body.global_position, Color.CYAN)


func _on_body_exited(body: Node) -> void:
	_affected_bodies.erase(body)
