# Gemini Plan Digest

## What Gemini got right

The useful core of the conversation is the **data-driven runtime** idea. The app should not compile a new game binary every time the child hits Play. The editor should write a room/world JSON file, then launch a pre-built Godot runner that reads that JSON and spawns the game.

The right stack is:

```text
Svelte UI → Tauri IPC → Rust backend → JSON files → Godot runner
```

The right repo layout is:

```text
/kidgamemaker
├── editor/     # Svelte + Tauri child-facing editor
├── engine/     # Godot runner
├── docs/       # architecture and JSON contracts
└── .github/    # CI
```

The right asset design is **sidecar JSON per asset**, not one massive global database.

The right UX is **Mario Maker-style stamping**, not a normal game engine editor.

## What needs correction

Gemini kept implying AI can reliably infer complex game design intent from placement alone. That is only partly true.

The engine can safely automate:
- key opens matching colored door
- big enemy becomes boss candidate
- player/enemy gravity snapping
- terrain edge snapping
- torch emits light
- placed jukebox controls area music
- checkpoint overrides respawn point
- background asset goes to parallax layer

The engine should **not** rely on AI as the first-pass source of truth for:
- automatic animation naming
- boss arena design
- full Metroidvania progression validation
- NPC daily routines
- room-to-room pacing
- puzzle solvability

Those need deterministic rules first, AI hints second.

## Correct build order

1. **Godot runner proof**
   - Load `dummy_level.json`.
   - Spawn player and terrain.
   - Attach camera.
   - Apply gravity and movement.

2. **Tauri bridge**
   - Svelte button sends a dummy room payload.
   - Rust writes `engine/data/game_state.json`.
   - Rust launches Godot with `--level-json`.

3. **Svelte canvas**
   - Flat `currentRoomState` array.
   - Stamp entities onto canvas.
   - Eraser deletes by `instance_id`.
   - Toybox reads asset inventory from Rust.

4. **Asset sidecars**
   - Use hand-authored sidecars first.
   - Then build the Rust ingestor to generate them.

5. **Asset ingestion**
   - Watch `_Inbox`.
   - Unzip packs.
   - Parse images/audio/docs.
   - Generate sidecar JSON.
   - Route assets into category folders.

6. **Automation systems**
   - Snap rules.
   - Parallax buckets.
   - Audio triggers.
   - Lighting metadata.
   - Checkpoints.
   - Doors/keys.
   - Boss candidates.
   - Weather inference.

7. **Advanced child UX**
   - Bookshelf project manager.
   - Auto-thumbnails.
   - Drop-in ghost testing.
   - Publish/export zip.

## MVP definition

The MVP is successful when:

- The child can pick a hero, floor, enemy, coin, door, and background.
- The child can stamp them freely on a canvas.
- The child can press Play.
- Godot opens a playable room from JSON.
- The player can move, jump, collide with ground, and follow the camera.
- Assets are loaded from sidecar JSON.
- No code is visible to the child.

Anything beyond that is Phase 2+.


---

# Architecture

## Product goal

KidGameMaker is a native desktop side-scrolling game maker for a young child. The child never sees code, file structures, sprite slicing tools, import settings, node graphs, or build systems. They place visual stamps, press Play, and the engine handles the rest.

The system still needs enough depth to eventually support games with:
- platforming
- Metroidvania gates
- rooms/worlds
- multiple heroes
- enemies
- collectibles
- checkpoints
- lighting
- parallax
- weather
- day/night
- NPC routines
- background music
- spatial sound effects
- project saving/exporting

## System overview

