extends RefCounted


static func build(main: Node2D, spawned_entities: Array, contraptions: Array) -> void:
	var glueables := _collect_glueables(spawned_entities)
	if glueables.is_empty():
		return

	var components := _find_zonai_components(glueables)
	for component in components:
		_create_contraption(main, spawned_entities, contraptions, component)


static func _collect_glueables(spawned_entities: Array) -> Array:
	var glueables: Array = []
	for ent in spawned_entities:
		if is_instance_valid(ent):
			var asset_id = ent.get_meta("asset_id") if ent.has_meta("asset_id") else ""
			if asset_id.begins_with("zonai_") or ent.has_meta("chemistry_material"):
				glueables.append(ent)
	return glueables


static func _find_zonai_components(glueables: Array) -> Array:
	var visited := {}
	var components := []

	for node in glueables:
		if visited.has(node):
			continue

		var component := _collect_touching_component(node, glueables, visited)
		if _component_has_zonai_device(component):
			components.append(component)

	return components


static func _collect_touching_component(root: Node2D, glueables: Array, visited: Dictionary) -> Array:
	var component := []
	var queue := [root]
	visited[root] = true

	while not queue.is_empty():
		var current = queue.pop_front()
		component.append(current)

		var rect_current := _node_touch_rect(current)
		for candidate in glueables:
			if visited.has(candidate):
				continue
			if rect_current.intersects(_node_touch_rect(candidate)):
				visited[candidate] = true
				queue.append(candidate)

	return component


static func _component_has_zonai_device(component: Array) -> bool:
	for node in component:
		var asset_id = node.get_meta("asset_id") if node.has_meta("asset_id") else ""
		if asset_id.begins_with("zonai_"):
			return true
	return false


static func _create_contraption(main: Node2D, spawned_entities: Array, contraptions: Array, component: Array) -> void:
	var centroid := _component_centroid(component)
	var rigidbody := RigidBody2D.new()
	rigidbody.name = "ZonaiContraption"
	rigidbody.global_position = centroid
	rigidbody.contact_monitor = true
	rigidbody.max_contacts_reported = 4

	main.add_child(rigidbody)
	contraptions.append(rigidbody)

	for node in component:
		var offset = node.global_position - centroid
		_move_collision_children_to_rigidbody(node, rigidbody)

		node.get_parent().remove_child(node)
		rigidbody.add_child(node)
		node.position = offset
		spawned_entities.erase(node)


static func _component_centroid(component: Array) -> Vector2:
	var sum_pos := Vector2.ZERO
	for node in component:
		sum_pos += node.global_position
	return sum_pos / component.size()


static func _node_touch_rect(node: Node2D) -> Rect2:
	var size = node.get_meta("collision_size") if node.has_meta("collision_size") else Vector2(48, 48)
	return Rect2(node.global_position - size / 2 - Vector2(2, 2), size + Vector2(4, 4))


static func _move_collision_children_to_rigidbody(node: Node, rigidbody: RigidBody2D) -> void:
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			var child_global = child.global_position
			node.remove_child(child)
			rigidbody.add_child(child)
			child.global_position = child_global
