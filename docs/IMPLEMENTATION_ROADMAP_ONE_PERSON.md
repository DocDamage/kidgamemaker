# One-Person Roadmap

## Phase 1 — Contract Runner

Status: started in this package.

Definition of done:

- Editor writes a valid room JSON.
- Godot loads that JSON.
- Player falls, lands on terrain, and moves.
- Enemy patrols.
- Collectible can be picked up.
- Sidecar metadata is read.

## Phase 2 — Real Godot Feel

- Replace placeholder polygons with loaded textures when texture paths exist.
- Add better camera limits and smoothing.
- Add tile/terrain collision merging.
- Add basic checkpoint respawn.
- Add room reset without relaunching editor.

## Phase 3 — Editor Usability

- Drag-to-place instead of click-only stamping.
- Pan/zoom canvas.
- Asset tray loaded from Rust inventory command.
- Visual snap guides.
- Save/load multiple room files.

## Phase 4 — Asset Inbox v1

No AI yet.

- Watch `_Inbox`.
- Unzip packs.
- Copy images/audio/docs into staging folders.
- Generate conservative sidecars from filenames and dimensions.
- Route obvious assets to `heroes`, `terrain`, `enemies`, etc.

## Phase 5 — Sprite Slicing v1

- Alpha threshold scan.
- Connected component bounding boxes.
- Uniform-grid detection.
- Frame export manifest.
- Manual fallback sidecar when confidence is low.

## Phase 6 — Auto Behavior Metadata

- Filename/tag heuristics.
- Light source tagging.
- Collectible tagging.
- Enemy archetype defaults.
- Player archetype defaults.

## Phase 7 — World Linking

- Door/portal stamps.
- Auto-create target room.
- Back/return portal.
- Room streaming in runner.

## Phase 8 — Atmosphere

- CanvasModulate day/night.
- PointLight2D texture support.
- Weather particles.
- Audio zones and jukebox stamps.

## Phase 9 — Export

- Package project data with runner.
- Zip playable build.
- Keep editor separate from exported game.
