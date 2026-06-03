# Architecture

## Core Decision

KidGameMaker uses a data-driven runtime.

The editor does not generate code. The editor produces JSON. The Godot runner consumes JSON.

```text
Svelte/Tauri Editor
        |
        | writes game_state.json
        v
Godot Runner
        |
        | reads asset sidecars
        v
Playable side-scrolling room
```

## Components

### Editor

The editor is a native desktop shell using Tauri with a Svelte frontend.

Responsibilities:

- Show a large child-friendly canvas.
- Show toybox/stamp assets.
- Apply grid snap-to-position assistance.
- Save a clean room JSON layout payload.
- Automatically save state (every 60s) and track projects via the Bookshelf room manager.
- Call the Rust backend to save files, load visual thumbnails, and run the Godot runner.

The editor never exposes scripts, file trees, raw metadata, or engine internals to the child.

### Rust Backend

The Rust backend is the bridge between the UI and the file system.

Responsibilities:

- Write and load room JSON configurations (`save_room`, `load_room`, etc.).
- Scan `engine/data/assets/**/**.json` sidecars to supply the Toybox inventory.
- Run a background directory watcher on `_Inbox/` to extract archives, slice sheets, and classify textures/audio.
- Launch the Godot runner (or an exported `Runner.exe` executable).

### Godot Runner

Godot is the reusable 2D runtime.

Responsibilities:

- Read `game_state.json` or a command-line `--level-json` path.
- Resolve each entity's sidecar metadata.
- Spawn physical objects dynamically.
- Apply gravity, collision bounds, camera boundaries, and checkpoint respawning.
- Manage atmospheric effects (day/night tints, weather particles, ambient sound/music loops).
- Stream transitions between rooms via portals.

## Asset Sidecars

Each asset lives in its own folder with its own metadata file.

```text
engine/data/assets/enemies/slime_patrol/
  slime_patrol.json
  slime_patrol.png
```

Sidecars are the long-term contract between the ingestor, editor, and runner.

## Behavior Emergence

The project does not rely on a hidden adult node editor. Complex behavior emerges from metadata and placement rules.

Example:

- A key asset declares itself in sidecar metadata as a `key_collectible`.
- A door portal asset declares itself as `locked_door`.
- The child places both visually.
- The runner links them by color tags without any UI scripting menus required.
