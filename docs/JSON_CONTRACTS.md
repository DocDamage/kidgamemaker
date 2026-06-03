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

This lets the asset ingestor grow without constantly breaking the runner.
