# 🧸 KidGameMaker

`KidGameMaker` is a contract-first, zero-code game creation suite designed for young children (ages 5+). Children can design 2D platforming adventures using simple visual stamp brushes and play them instantly, with all the heavy lifting hidden behind a magical, intuitive interface.

---

## 🎨 Modern Architecture

The suite splits game design and execution into three decoupled, secure components:

```mermaid
graph TD
    A[Svelte 5 UI Client] <-->|Tauri IPC Invokes| B[Rust Desktop Engine]
    B <-->|Asset Sync / Save Files| C[Local Storage & JSON Rooms]
    B -->|Tauri process spawn| D[Godot 4 Runner]
    D -->|Parses Level Settings| C
    E[Inbox Daemon Thread] -->|Asset Drop Ingestion| B
```

* **Editor Frontend**: Built with Svelte 5, TypeScript, and custom CSS. Handles placing toys, canvas panning/zooming, and rules customization.
* **Tauri Desktop Wrapper**: Integrates the Svelte frontend with local system resources using Tauri v2.
* **Rust Backend**: Manages file operations, folder-watching ingestion, connected-components sprite slicing, and packaging.
* **Godot Runner**: A 2D game runner written in GDScript. Reads `game_state.json`, translates physics vectors, parses rule events, and handles inputs.

---

## 🚀 Features

### 🛠️ Editor & Canvas
* **Drag-Paint Placement**: Drag stamps smoothly across the canvas to paint platforms, hazards, or collectibles.
* **Long-Press Repositioning**: Click and drag placed elements directly on the canvas to realign them.
* **Bookshelf Room Picker**: An interface to manage multiple rooms complete with mini-map rendering preview cards.
* **Undo/Redo History Stack**: Save/restore canvas states on the fly to undo mistakes.
* **Toybox Favorites**: Star (`🤍`/`❤️`) toys to pin them on a quick-select favorites ribbon. Persisted via browser `localStorage`.
* **🎲 Surprise Me! Generator**: Create complete, playable rooms procedural platform loops, rubies, patrolling enemies, and exit portals with a single tap.

### 💨 Magic Custom Rules Engine (No-Code If/Then Logic)
Create rules to trigger actions on in-game events without coding:
* **IF Triggers**:
  * 🔘 `button_step` (Floor Button Stepped)
  * 🕹️ `lever_flip` (Wall Lever Flipped)
  * 🎯 `target_hit` (Spinning Target practice hit by projectile/jump/hammer)
  * 💎 `coins_5` / `coins_10` (Collected 5/10 Rubies)
* **THEN Actions**:
  * 🚪 `toggle_gate` (Opens/Closes barrier tiles)
  * ✨ `spawn_sparkles` (Fires magic particle flares)
  * 💖 `heal_player` (Heals 20 HP)
  * 🔔 `play_sfx_chime` (Plays retro sound sweeps)

### 🌟 Gameplay Mechanics & Alchemy Potions
* **Wardrobe Costumes**: Swap player color templates (Storm Ninja, Void Wizard) that auto-modulate runner sprite colors and trail emissions.
* **Conveyor Belts**: Moving platforms that slide players and enemies at custom speeds.
* **Mystery Boxes**: Collision blocks that spin items, health, potion speed boosts, shields, or a surprise slime monster.
* **Gravity Flip Zones**: Trigger boundaries that invert gravity physics on enter and normalize it on exit.
* **Alchemy Potions**: Collectible potions for Speed boosts, Giant growth, High Jumps, and Gravity flips.
* **Equipment Gear**: Fly using **Jetpack Thrusters** or float downwards with **Glider Capes**.
* **NPC Shopkeepers**: Interactive shop units that sell tools in exchange for rubies.
* **Lighting Masks**: Ambient dark zones (night/sunset) require equipping the **Lantern** tool to reveal pathways.
* **Toy Hammer**: A tool to smash destructible brick/ice platforms.

### 🛡️ Difficulty Modes & Safety Options
* **Easy Mode**: Halves enemy damage, doubles initial player health, and slows down monster patrols.
* **Normal Mode**: Standard baseline challenge.
* **Creative Mode**: Invincible player mode displaying crowns (`👑`) on the health bar. Bypasses gravity limits to fly freely.
* **Calm Mode**: Disables enemy damage and swaps game over screens with immediate, healthy checkpoint respawns.

