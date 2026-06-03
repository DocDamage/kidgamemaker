# KidGameMaker

KidGameMaker is a contract-first, zero-code side-scrolling game maker aimed at a child-facing editor with a real 2D runtime underneath it.

The Phase 1 build proves the core loop:

1. The editor lets the user stamp heroes, terrain, enemies, collectibles, and decorations on a canvas.
2. The editor writes a clean `game_state.json` room contract.
3. The Godot runner reads that JSON and spawns physical gameplay objects.
4. The Rust/Tauri backend bridges the editor and runner without exposing implementation details to the child.

This repo is intentionally starting small. Do not build the AI asset ingestor first. The runner contract must exist first so the ingestor has a strict target to generate.

## Phase 1 Layout

```text
.github/workflows/ci.yml              Basic schema/script validation
docs/                                 Architecture and one-person roadmap
editor/                               Svelte + Tauri desktop editor scaffold
engine/                               Godot JSON-driven runner scaffold
tools/                                Local helper scripts
```

## Local Start

### Editor

```powershell
cd editor
npm install
npm run tauri:dev
```

The editor can run before a Godot export exists. Pressing Play will write `engine/data/game_state.json`. If a Godot runner executable is found later, the backend will launch it.

### Godot Runner

Open `engine/project.godot` in Godot 4.x and run the main scene. The runner loads `engine/data/dummy_level.json` by default.

To test a JSON file explicitly after exporting a runner:

```powershell
.\engine\Runner.exe --level-json .\engine\data\game_state.json
```

## Current Scope

Implemented in this starter:

- JSON room contract
- Asset sidecar examples
- Child-facing stamp canvas scaffold
- Rust command to write `game_state.json`
- Godot runtime loader
- Placeholder player, terrain, enemy, collectible, decoration spawning
- Basic gravity/player movement
- Basic enemy patrol
- Checkpoint and light metadata reserved in the contract

Not implemented yet:

- Real sprite slicing
- AI classification
- ZIP ingestion daemon
- real parallax nodes
- weather particles
- day/night lighting transitions
- room linking/world map
- exported game packaging

Those come after the contract-first runner loop is proven.