```text
┌─────────────────────────────────────────────────────────────┐
│ Editor: Svelte UI inside Tauri                              │
│ - Mario Maker-style stamp ribbon                            │
│ - Toybox modal                                               │
│ - Freeform canvas with magnetic snapping                     │
│ - Bookshelf project picker                                   │
│ - Big Play button                                            │
└───────────────────────────┬─────────────────────────────────┘
                            │ Tauri invoke()
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Rust backend                                                 │
│ - Receives canvas state                                      │
│ - Writes game_state.json                                     │
│ - Scans asset sidecars                                       │
│ - Watches _Inbox                                             │
│ - Unzips asset packs                                         │
│ - Slices sprite sheets                                       │
│ - Generates metadata                                         │
│ - Launches Godot runner                                      │
└───────────────────────────┬─────────────────────────────────┘
                            │ JSON contract
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Godot runner                                                 │
│ - Reads game_state.json                                      │
│ - Reads sidecar JSON                                         │
│ - Spawns nodes                                               │
│ - Applies physics                                            │
│ - Applies camera/parallax                                    │
│ - Applies lighting/audio/weather/checkpoints/gates           │
└─────────────────────────────────────────────────────────────┘
```

## Repo structure

```text
/kidgamemaker
├── editor/
│   ├── src/
│   │   ├── App.svelte
│   │   ├── ToyboxModal.svelte
│   │   └── lib/
│   │       └── canvasState.ts
│   └── src-tauri/
│       └── src/
│           ├── lib.rs
│           └── commands.rs
├── engine/
│   ├── project.godot
│   ├── scenes/
│   ├── scripts/
│   │   ├── Main.gd
│   │   ├── PlayerController.gd
│   │   └── SmartEnemy.gd
│   └── data/
│       ├── dummy_level.json
│       └── assets/
│           ├── heroes/
│           ├── terrain/
│           ├── enemies/
│           ├── collectibles/
│           ├── backgrounds/
│           ├── portals/
│           ├── decorations/
│           └── audio/
├── docs/
└── .github/workflows/
```

## Core data flow

1. User stamps assets in the Svelte canvas.
2. Svelte stores a flat array of placed entities.
3. User presses Play.
4. Svelte calls Rust through `invoke("compile_and_play")`.
5. Rust writes the payload to `engine/data/game_state.json`.
6. Rust launches Godot and passes the JSON file path.
7. Godot reads the JSON, loads matching asset sidecars, and spawns gameplay objects.

## Why Godot runner instead of custom runtime

Use Godot for the runner because the project needs strong 2D support quickly:
- `FileAccess` reads/writes runtime data files.
- `JSON` parses the game-state contract.
- `CharacterBody2D` is built for controlled 2D player/enemy motion.
- `Camera2D` handles side-scrolling camera movement.
- Static/dynamic/area physics nodes are already mature.
- 2D lights, particles, audio, and animation tools are built in.

The Rust backend should handle ingestion and orchestration, not reinvent the game engine.

## Why Tauri/Svelte

Tauri gives native file-system access and a Rust backend while keeping the child UI built with web technology. Svelte is a good fit for the bouncy, low-friction, animated interface because it compiles to small direct DOM updates and keeps state simple.

## Rule of thumb

The editor records **what the child placed**.

The Rust backend decides **what files and metadata exist**.

The Godot runner decides **how it plays**.


---

# Implementation Roadmap for a One-Person Team

## Principle

Do not build the whole dream first. Build a thin playable vertical slice, then expand one system at a time.

The first playable version should look boring internally but prove the architecture.

## Phase 0 — Repo and toolchain

Goal: Make the repo usable.

Tasks:
- Clone `https://github.com/DocDamage/kidgamemaker.git`.
- Create `editor/`, `engine/`, `docs/`, and `.github/workflows/`.
- Scaffold Tauri + Svelte in `editor/`.
- Create a Godot 4 project in `engine/`.
- Add this starter documentation.
- Commit the baseline.

Done when:
- Repo has the monorepo folders.
- `npm install` works in `editor/`.
- Godot opens `engine/project.godot`.

## Phase 1 — Godot JSON runner

Goal: Prove `dummy_level.json` can become a playable room.

Tasks:
- Attach `scripts/Main.gd` to a `Node2D` named `Main`.
- Add `scripts/PlayerController.gd`.
- Add `data/dummy_level.json`.
- Add hand-authored sidecars for `hero_knight` and `stone_floor`.
- Spawn placeholders if sprites do not exist yet.

