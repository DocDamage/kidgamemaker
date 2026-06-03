# One-Person Roadmap & Status

This roadmap outlines the phases of development. All core phases (1 through 9) have been fully implemented and verified on the `main` branch.

---

## Phase 1 — Contract Runner (✅ Complete)

**Implemented files**: `editor/src/App.svelte`, `editor/src-tauri/src/commands.rs`, `engine/scripts/Main.gd`

- **Editor** writes a valid room JSON to the backend.
- **Godot** loads the room JSON dynamically.
- **Player** falls, lands on terrain, and moves left/right/jumps.
- **Enemy** patrols and turns around at edges.
- **Collectible** is picked up and triggers score accumulation.
- **Sidecar metadata** is resolved for each asset type.

---

## Phase 2 — Real Godot Feel (✅ Complete)

**Implemented files**: `engine/scripts/Main.gd`, `engine/scripts/PlayerController.gd`

- **Textures** load from paths when present in sidecar files.
- **Camera limits** and smooth interpolation are applied.
- **Tile collision merging** combines terrain shapes to prevent player sticking.
- **Checkpoint respawning** handles recovery without restarting.
- **Room reset** works without relaunching the Godot application.

---

## Phase 3 — Editor Usability (✅ Complete)

**Implemented files**: `editor/src/App.svelte`, `editor/src/lib/canvasState.ts`, `editor/src/ToyboxModal.svelte`

- **Drag-to-place** support added for paint-brush stamping.
- **Pan/zoom** controls added via mouse gestures and keyboard inputs.
- **Asset tray** populated dynamically from Rust command queries.
- **Snapping alignment** aids placing tiles cleanly on a 32px or 64px grid.
- **Multi-room** save and load capabilities fully supported.

---

## Phase 4 — Asset Inbox v1 (✅ Complete)

**Implemented files**: `editor/src-tauri/src/inbox.rs`, `editor/src-tauri/src/commands.rs`

- **`_Inbox/` folder** watched on a 5-second background daemon.
- **ZIP archives** unpacked automatically.
- **Staging routing** filters images, audio, and documents into correct categories (`heroes`, `terrain`, `enemies`, `collectibles`, `portals`, `decorations`, `audio`).
- **Initial sidecar generation** automatically formats layout contracts.

---

## Phase 5 — Sprite Slicing v1 (✅ Complete)

**Implemented files**: `editor/src-tauri/src/slicer.rs`, `editor/src-tauri/src/inbox.rs`

- **Alpha threshold scanner** identifies empty/transparent space.
- **Connected component BFS** algorithm groups non-empty pixels into sprite sheets.
- **Uniform grid detection** automatically formats tile lists.
- **Frame manifest creation** matches exported tiles.
- **Automatic Toybox refreshing** polls and updates the Svelte canvas assets within 5 seconds.

---

## Phase 6 — Auto Behavior Metadata (✅ Complete)

**Implemented files**: `editor/src-tauri/src/inbox.rs`

- **Heuristic matching** parses filenames/tags to determine roles.
- **Light source tagging** detects names like `torch`, `lamp`, `fire` to enable dynamic lighting.
- **Collectible tagging** maps names like `coin`, `ruby`, `heart` to score/heal effects.
- **Archetype defaults** assign speeds, scale values, and health levels for players and enemies.

---

## Phase 7 — World Linking (✅ Complete)

**Implemented files**: `editor/src/App.svelte`, `engine/scripts/Main.gd`

- **Portal stamps** placed visually on canvas.
- **Target rooms** created automatically for portals if not present.
- **Bidirectional portal links** connect portals back and forth.
- **In-game transitions** stream and switch rooms instantly inside the Godot runner.
- **Key-door gates** require the player to collect matching keys before doors unlock.

---

## Phase 8 — Atmosphere (✅ Complete)

**Implemented files**: `engine/scripts/Main.gd`

- **`CanvasModulate`** tints screen for morning, afternoon, sunset, and night times of day.
- **`PointLight2D`** attached automatically to light-emitting assets.
- **Weather particle systems** simulate rain and snow dynamically based on room settings.
- **Music/SFX channels** play ambient tracks and trigger spatial effects.

---

## Phase 9 — Projects and Export (✅ Complete)

**Implemented files**: `editor/src/BookshelfModal.svelte`, `editor/src-tauri/src/commands.rs`

- **Visual Bookshelf** lists projects and load settings.
- **Canvas minimap thumbnails** saved locally for visual preview.
- **Auto-save system** saves work every 60 seconds automatically.
- **Project exporter** packages runner, data files, and asset configurations into a portable zip bundle.

---

## Next Steps / Remaining Work

1. **Runner Compilation**: Build and export `engine/` to a native `Runner.exe` in Godot 4.
2. **Artwork**: Replace stub images with actual pixel-art spritesheets via `_Inbox/`.
3. **HUD**: Create a visual Godot interface layer to display current score and player health.
