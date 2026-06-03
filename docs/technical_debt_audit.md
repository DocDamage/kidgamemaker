# Technical Debt & Security Audit: KidGameMaker Workspace

This document provides a comprehensive audit of the technical debt, security risks, memory leaks, and incomplete features/stubs in the **KidGameMaker** workspace.

---

## 1. Security Vulnerabilities

### ✅ Resolved: Remote Command Injection via PowerShell in `inbox.rs`
- **Location**: [`inbox.rs:L141-216`](file:///g:/kidgamemaker/editor/src-tauri/src/inbox.rs#L141-L216)
- **Status**: **RESOLVED**
- **Description**: Spawning external PowerShell processes for unzipping files has been completely removed. The watch daemon now uses the native Rust `zip` crate to open and extract archives in program memory, eliminating shell expansion vulnerabilities.

### ✅ Resolved: Command Injection risk on Workspace Path in `commands.rs`
- **Location**: [`commands.rs:L608-650`](file:///g:/kidgamemaker/editor/src-tauri/src/commands.rs#L608-L650)
- **Status**: **RESOLVED**
- **Description**: Spawning PowerShell processes to run `Compress-Archive` during project exports has been replaced with programmatic recursive ZIP compilation using `zip::ZipWriter` and `io::copy`, which runs safely inside the Rust engine runtime context without spawning shell child processes.

### ✅ Resolved: Content Security Policy (CSP) Enabled
- **Location**: [`tauri.conf.json:L22-24`](file:///g:/kidgamemaker/editor/src-tauri/tauri.conf.json#L22-L24)
- **Status**: **RESOLVED**
- **Description**: Disabling Content Security Policy has been replaced with a strict local asset isolation policy:
  `"csp": "default-src 'self' tauri: asset: https://asset.localhost; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: asset: https://asset.localhost blob:;"`
  This blocks arbitrary inline scripts and unapproved network payloads.

### ✅ Resolved: Zip Slip (Path Traversal) during Ingestion
- **Location**: [`inbox.rs:L141-216`](file:///g:/kidgamemaker/editor/src-tauri/src/inbox.rs#L141-L216)
- **Status**: **RESOLVED**
- **Description**: Added explicit checks on zip path components during extraction in `unzip_file`. Any entry carrying parent-directory components (`..`) or paths resolving outside the destination directory prefix is rejected immediately, shielding the app from Zip Slip exploits.

---

## 2. Memory & Resource Leaks

### ✅ Resolved: Svelte UI `setInterval` Leaks on Unmount
- **Location**: [`App.svelte:L607-618`](file:///g:/kidgamemaker/editor/src/App.svelte#L607-L618)
- **Status**: **RESOLVED**
- **Description**: periodic polling intervals are now stored in local constants (`saveId`, `refreshId`) inside `onMount` and are explicitly cleared on component unmount in Svelte's cleanup return block, preventing javascript thread accumulation during development hot-reloads.

### ✅ Resolved: Godot Runner HUD Canvas Leak on Room Transition
- **Location**: [`Main.gd:L1533-1537`](file:///g:/kidgamemaker/engine/scripts/Main.gd#L1533-L1537)
- **Status**: **RESOLVED**
- **Description**: Transitioning between portals triggers `clear_spawned_entities()`, which now explicitly calls `queue_free()` on `hud_canvas` to release the CanvasLayer viewport tree nodes.

---

## 3. Stubs & Placeholders

### 🖼️ Visual Assets: Emoji & 1x1 Stubs
- **Location**: [`engine/data/assets/`](file:///g:/kidgamemaker/engine/data/assets/)
- **Description**: Emojis are used as visual stamps for many default objects (e.g. `"visual": "🛡️"` for `hero_knight.json`, `"visual": "🪙"` for `gold_coin.json`). 
  The project lacks real 2D pixel art textures. When images are imported, they are often 1x1 stubs. For emojis, the runner programmatically draws flat block polygon placeholders and floats emoji text.
- **Remediation**: Populate asset directories with actual game-ready sprite sheets and configure the sidecars with frame coordinates.

### 🔊 Missing Audio Files
- **Location**: [`gold_coin.json:L29-31`](file:///g:/kidgamemaker/engine/data/assets/gold_coin.json#L29-L31)
- **Description**: The metadata sidecars reference audio files such as `coin_collect.wav` in the `implicit_audio` property. However, there are no `.wav` files inside the workspace asset structure.
- **Remediation**: Place sound asset files under `engine/data/assets/audio/` and update sidecar paths.

### 🔨 Manual Godot Binary Export Required
- **Location**: [`commands.rs:L363-391`](file:///g:/kidgamemaker/editor/src-tauri/src/commands.rs#L363-L391)
- **Description**: Spawning the playable room requires an exported `Runner.exe` / `Runner.app` executable in the `engine/` project folder. If the developer has not manually run the export command from Godot, the editor fails to launch the game window and prints a warning.
- **Remediation**: Integrate a build script or automate the Godot headless command export process (e.g., `godot --headless --export-release "Windows Desktop"`) within the Tauri builder or a developer build command.

### 🏎️ Asset Ingestion Limitations
- **Location**: [`inbox.rs:L164-186`](file:///g:/kidgamemaker/editor/src-tauri/src/inbox.rs#L164-L186)
- **Description**: The file-watcher automatically runs sprite slicing only for `.png` files. If other format files (like WEBP, JPG, or SVG) are dropped into `_Inbox/`, it skips slicing entirely and treats the image as a single flat frame, limiting the asset loader.

---

## 4. Repository Clutter & Legacy Artifacts

### 🧹 Leftover Zips, Patches, and Files
- **Location**: Workspace Root [`g:\kidgamemaker`](file:///g:/kidgamemaker)
- **Description**: Several large backup archives and patch files from past development sessions are kept directly in the workspace root:
  - `kidgamemaker_phase1_contract_runner.patch` (66 KB)
  - `kidgamemaker_phase1_contract_runner.zip` (50 KB)
  - `kidgamemaker_starter_pack.zip` (28 KB)
- **Remediation**: Delete these archives or add them to `.gitignore` to prevent tracking binary artifacts in version control.

### ✅ Resolved: Legacy JSON files directly under `/assets`
- **Location**: [`engine/data/assets/`](file:///g:/kidgamemaker/engine/data/assets/)
- **Status**: **RESOLVED**
- **Description**: The legacy flat JSON files `gold_coin.json`, `hero_knight.json`, `slime_enemy.json`, and `stone_floor.json` have been safely removed from the root `assets` directory, and all sidecars are organized cleanly inside category subfolders.