Done when:
- Player spawns.
- Floor spawns.
- Player falls and lands.
- Camera follows player.
- Console shows which JSON file loaded.

## Phase 2 — Tauri bridge

Goal: Prove the editor can launch the runner.

Tasks:
- Add Rust command `compile_and_play`.
- Add Rust command `get_asset_inventory`.
- Add a Svelte Play button.
- Send dummy room payload from Svelte to Rust.
- Rust writes `engine/data/game_state.json`.
- Rust launches Godot with `--level-json`.

Done when:
- Clicking Play writes JSON.
- Godot starts with the generated room payload.
- If Godot runner is missing, Rust returns a clean message instead of crashing.

## Phase 3 — Child-facing canvas MVP

Goal: Basic Mario Maker-style stamping.

Tasks:
- Implement quick ribbon with 5–7 active stamps.
- Implement Toybox modal.
- Use a flat `PlacedEntity[]` array.
- Click canvas to stamp.
- Eraser removes by `instance_id`.
- Press Play to run current canvas.

Done when:
- A non-technical user can place hero/floor/enemy/collectible/background.
- The payload produced by the UI matches `room_state.schema.json`.

## Phase 4 — Sidecar-driven toybox

Goal: Rust populates the editor from asset folders.

Tasks:
- Scan `engine/data/assets/<category>/<asset_id>/<asset_id>.json`.
- Return inventory grouped by category.
- Display assets in Toybox.
- Slot selected asset into quick ribbon.

Done when:
- Adding a new hand-authored sidecar makes it appear in the Toybox without code changes.

## Phase 5 — Deterministic asset ingestion

Goal: First real backend value.

Tasks:
- Create `_Inbox`.
- Watch for dropped files.
- Unzip archives.
- Copy supported files into staging.
- Detect image/audio/doc types.
- For PNG sprites, run alpha-threshold connected-component slicing.
- Generate initial sidecar JSON.
- Route to category folders.

Done when:
- Dropping a simple transparent PNG sheet produces sliced frames and a sidecar.
- Dropping an audio file creates an audio sidecar.
- The Toybox refreshes.

## Phase 6 — Smart placement

Goal: Hide complexity without lying to the user.

Tasks:
- Edge snapping for terrain.
- Gravity snapping for players/enemies/checkpoints.
- Surface/socket snapping for torches/signs/decorations.
- Parallax bucket assignment.
- Z-index assignment.

Done when:
- Child can place assets freely and they still land cleanly.

## Phase 7 — Basic gameplay rules

Goal: Make levels feel like games.

Tasks:
- Collectibles.
- Damage.
- Respawn at hero start.
- Checkpoint override.
- Door/portal room linking.
- Key-door matching by tags.
- Enemy patrol.
- Basic boss candidate behavior for huge enemies.

Done when:
- A small two-room game can be built and completed.

## Phase 8 — Atmosphere

Goal: Make rooms feel premium.

Tasks:
- CanvasModulate day/night.
- PointLight2D attachment for light-emitting sidecars.
- Weather particles from room/theme tags.
- Jukebox/music block zones.
- Spatial SFX anchors.
- Dynamic boss music override.

Done when:
- A torch lights a dark room.
- A placed music block changes the track.
- A boss overrides the current music.

## Phase 9 — Projects and export

Goal: Make it usable as a real product.

Tasks:
- Visual Bookshelf.
- Auto-thumbnail saves.
- New world button with generated names.
- Auto-save.
- Project folder copy/export.
- Publish zip with runner + used assets + JSON.

Done when:
- Child can maintain more than one game.
- A playable game zip can be created.

## Do not start with

- AI vision classification
- Full NPC routines
- Full Metroidvania progression analyzer
- Procedural world generation
- Published installers
- Full sprite rigging/animation editor

Those are later systems. Starting there will bury the MVP.
