extends AnimatableBody2D

var axis: String = "horizontal"
var speed: float = 100.0
var travel: float = 128.0
var start_pos: Vector2 = Vector2.ZERO
var time_passed: float = 0.0


func _ready() -> void:
	start_pos = global_position


func _physics_process(delta: float) -> void:
	time_passed += delta
	var wave: float = sin(time_passed * (speed / 50.0))
	if axis == "horizontal":
		global_position.x = start_pos.x + wave * travel * 0.5
	else:
		global_position.y = start_pos.y + wave * travel * 0.5
