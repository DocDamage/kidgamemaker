extends Area2D

var velocity: Vector2 = Vector2.ZERO
var shooter: Node = null
var damage: int = 0
var lifetime: float = 3.0
var rotate_to_velocity: bool = false
var gravity_y: float = 0.0
var pierce: bool = false
var element: String = ""
var applies_burn: bool = false

var _hit_entities: Array = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if lifetime > 0.0:
		get_tree().create_timer(lifetime).timeout.connect(_expire)


func _physics_process(delta: float) -> void:
	velocity.y += gravity_y * delta
	global_position += velocity * delta
	if rotate_to_velocity and velocity.length_squared() > 0.0:
		rotation = velocity.angle()


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if not body.has_method("take_damage") or body.name.begins_with("Player"):
		return
	if pierce:
		if body in _hit_entities:
			return
		_hit_entities.append(body)

	body.take_damage(damage, element, shooter)
	if applies_burn and "is_burning" in body:
		body.set("is_burning", true)
		body.set("burn_timer", 3.0)
	if not pierce:
		queue_free()


func _expire() -> void:
	if is_instance_valid(self):
		queue_free()
