extends RefCounted


static func collision_size(sidecar: Dictionary, fallback: Vector2, entity_data: Dictionary = {}) -> Vector2:
	var modifiers: Dictionary = entity_data.get("modifiers", {}) if entity_data.has("modifiers") else {}
	if modifiers.has("override_size"):
		var override_size: Variant = modifiers.get("override_size")
		if typeof(override_size) == TYPE_ARRAY and override_size.size() >= 2:
			return Vector2(float(override_size[0]), float(override_size[1]))

	var collision: Dictionary = sidecar.get("collision", {})
	var size_value: Variant = collision.get("size", [fallback.x, fallback.y])
	if typeof(size_value) == TYPE_ARRAY and size_value.size() >= 2:
		return Vector2(float(size_value[0]), float(size_value[1]))
	return fallback


static func add_box_collision(parent: Node, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	parent.add_child(collision)


static func add_fallback_polygon(parent: Node2D, size: Vector2, color: Color) -> void:
	var half := size * 0.5
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y)
	])
	poly.color = color
	parent.add_child(poly)


static func add_visuals(parent: Node2D, sidecar: Dictionary, size: Vector2, default_color: Color, asset_root: String) -> void:
	var visual: String = str(sidecar.get("visual", ""))
	var ext := visual.get_extension().to_lower()
	var is_image := ext in ["png", "jpg", "jpeg", "svg", "webp"]

	var texture: Texture2D = null
	if is_image:
		texture = load_texture_dynamic(visual, str(sidecar.get("sidecar_path", "")), asset_root)

	if texture != null:
		_add_texture_visual(parent, sidecar, size, texture)
	else:
		add_fallback_polygon(parent, size, default_color)
		_add_visual_label(parent, visual, size)


static func load_texture_dynamic(path: String, sidecar_file_path: String, asset_root: String) -> Texture2D:
	var resolved_path := path

	if not path.begins_with("res://") and not path.begins_with("user://") and not path.is_absolute_path():
		if sidecar_file_path != "":
			var base_dir := sidecar_file_path.get_base_dir()
			resolved_path = base_dir.path_join(path)
		else:
			resolved_path = asset_root.path_join(path)

	if resolved_path.begins_with("file://"):
		resolved_path = resolved_path.replace("file://", "")
		if OS.get_name() == "Windows" and resolved_path.begins_with("/"):
			resolved_path = resolved_path.substr(1)

	if resolved_path.begins_with("res://") and ResourceLoader.exists(resolved_path):
		var tex := load(resolved_path) as Texture2D
		if tex != null:
			return tex

	var final_fs_path := ProjectSettings.globalize_path(resolved_path)
	if FileAccess.file_exists(final_fs_path):
		var img := Image.load_from_file(final_fs_path)
		if img != null:
			return ImageTexture.create_from_image(img)

	print("Failed to load texture at path: ", resolved_path, " (FS path: ", final_fs_path, ")")
	return null


static func _add_texture_visual(parent: Node2D, sidecar: Dictionary, size: Vector2, texture: Texture2D) -> void:
	var runtime_template := str(sidecar.get("runtime_template", ""))
	var is_spritesheet: bool = bool(sidecar.get("is_spritesheet", false))
	var frames: Array = sidecar.get("frames", [])

	if is_spritesheet and frames.size() > 0 and (runtime_template == "player" or runtime_template == "enemy"):
		_add_animated_sprite(parent, size, texture, frames)
	elif is_spritesheet and frames.size() > 0:
		_add_spritesheet_region(parent, size, texture, frames)
	else:
		_add_sprite(parent, size, texture, runtime_template)

	parent.set_meta("collision_size", size)


static func _add_animated_sprite(parent: Node2D, size: Vector2, texture: Texture2D, frames: Array) -> void:
	var animated_sprite := AnimatedSprite2D.new()
	var sprite_frames := SpriteFrames.new()
	if not sprite_frames.has_animation("default"):
		sprite_frames.add_animation("default")
	sprite_frames.set_animation_speed("default", 8.0)
	sprite_frames.set_animation_loop("default", true)

	for frame in frames:
		if typeof(frame) == TYPE_DICTIONARY:
			var frame_rect := Rect2(float(frame.get("x", 0)), float(frame.get("y", 0)), float(frame.get("w", 0)), float(frame.get("h", 0)))
			var atlas_tex := AtlasTexture.new()
			atlas_tex.atlas = texture
			atlas_tex.region = frame_rect
			sprite_frames.add_frame("default", atlas_tex)

	animated_sprite.sprite_frames = sprite_frames
	parent.add_child(animated_sprite)

	var first_frame: Dictionary = frames[0]
	var frame_size := Vector2(float(first_frame.get("w", size.x)), float(first_frame.get("h", size.y)))
	if frame_size.x > 0 and frame_size.y > 0:
		animated_sprite.scale = size / frame_size

	animated_sprite.play("default")


static func _add_spritesheet_region(parent: Node2D, size: Vector2, texture: Texture2D, frames: Array) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true

	var first_frame: Dictionary = frames[0]
	var frame_rect := Rect2(float(first_frame.get("x", 0)), float(first_frame.get("y", 0)), float(first_frame.get("w", 0)), float(first_frame.get("h", 0)))
	sprite.region_rect = frame_rect

	parent.add_child(sprite)

	if frame_rect.size.x > 0 and frame_rect.size.y > 0:
		sprite.scale = size / frame_rect.size


static func _add_sprite(parent: Node2D, size: Vector2, texture: Texture2D, runtime_template: String) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture

	if runtime_template == "terrain":
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		sprite.region_enabled = true
		sprite.region_rect = Rect2(Vector2.ZERO, size)
	else:
		var tex_size := texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			sprite.scale = size / tex_size

	parent.add_child(sprite)


static func _add_visual_label(parent: Node2D, visual: String, size: Vector2) -> void:
	if visual == "":
		return

	var label := Label.new()
	label.text = visual
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var settings := LabelSettings.new()
	settings.font_size = 24
	settings.font_color = Color.WHITE
	settings.outline_size = 4
	settings.outline_color = Color.BLACK
	label.label_settings = settings

	label.size = size
	label.position = -size * 0.5
	parent.add_child(label)
