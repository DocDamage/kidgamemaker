# JSON Contracts

## Room Contract

`engine/data/game_state.json` and `engine/data/dummy_level.json` use this shape:

```json
{
  "schema_version": 1,
  "project_id": "demo_project",
  "room_id": "test_chamber_01",
  "world_settings": {
    "time_of_day": "day",
    "weather": "clear"
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
        "scale_multiplier": 1.0
      }
    }
  ]
}
```

## Sidecar Contract

Every sidecar includes at least:

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

The Godot runner recognizes the following `runtime_template` types:

- `player` — Controlled character movement.
- `terrain` — Static terrain blocks. Multiple adjacent blocks merge collision shapes automatically for optimized collision.
- `enemy` — Patrolling enemies with ledge detection. Archetypes with health thresholds above 100 trigger boss mode (increasing scale and speed).
- `collectible` — Score pickups (e.g. `score_value`) or health pickups (e.g. `heal_value`).
- `key_collectible` — Key items used to open locks (color-matched via `key_color`).
- `portal` — Link gates that stream new level JSON files upon contact.
- `locked_door` — Color-matched portal blocks requiring a key of the corresponding color to pass.
- `checkpoint` — Active checkpoint zones that override the player respawn coordinates.
- `decoration` — Decorative visual items with no collision logic.

Unknown templates spawn as decorations instead of crashing the runner.

## Reserved Metadata Blocks

These sections of the sidecar contracts enable advanced gameplay rules:

- `baseline_attributes` — Health, movement speeds, damage values, jump force, gravity scales.
- `gameplay_logic` — Properties defining keys (`key_color`), score values (`score_value`), health recovery values (`heal_value`), and locks (`requires_key`, `key_color`).
- `placement_logic` — Parallax layering and canvas alignment behaviors.
- `lighting_logic` — Configures torches, fires, or lanterns to automatically cast dynamic PointLight2D instances.
- `audio_logic` — Dictates sound triggers or ambient loop streaming.
