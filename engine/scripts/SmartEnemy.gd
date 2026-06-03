extends CharacterBody2D

@export var patrol_speed: float = 70.0
@export var gravity_scale: float = 1.0
@export var ledge_probe_distance: float = 28.0
@export var ledge_probe_depth: float = 48.0
@export var damage_value: int = 10
@export var boss_mode: bool = false

var direction: int = -1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var floor_probe: RayCast2D
var _damage_area: Area2D = null


func _ready() -> void:
	floor_probe = RayCast2D.new()
	floor_probe.enabled = true
	add_child(floor_probe)
	_update_probe()

	# Boss: scale up and move faster
	if boss_mode:
		scale = Vector2(1.8, 1.8)
		patrol_speed *= 1.5

	# Damage hitbox — slightly smaller than collision box so it feels fair
	_damage_area = Area2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28, 28)
	var col := CollisionShape2D.new()
	col.shape = shape
	_damage_area.add_child(col)
	_damage_area.collision_layer = 0
	_damage_area.collision_mask = 1   # layer 1 = player CharacterBody2D
	_damage_area.body_entered.connect(_on_damage_area_body_entered)
	add_child(_damage_area)


func _on_damage_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage_value)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta

	velocity.x = float(direction) * patrol_speed
	move_and_slide()

	if is_on_wall() or not _has_floor_ahead():
		direction *= -1
		_update_probe()


func _has_floor_ahead() -> bool:
	_update_probe()
	floor_probe.force_raycast_update()
	return floor_probe.is_colliding()


func _update_probe() -> void:
	if floor_probe == null:
		return
	floor_probe.position = Vector2(float(direction) * ledge_probe_distance, 0)
	floor_probe.target_position = Vector2(0, ledge_probe_depth)
