extends Node2D
## RuntimeVisualProgression
##
## Attach as a child of the player node.
## Listens for "enemy_defeated" signals from Main and advances the player's
## visual tier without any numbers or words visible to the child.
##
## Tier thresholds (enemy defeats):
##   0  — pristine      original scale, no aura
##   3  — seasoned      scale ×1.08, faint white shimmer
##   6  — veteran       scale ×1.15, bronze shimmer particles
##   10 — champion      scale ×1.22, silver shimmer particles
##   15 — legend        scale ×1.30, gold aura + outline glow, evolution burst
##
## Each tier transition plays a brief "growth pulse" tween so the change
## feels rewarding but not distracting.

const TIER_THRESHOLDS := [0, 3, 6, 10, 15]
const TIER_SCALES     := [1.0, 1.08, 1.15, 1.22, 1.30]
const TIER_NAMES      := ["pristine", "seasoned", "veteran", "champion", "legend"]
const TIER_AURA_COLORS := [
	Color(1.0, 1.0, 1.0, 0.0),   # pristine  — no aura
	Color(1.0, 1.0, 1.0, 0.35),  # seasoned  — faint white
	Color(0.82, 0.55, 0.22, 0.55), # veteran   — bronze
	Color(0.85, 0.90, 0.95, 0.65), # champion  — silver
	Color(1.0, 0.88, 0.20, 0.80),  # legend    — gold
]

var _defeat_count: int = 0
var _current_tier: int = 0
var _aura_particles: CPUParticles2D = null
var _player_sprite: Node2D = null  # set in _ready after finding the sprite child


func _ready() -> void:
	# Find the sprite child (first Sprite2D or AnimatedSprite2D)
	var parent := get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			_player_sprite = child
			break

	_build_aura_emitter()
	_apply_tier(0, false)


func on_enemy_defeated() -> void:
	## Call from Main when any enemy dies, passing the player that defeated it.
	_defeat_count += 1
	var new_tier := _tier_for_count(_defeat_count)
	if new_tier != _current_tier:
		_advance_to_tier(new_tier)


func _tier_for_count(count: int) -> int:
	var tier := 0
	for i in range(TIER_THRESHOLDS.size()):
		if count >= TIER_THRESHOLDS[i]:
			tier = i
	return tier


func _advance_to_tier(new_tier: int) -> void:
	_current_tier = new_tier
	_apply_tier(new_tier, true)


func _apply_tier(tier: int, animate: bool) -> void:
	var parent := get_parent()
	if parent == null or not is_instance_valid(parent):
		return

	var target_scale: float = float(TIER_SCALES[tier])
	var aura_color: Color = TIER_AURA_COLORS[tier]

	if animate:
		# Growth pulse tween — expand → contract → settle
		var base_s: Vector2 = Vector2.ONE * target_scale
		var tween := create_tween()
		tween.tween_property(parent, "scale",
			Vector2.ONE * target_scale * 1.45, 0.12).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(parent, "scale",
			Vector2.ONE * target_scale * 0.9, 0.10).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(parent, "scale", base_s, 0.12).set_trans(Tween.TRANS_SPRING)

		# Burst of sparkle particles at tier transition
		_burst_sparkle(aura_color, tier)

		# Announce via floating text (emoji only — no numbers)
		var main := get_tree().get_root().get_node_or_null("Main")
		if main != null and main.has_method("spawn_floating_text"):
			var emoji := _tier_emoji(tier)
			main.spawn_floating_text(emoji, parent.global_position + Vector2(0, -48),
				aura_color if aura_color.a > 0.1 else Color.WHITE)
	else:
		parent.scale = Vector2.ONE * target_scale

	# Update continuous aura emitter
	if _aura_particles != null and is_instance_valid(_aura_particles):
		_aura_particles.color = aura_color
		_aura_particles.emitting = aura_color.a > 0.05


func _build_aura_emitter() -> void:
	_aura_particles = CPUParticles2D.new()
	_aura_particles.name = "ProgressionAura"
	_aura_particles.amount = 8
	_aura_particles.lifetime = 0.9
	_aura_particles.direction = Vector2.UP
	_aura_particles.gravity = Vector2.ZERO
	_aura_particles.initial_velocity_min = 15.0
	_aura_particles.initial_velocity_max = 30.0
	_aura_particles.scale_amount_min = 2.0
	_aura_particles.scale_amount_max = 4.0
	_aura_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_aura_particles.emission_sphere_radius = 14.0
	_aura_particles.color = Color(1, 1, 1, 0)
	_aura_particles.emitting = false
	_aura_particles.z_index = -1
	add_child(_aura_particles)


func _burst_sparkle(color: Color, tier: int) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var burst := CPUParticles2D.new()
	burst.name = "TierBurst"
	burst.one_shot = true
	burst.emitting = true
	burst.amount = 12 + tier * 4
	burst.lifetime = 0.7
	burst.direction = Vector2.UP
	burst.spread = 180.0
	burst.gravity = Vector2(0, -60)
	burst.initial_velocity_min = 60.0
	burst.initial_velocity_max = 140.0
	burst.scale_amount_min = 3.0
	burst.scale_amount_max = 6.0
	burst.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	burst.emission_sphere_radius = 10.0
	burst.color = color if color.a > 0.1 else Color.WHITE
	burst.z_index = 10
	parent.add_child(burst)
	get_tree().create_timer(1.2).timeout.connect(func():
		if is_instance_valid(burst):
			burst.queue_free()
	)


func _tier_emoji(tier: int) -> String:
	match tier:
		1: return "✨"
		2: return "🥉"
		3: return "🥈"
		4: return "🏆✨"
		_: return "✨"
