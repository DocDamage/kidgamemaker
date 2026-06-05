extends RefCounted


static func add_to_backpack_grid(backpack_grid: Array, item_type: String) -> bool:
	var size := _item_size(item_type)
	var width := int(size.x)
	var height := int(size.y)

	for row in range(4 - height + 1):
		for column in range(4 - width + 1):
			if not _item_fits(backpack_grid, row, column, width, height):
				continue
			_place_item(backpack_grid, item_type, row, column, width, height)
			print("Added ", item_type, " to backpack at ", row, ", ", column)
			return true

	print("Backpack is full! Cannot add: ", item_type)
	return false


static func _item_size(item_type: String) -> Vector2i:
	if item_type in ["shield", "weapon_shield"]:
		return Vector2i(2, 2)
	if item_type in ["sword", "firesword", "weapon_sword", "tool_hammer"]:
		return Vector2i(1, 2)
	return Vector2i(1, 1)


static func _item_fits(backpack_grid: Array, row: int, column: int, width: int, height: int) -> bool:
	for row_offset in range(height):
		for column_offset in range(width):
			if backpack_grid[row + row_offset][column + column_offset] != null:
				return false
	return true


static func _place_item(backpack_grid: Array, item_type: String, row: int, column: int, width: int, height: int) -> void:
	for row_offset in range(height):
		for column_offset in range(width):
			backpack_grid[row + row_offset][column + column_offset] = {
				"type": item_type,
				"root_r": row,
				"root_c": column,
				"w": width,
				"h": height
			}
