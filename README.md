# KidGameMaker

KidGameMaker is a contract-first, zero-code side-scrolling game maker aimed at a child-facing editor with a real 2D runtime underneath it.

The child never sees code, file structures, sprite slicing tools, import settings, node graphs, or build systems. They place visual stamps, press Play, and the engine handles the rest.

## Architecture

```text
Svelte UI → Tauri IPC → Rust backend → JSON files → Godot runner
```

## Phase Completion Status

| Phase | Goal | Status |
|---|---|---|
| 0 | Repo and toolchain | ✅ Done |
| 1 | Godot JSON runner | ✅ Done |
| 2 | Tauri bridge | ✅ Done |
| 3 | Child-facing canvas MVP | ✅ Done |
| 4 | Sidecar-driven Toybox | ✅ Done |
| 5 | Asset ingestion (_Inbox watcher, slicing) | ✅ Done |
| 6 | Smart placement (snap, parallax, z-index) | ✅ Done |
| 7 | Basic gameplay rules | ✅ Done |
| 8 | Atmosphere (day/night, weather, lighting, music) | ✅ Done |
| 9 | Projects and export | ✅ Done |

## What is implemented

- **Editor canvas**: Mario Maker-style stamp ribbon + Toybox modal, erase by instance_id, drag-paint, pan/zoom, grid snap
- **World settings**: time-of-day (day/morning/sunset/night) and weather (clear/rain/snow) dropdowns wired into the saved JSON
- **Multi-room**: save, load, list, delete rooms; Bookshelf picker with mini-map thumbnails
- **Auto-save**: saves current room every 60 seconds automatically
- **Toybox auto-refresh**: polls for new assets from `_Inbox` every 5 seconds
- **Godot runner**: reads `game_state.json`, spawns all entity types, applies physics
- **Player**: move, jump, gravity, `heal()`, `take_damage()` with invincibility frames
- **Enemies**: patrol with ledge detection, damage hitbox, boss mode (scale + speed)
- **Collectibles**: score pickup, health pickup, pop-and-fade tween animation
- **Key-door system**: gold key collectibles unlock locked_door portals (color-tagged)
- **Checkpoints**: override respawn point on touch
- **Portals**: bidirectional room linking via `target_room` / `target_portal` modifiers
- **Day/night**: `CanvasModulate` transitions based on `time_of_day`
- **Weather**: rain and snow `GPUParticles2D` systems driven by room JSON
- **Lighting**: `PointLight2D` auto-attached to torches, fires, lanterns
- **Music/SFX**: `AudioStreamPlayer` spawned from sidecar `audio_logic`
- **Asset ingestion**: drop PNG or ZIP into `_Inbox/` → BFS sprite slicing → sidecar JSON → Toybox auto-refresh
- **Sprite slicing**: uniform grid + connected-component BFS with confidence scoring
- **Export**: zip current project + used assets + runner JSON

## Repo layout

```text
/kidgamemaker
├── editor/                   # Svelte + Tauri desktop editor
│   ├── src/
│   │   ├── App.svelte         # Main canvas editor
│   │   ├── ToyboxModal.svelte # Asset picker modal
│   │   ├── BookshelfModal.svelte # Room/project picker with thumbnails
│   │   └── lib/canvasState.ts # Shared types and state helpers
│   └── src-tauri/src/
│       ├── commands.rs        # All Tauri IPC commands
│       ├── inbox.rs           # _Inbox watcher + asset classification
│       ├── slicer.rs          # PNG sprite sheet slicer
│       └── lib.rs             # Tauri setup
├── engine/                   # Godot 4 runner
│   ├── scripts/
│   │   ├── Main.gd            # Entity spawning, room loading, gameplay systems
│   │   ├── PlayerController.gd
│   │   ├── SmartEnemy.gd
│   │   └── Collectible.gd
│   └── data/
│       ├── dummy_level.json   # Example room for testing the runner standalone
│       └── assets/            # Sidecar JSON folders per asset
├── _Inbox/                   # Drop assets here for auto-ingestion
└── docs/                     # Architecture and roadmap
```

## Local Start

### Editor

```powershell
cd editor
npm install
npm run tauri:dev
```

The editor loads the Toybox from `engine/data/assets/`. Pressing Play writes `engine/data/game_state.json`.

### Godot Runner

Open `engine/project.godot` in Godot 4.x and run the main scene.

To test a JSON file after exporting a runner binary:

```powershell
.\engine\Runner.exe --level-json .\engine\data\game_state.json
```

### Adding assets

Drop any `.png`, `.wav`, `.ogg`, or `.zip` into `_Inbox/`. The Rust backend classifies, slices (for sprites), generates a sidecar JSON, and moves the asset to the correct `engine/data/assets/<category>/` folder. The Toybox refreshes automatically within 5 seconds.

## Key-door system

- Place a **Gold Key** collectible → player picks it up silently
- Place a **Locked Door** portal → flashes red if player has no key, opens (with a scale tween) and optionally links to another room if the player has one
- Key colors (`gold`, `red`, `blue`, `silver`) are matched by tag — e.g., `red_locked_door.png` requires a `red_key`

## Still to do

- Build and export `engine/` in Godot 4 → `Runner.exe` (manual Godot step)
- Real pixel-art sprite assets (current PNGs are 1×1 stubs)
- HUD overlay (score, hearts) rendered in Godot
- Published installer / app bundle
