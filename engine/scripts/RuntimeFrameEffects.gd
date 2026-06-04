extends RefCounted


static func update_hit_stop(hit_stop_timer: float, original_time_scale: float, delta: float) -> float:
	if hit_stop_timer <= 0.0:
		return hit_stop_timer

	var real_delta = delta / (Engine.time_scale if Engine.time_scale > 0.0 else 0.01)
	hit_stop_timer -= real_delta
	if hit_stop_timer <= 0.0:
		Engine.time_scale = original_time_scale
	return hit_stop_timer


static func update_screen_shake(camera: Camera2D, shake_duration: float, shake_amplitude: float, delta: float) -> float:
	if shake_duration <= 0.0:
		return shake_duration

	shake_duration -= delta
	if camera != null:
		if shake_duration <= 0.0:
			camera.offset = Vector2.ZERO
		else:
			var offset_x = randf_range(-shake_amplitude, shake_amplitude)
			var offset_y = randf_range(-shake_amplitude, shake_amplitude)
			camera.offset = Vector2(offset_x, offset_y)
	return shake_duration
