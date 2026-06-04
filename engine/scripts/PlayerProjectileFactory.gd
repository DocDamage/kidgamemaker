extends RefCounted

const PlayerLinearProjectileScript = preload("res://scripts/PlayerLinearProjectile.gd")
const PlayerBoomerangScript = preload("res://scripts/PlayerBoomerang.gd")
const PlayerBombScript = preload("res://scripts/PlayerBomb.gd")
const PlayerPaintShotScript = preload("res://scripts/PlayerPaintShot.gd")


static func fire_projectile(player: CharacterBody2D, main: Node, charge: float) -> void:
	var facing := _facing(player)
	var is_mega := charge >= 1.0
	var text := "⚡ MEGA BLAST!" if is_mega else "🔫 PEW!"
	var damage := 40 if is_mega else 10
	var speed := 180.0 if is_mega else 300.0
	var size := Vector2(24, 24) if is_mega else Vector2(10, 6)
	var color := Color(1.0, 0.85, 0.1, 1.0) if is_mega else Color(0.1, 0.85, 1.0, 1.0)

	_play_sfx(main, "jump")
	_spawn_text(main, text, player.global_position, Color.GOLD if is_mega else Color.CYAN)

	var bullet := _create_circle_area("PlayerProjectile", size.x * 0.5, color, size)
	_configure_linear_projectile(bullet, player, Vector2(facing * speed, 0.0), damage, 4.0)
	bullet.global_position = player.global_position + Vector2(facing * 16.0, -10.0)
	main.add_child(bullet)


static func fire_archer_arrow(player: CharacterBody2D, main: Node) -> void:
	var facing := _facing(player)
	_play_sfx(main, "jump")
	_spawn_text(main, "🏹 ARROW!", player.global_position, Color.GREEN)

	var shoot_dir := Vector2(facing, 0.0)
	var closest_enemy := _closest_enemy(player, main, 300.0)
	if closest_enemy != null:
		shoot_dir = (closest_enemy.global_position - player.global_position).normalized()

	var bullet := _create_circle_area("ArcherArrow", 4.0, Color.GREEN, Vector2(16, 4))
	_configure_linear_projectile(bullet, player, shoot_dir * 450.0, 12, 3.0, true)
	bullet.global_position = player.global_position + Vector2(facing * 16.0, -10.0)
	main.add_child(bullet)


static func fire_mage_wand_bolt(player: CharacterBody2D, main: Node, copied_enemy_projectile: String) -> void:
	if copied_enemy_projectile != "":
		fire_copied_projectile(player, main, copied_enemy_projectile)
		return

	var facing := _facing(player)
	_play_sfx(main, "hit")
	_spawn_text(main, "🔮 WAND!", player.global_position, Color.PURPLE)

	var bullet := _create_circle_area("MageWandBolt", 4.0, Color(0.8, 0.4, 1.0), Vector2(8, 8))
	_configure_linear_projectile(bullet, player, Vector2(facing * 350.0, 0.0), 8, 2.0)
	bullet.global_position = player.global_position + Vector2(facing * 16.0, -10.0)
	main.add_child(bullet)


static func fire_copied_projectile(player: CharacterBody2D, main: Node, copied_enemy_projectile: String) -> void:
	var facing := _facing(player)
	_play_sfx(main, "hit")
	_spawn_text(main, "🧬 " + copied_enemy_projectile.to_upper() + "!", player.global_position, Color.DEEP_SKY_BLUE)

	var bullet := Area2D.new()
	bullet.name = "CopiedProjectile"
	var visual := Label.new()
	visual.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	visual.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var settings := LabelSettings.new()
	settings.font_size = 14
	visual.label_settings = settings
	visual.size = Vector2(20, 20)
	visual.position = -Vector2(10, 10)

	var damage := 10
	var applies_burn := false
	var applies_gravity := false
	if copied_enemy_projectile == "slime_spit":
		visual.text = "🟢"
		damage = 12
		applies_gravity = true
	elif copied_enemy_projectile == "fireball":
		visual.text = "🔥"
		damage = 14
		applies_burn = true
	else:
		visual.text = "⚡"

	bullet.add_child(visual)
	_add_circle_collision(bullet, 8.0)
	bullet.collision_layer = 0
	bullet.collision_mask = 1

	var gravity_y := 180.0 if applies_gravity else 0.0
	_configure_linear_projectile(
		bullet,
		player,
		Vector2(facing * 350.0, 0.0),
		damage,
		2.0,
		false,
		false,
		gravity_y,
		applies_burn
	)
	bullet.global_position = player.global_position + Vector2(facing * 16.0, -10.0)
	main.add_child(bullet)


static func fire_mage_magic_blast(player: CharacterBody2D, main: Node) -> void:
	var facing := _facing(player)
	_play_sfx(main, "jump")
	_spawn_text(main, "⚡ MAGIC BLAST!", player.global_position, Color.MAGENTA)

	var bullet := _create_circle_area("MageMagicBlast", 10.0, Color(1.0, 0.2, 0.8), Vector2(20, 20))
	_configure_linear_projectile(bullet, player, Vector2(facing * 220.0, 0.0), 25, 3.5, false, true)
	bullet.global_position = player.global_position + Vector2(facing * 16.0, -10.0)
	main.add_child(bullet)