### 🌋 Atmosphere & Polish
* **Rising Hazards**: Global rules toggle to trigger slowly rising **🌊 Water** (drown damage) or **🌋 Lava** (lava burn damage).
* **Wind Zones**: Invisible push areas that project player velocity with particle stream lines and custom forces.
* **Emote Wheel**: Tap number keys `1-5` during gameplay to display bouncing scaling emoji bubbles (`😊`, `😡`, `😱`, `🎉`, `💤`) that drift up and fade out.
* **Level Length Indicator**: Shows size tags in the canvas footer based on horizontal terrain bounds (`🎈 Short Adventure`, `🚀 Medium Adventure`, `🏰 Long Quest`, `👑 Epic Quest!`).

---

## 📂 Directory Structure

```text
/kidgamemaker
├── editor/                   # Tauri + Svelte desktop editor
│   ├── src/
│   │   ├── App.svelte         # Main editor workspace
│   │   ├── ToyboxModal.svelte # Star inventory modal
│   │   ├── BookshelfModal.svelte # Level cards modal
│   │   └── lib/canvasState.ts # Shared TypeScript contracts & item types
│   └── src-tauri/src/
│       ├── commands.rs        # Tauri Rust command invokes
│       ├── inbox.rs           # Watcher thread + Zip Slip guards
│       ├── slicer.rs          # Connected-components image slicing
│       └── lib.rs             # Application runner & handlers
├── engine/                   # Godot 4 game runtime
│   ├── scripts/
│   │   ├── Main.gd            # Spawns components, compiles levels, manages BGM
│   │   ├── PlayerController.gd # Player movement physics & emote overlays
│   │   ├── SmartEnemy.gd      # Patrolling, shooting, and boss camera sweeps
│   │   └── Collectible.gd     # Potions, rubies, and animation tweens
│   └── data/
│       ├── game_state.json    # Transpiled level payload
│       └── assets/            # Metadata sidecar descriptors per toy
├── _Inbox/                   # Drop assets here for watch ingestion
└── docs/                     # Technical specifications & roadmap guides
```

---

## 🚀 Getting Started

### Prerequisites
* **Node.js** (v18+)
* **Rust & Cargo** (for Tauri v2 compilation)
* **Godot Engine 4.x** (with PATH registered)

### 1. Launch the Editor
```bash
cd editor
npm install
npm run tauri:dev
```
The editor will compile, start, and locate your workspace directory.

### 2. Run the Game Client
* **Manual Editor Mode**: Open `engine/project.godot` in Godot 4, and run the main scene.
* **Direct Execution Mode** (if you have exported runner binaries):
  ```bash
  .\engine\Runner.exe --level-json .\engine\data\game_state.json
  ```

### 3. Ingesting Custom Assets
Drop `.png`, `.wav`, or `.zip` files into the `_Inbox/` folder. The background watcher daemon will:
1. Parse the dimensions (connected-components grid scan for spritesheets).
2. Generate target classifications based on name tags.
3. Automatically compile a matching `.json` sidecar metadata descriptor.
4. Relocate the files into the `engine/data/assets/` categories directory.
5. Trigger the editor’s Svelte list to refresh automatically.

---

## 🔒 Security & Code Verification

* **PowerShell Escape Guards**: PowerShell process invocations are bypassed in favor of native Rust programmatic archiving using `zip::ZipWriter` and `zip::ZipArchive`, shielding the app from command injection.
* **Zip Slip Path Controls**: Archive extraction inside `inbox.rs` validates entry paths, skipping items resolving outside the target directories.
* **Content Security Policy (CSP)**: Tauri webview configuration strictly scopes script, image, and style protocols:
  `"csp": "default-src 'self' tauri: asset: https://asset.localhost; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: asset: https://asset.localhost blob:;"`
* **Static Verification**:
  * Run TypeScript validation: `npm run check` (runs `tsc --noEmit`).
  * Verify Vite production bundling: `npm run build`.
