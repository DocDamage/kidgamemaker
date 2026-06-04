extends RefCounted


static func merge(entities: Array, sidecar_loader: Callable, collision_sizer: Callable) -> Array:
	var terrain_entities: Array = []
	var other_entities: Array = []

	for entity in entities:
		if typeof(entity) != TYPE_DICTIONARY:
			continue
		var category := str(entity.get("category", ""))
		var type := str(entity.get("type", ""))
		var asset_id := str(entity.get("asset_id", ""))
		var loaded_sidecar: Variant = sidecar_loader.call(asset_id, category)
		var sidecar: Dictionary = loaded_sidecar if typeof(loaded_sidecar) == TYPE_DICTIONARY else {}
		var runtime_template := str(sidecar.get("runtime_template", type))

		if runtime_template == "terrain":
			terrain_entities.append(entity.duplicate(true))
		else:
			other_entities.append(entity)

	var merged_any := true
	while merged_any:
		merged_any = false
		var merged_list: Array = []
		var skip_indices := {}

		for i in range(terrain_entities.size()):
			if skip_indices.has(i):
				continue
			var box_a: Dictionary = terrain_entities[i]
			var metrics_a := _box_metrics(box_a, sidecar_loader, collision_sizer)

			for j in range(i + 1, terrain_entities.size()):
				if skip_indices.has(j):
					continue
				var box_b: Dictionary = terrain_entities[j]
				if box_a.get("asset_id") != box_b.get("asset_id"):
					continue

				var metrics_b := _box_metrics(box_b, sidecar_loader, collision_sizer)
				if _can_merge(metrics_a, metrics_b):
					_merge_into(box_a, metrics_a, metrics_b)
					skip_indices[j] = true
					merged_any = true

			merged_list.append(box_a)
		terrain_entities = merged_list

	return other_entities + terrain_entities


static func _box_metrics(box: Dictionary, sidecar_loader: Callable, collision_sizer: Callable) -> Dictionary:
	var pos := _read_position(box.get("position", {"x": 0, "y": 0}))
	var loaded_sidecar: Variant = sidecar_loader.call(str(box.get("asset_id", "")), str(box.get("category", "")))
	var sidecar: Dictionary = loaded_sidecar if typeof(loaded_sidecar) == TYPE_DICTIONARY else {}
	var loaded_size: Variant = collision_sizer.call(sidecar, Vector2(128, 32), box)
	var size: Vector2 = loaded_size if typeof(loaded_size) == TYPE_VECTOR2 else Vector2(128, 32)
	return {
		"position": pos,
		"size": size,
		"left": pos.x - size.x * 0.5,
		"right": pos.x + size.x * 0.5,
		"top": pos.y - size.y * 0.5,
		"bottom": pos.y + size.y * 0.5
	}


static func _can_merge(metrics_a: Dictionary, metrics_b: Dictionary) -> bool:
	var pos_a: Vector2 = metrics_a.get("position", Vector2.ZERO)
	var pos_b: Vector2 = metrics_b.get("position", Vector2.ZERO)
	var size_a: Vector2 = metrics_a.get("size", Vector2.ZERO)
	var size_b: Vector2 = metrics_b.get("size", Vector2.ZERO)
	var same_y: bool = abs(pos_a.y - pos_b.y) < 1.0
	var same_h: bool = abs(size_a.y - size_b.y) < 1.0
	var touches_x: bool = (
		float(metrics_b.get("left", 0.0)) <= float(metrics_a.get("right", 0.0)) + 2.0
		and float(metrics_b.get("right", 0.0)) >= float(metrics_a.get("left", 0.0)) - 2.0
	)
	return same_y and same_h and touches_x


static func _merge_into(box_a: Dictionary, metrics_a: Dictionary, metrics_b: Dictionary) -> void:
	var pos_a: Vector2 = metrics_a.get("position", Vector2.ZERO)
	var size_a: Vector2 = metrics_a.get("size", Vector2.ZERO)
	var new_left: float = min(float(metrics_a.get("left", 0.0)), float(metrics_b.get("left", 0.0)))
	var new_right: float = max(float(metrics_a.get("right", 0.0)), float(metrics_b.get("right", 0.0)))
	var new_width: float = new_right - new_left
	var new_center_x: float = new_left + new_width * 0.5

	box_a["position"] = {"x": new_center_x, "y": pos_a.y}
	if not box_a.has("modifiers"):
		box_a["modifiers"] = {}
	box_a["modifiers"]["override_size"] = [new_width, size_a.y]

	metrics_a["position"] = Vector2(new_center_x, pos_a.y)
	metrics_a["size"] = Vector2(new_width, size_a.y)
	metrics_a["left"] = new_left
	metrics_a["right"] = new_right


static func _read_position(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0)), float(value.get("y", 0)))
	return Vector2.ZERO