static func throw_boomerang(player: CharacterBody2D, main: Node, combo: String = "") -> void:
	var facing := _facing(player)
	_play_sfx(main, "jump")

	var is_explosive = (combo == "weapon_bomb")
	var text = "💥 EXPLOSIVE BOOMERANG!" if is_explosive else "🪃 BOOMERANG!"
	var color = Color.ORANGE if is_explosive else Color.YELLOW
	_spawn_text(main, text, player.global_position, color)

	var boomerang := _create_circle_area("PlayerBoomerang", 8.0, color, Vector2(16, 16))
	boomerang.set_script(PlayerBoomerangScript)
	boomerang.set("player", player)
	boomerang.set("start_pos", player.global_position)
	boomerang.set("fly_direction", Vector2(facing, -0.2).normalized())
	boomerang.set("damage_val", 25.0 if is_explosive else 15.0)
	boomerang.set("is_explosive", is_explosive)
	boomerang.global_position = player.global_position + Vector2(facing * 16.0, -10.0)
	main.add_child(boomerang)


static func throw_bomb(player: CharacterBody2D, main: Node, combo: String = "") -> void:
	var facing := _facing(player)
	_play_sfx(main, "jump")
	
	var is_paint = (combo == "weapon_paint_gun")
	var text = "🎨 PAINT BOMB!" if is_paint else "💣 BOMB THROWN!"
	var spark_color = Color(0.2, 1.0, 0.2) if is_paint else Color.RED
	_spawn_text(main, text, player.global_position, spark_color)

	var bomb := CharacterBody2D.new()
	bomb.name = "PlayerBomb"
	bomb.collision_layer = 0
	bomb.collision_mask = 1

	var visual := ColorRect.new()
	visual.color = Color.DARK_SLATE_GRAY
	visual.size = Vector2(14, 14)
	visual.position = -visual.size * 0.5
	bomb.add_child(visual)

	var spark := ColorRect.new()
	spark.color = spark_color
	spark.size = Vector2(4, 4)
	spark.position = Vector2(0, -10)
	bomb.add_child(spark)

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	collision.shape = shape
	bomb.add_child(collision)

	bomb.set_script(PlayerBombScript)
	bomb.set("player", player)
	bomb.set("blast_radius", 100.0 if is_paint else 80.0)
	bomb.set("fuse", 2.0)
	bomb.set("is_paint_bomb", is_paint)
	bomb.global_position = player.global_position + Vector2(facing * 16.0, -10.0)
	main.add_child(bomb)


static func fire_paint_projectile(player: CharacterBody2D, main: Node) -> void:
	var facing := _facing(player)
	_play_sfx(main, "jump")

	var projectile := Area2D.new()
	projectile.collision_layer = 1
	projectile.collision_mask = 1
	_add_circle_collision(projectile, 8.0)

	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-8, -4), Vector2(8, -4), Vector2(8, 4), Vector2(-8, 4)
	])
	poly.color = Color(0.2, 1.0, 0.2)
	projectile.add_child(poly)

	projectile.global_position = player.global_position + Vector2(facing * 20.0, -12.0)
	projectile.name = "PaintShot"
	projectile.set_script(PlayerPaintShotScript)
	projectile.set("dir", facing)
	projectile.set("shooter", player)
	main.add_child(projectile)


static func _configure_linear_projectile(
	projectile: Area2D,
	player: CharacterBody2D,
	projectile_velocity: Vector2,
	projectile_damage: int,
	projectile_lifetime: float,
	rotate_to_velocity: bool = false,
	pierce: bool = false,
	gravity_y: float = 0.0,
	applies_burn: bool = false
) -> void:
	projectile.set_script(PlayerLinearProjectileScript)
	projectile.set("shooter", player)
	projectile.set("velocity", projectile_velocity)
	projectile.set("damage", projectile_damage)
	projectile.set("lifetime", projectile_lifetime)
	projectile.set("rotate_to_velocity", rotate_to_velocity)
	projectile.set("pierce", pierce)
	projectile.set("gravity_y", gravity_y)
	projectile.set("applies_burn", applies_burn)


static func _create_circle_area(node_name: String, radius: float, color: Color, size: Vector2) -> Area2D:
	var area := Area2D.new()
	area.name = node_name
	var visual := ColorRect.new()
	visual.color = color
	visual.size = size
	visual.position = -visual.size * 0.5
	area.add_child(visual)
	_add_circle_collision(area, radius)
	area.collision_layer = 0
	area.collision_mask = 1
	return area


static func _add_circle_collision(parent: CollisionObject2D, radius: float) -> void:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	parent.add_child(collision)


static func _closest_enemy(player: CharacterBody2D, main: Node, max_distance: float) -> Node2D:
	var closest_enemy: Node2D = null
	var closest_dist := max_distance
	for child in main.get_children():
		if child.has_method("take_damage") and not child.name.begins_with("Player"):
			var node := child as Node2D
			if node == null:
				continue
			var dist := player.global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_enemy = node
	return closest_enemy


static func _facing(player: CharacterBody2D) -> float:
	return float(player.get("facing_direction"))


static func _play_sfx(main: Node, sfx_type: String) -> void:
	if main.has_method("play_sfx"):
		main.play_sfx(sfx_type)


static func _spawn_text(main: Node, text: String, position: Vector2, color: Color) -> void:
	if main.has_method("spawn_floating_text"):
		main.spawn_floating_text(text, position, color)
