# JSON Contracts

## Room Contract

`engine/data/game_state.json` and `engine/data/dummy_level.json` use this shape. New editor saves use schema `"2.0.0"` and include Phase A sidecar blocks; legacy schema `1` rooms still load and the runner fills the Phase A defaults in memory.

```json
{
  "schema_version": "2.0.0",
  "project_id": "demo_project",
  "room_id": "test_chamber_01",
  "world_settings": {
    "time_of_day": "day",
    "weather": "clear",
    "level_balancer_enabled": true,
    "tutorial_whisperer_enabled": true
  },
  "movement_system": {
    "_meta": {
      "feature_domain": "movement_system",
      "minimum_schema_version": "2.0.0"
    },
    "enabled": true,
    "movement_ids": ["wall_jump", "double_jump", "dash", "glide", "ledge_grab", "ground_pound"],
    "params": {
      "dash_cooldown_seconds": 1.2,
      "dash_duration_seconds": 0.2,
      "wall_cling_seconds": 0.3,
      "glide_stamina_seconds": 4.0,
      "ground_pound_speed": 900
    }
  },
  "combat_system": {
    "_meta": {
      "feature_domain": "combat_system",
      "minimum_schema_version": "2.0.0"
    },
    "enabled": true,
    "mechanics": ["sword_combo", "charge_shot", "parry", "shield_block"],
    "params": {
      "combo_steps": 3,
      "combo_reset_seconds": 1.0,
      "parry_window_seconds": 0.18,
      "charge_shot_full_seconds": 1.0
    }
  },
  "rules_engine": {
    "_meta": {
      "feature_domain": "rules_engine",
      "minimum_schema_version": "2.0.0"
    },
    "enabled": true,
    "primitives": ["switch_door", "key_lock", "pressure_plate", "collectible_counter", "win_condition"]
  },
  "ai_assist": {
    "_meta": {
      "feature_domain": "ai_assist",
      "minimum_schema_version": "2.0.0"
    },
    "level_balancer": true,
    "tutorial_whisperer": true
  },
  "entities": [
    {
      "instance_id": "hero_001",
      "asset_id": "hero_knight",
      "category": "heroes",
      "type": "player",
      "position": { "x": 120, "y": 220 },
      "is_camera_target": true,
      "modifiers": {
        "variant": "default",
        "scale_multiplier": 1.0,
        "physics_preset": "kidfriendly"
      }
    }
  ]
}
```

## Sidecar Contract

Every sidecar should include at least:

```json
{
  "schema_version": 1,
  "asset_id": "stone_floor",
  "asset_name": "Stone Floor",
  "category": "terrain",
  "runtime_template": "terrain",
  "visual": "🪨",
  "placement_logic": {
    "snapping_type": "edge_to_edge",
    "parallax_bucket": "play_layer"
  },
  "collision": {
    "shape": "rectangle",
    "size": [128, 32]
  }
}
```

## Runtime Templates

The Godot runner currently recognizes:

- `player`
- `terrain`
- `enemy`
- `collectible`
- `decoration`
- `checkpoint`

Unknown templates spawn as decorations instead of crashing.

## Reserved Metadata Blocks

These are intentionally part of the contract now, even when the runtime behavior is still incomplete:

- `baseline_attributes`
- `implicit_abilities`
- `placement_logic`
- `lighting_logic`
- `audio_logic`
- `gameplay_logic`
- `animation_data`
- `logic_signals`

Top-level Phase A blocks are also reserved:

- `movement_system`
- `combat_system`
- `rules_engine`
- `ai_assist`

This lets the asset ingestor grow without constantly breaking the runner.
