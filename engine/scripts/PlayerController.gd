extends CharacterBody2D

@export var max_health: int = 100
@export var movement_speed: float = 220.0
@export var jump_force: float = -460.0
@export var gravity_scale: float = 1.0

var current_health: int = max_health
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	current_health = max_health


func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Player healed by %d HP. HP now: %d/%d" % [amount, current_health, max_health])


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * movement_speed

	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_force

	move_and_slide()

