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
- Apply simple snap-to-position assistance.
- Save a clean room JSON payload.
- Ask the Rust backend to launch the runner.

The editor should never expose scripts, file trees, raw metadata, or engine internals to the child.

### Rust Backend

The Rust backend is the bridge between the UI and the file system.

Responsibilities:

- Write `engine/data/game_state.json`.
- Scan `engine/data/assets/**/**.json` sidecars for the toybox.
- Launch the Godot runner when an exported executable exists.
- Later: watch `_Inbox`, unzip packs, slice spritesheets, generate sidecars, route assets.

### Godot Runner

Godot is the reusable 2D runtime.

Responsibilities:

- Read `game_state.json` or a command-line `--level-json` path.
- Resolve each entity's sidecar metadata.
- Spawn physical objects and apply dynamic physics configurations (like presets) on spawn.
- Evaluate runtime game rules and execute custom events (via `RuntimeRuleExecutor.gd`), automatically connecting nearby unlinked switches to gates/doors on load.
- Track and assist player progress, reducing threat levels dynamically when repeated failures occur at a single coordinate (via `RuntimeTutorialWhisperer.gd`).
- Apply gravity, collision, camera, baseline behaviors, and later parallax/lighting/weather/audio.

## Asset Sidecars

Each asset lives in its own folder with its own metadata file.

```text
engine/data/assets/enemies/slime_patrol/
  slime_patrol.json
  slime_patrol.png      # future real art
```

Sidecars are the long-term contract between the ingestor, editor, and runner.

## Why This Beats an Adult Mode

The project should not rely on a hidden adult node editor. Complex behavior must emerge from metadata and placement rules.

Example:

- A red key sidecar declares itself as `logic_signal: key_red`.
- A red door sidecar declares `requires_signal: key_red`.
- The child places both visually.
- The runner links them without menus.

That comes later. Phase 1 only establishes the contract shape.

---

## Codebase Standards & File Size Limits

To maintain modularity and prevent files from becoming unmaintainable:
* **500-Line Limit**: No source file (code, Svelte components, scripts, markup, etc.) should exceed **500 lines** unless absolutely necessary.
* **Decomposition Policy**: Files approaching or exceeding 500 lines must be split/decomposed into smaller, single-responsibility modules, sub-components, or mixins.
