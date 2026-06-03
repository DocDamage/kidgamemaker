# Technical Debt & Security Audit: KidGameMaker Workspace

This document provides a comprehensive audit of the technical debt, security risks, memory leaks, and incomplete features/stubs in the **KidGameMaker** workspace.

---

## 1. Security Vulnerabilities

### 🚨 Critical: Remote Command Injection via PowerShell in `inbox.rs`
- **Location**: [`inbox.rs:L112-116`](file:///g:/kidgamemaker/editor/src-tauri/src/inbox.rs#L112-L116)
- **Description**: The background asset ingestion watcher thread detects ZIP archives in `_Inbox/` and extracts them by running an external PowerShell process via `Command::new("powershell")`. The command is built using direct string formatting without parameterization or character escaping:
  ```rust
  let output = Command::new("powershell")
      .arg("-Command")
      .arg(format!("Expand-Archive -Path '{}' -DestinationPath '{}' -Force", zip_str, dest_str))
  ```
  Because the filenames are derived directly from user uploads inside `_Inbox/`, an attacker or a malicious asset pack can trigger command execution on the host machine by dropping a file named like:
  `'; Start-Process calc.exe; '.zip`
  This breaks out of the single-quote wrapping in PowerShell, executing arbitrary subcommands.
- **Remediation**: Avoid spawning `powershell` shell subprocesses for archive extraction. Instead, use a native Rust crate such as `zip` to perform extraction programmatically in memory. If PowerShell *must* be used, pass the arguments using standard arguments array parameterization or escape single quotes by doubling them (`'` to `''`).

### ⚠️ Medium/High: Command Injection risk on Workspace Path in `commands.rs`
- **Location**: [`commands.rs:L587-590`](file:///g:/kidgamemaker/editor/src-tauri/src/commands.rs#L587-L590)
- **Description**: During project export, the editor attempts to zip the package directory:
  ```rust
  let output = std::process::Command::new("powershell")
      .arg("-NoProfile")
      .arg("-Command")
      .arg(format!(
          "Compress-Archive -Path '{}/*' -DestinationPath '{}' -Force",
          package_dir_str, zip_path_str
      ))
  ```
  `safe_project_id` is sanitized to alphanumeric characters, but `package_dir_str` contains `repo_root` (the directory where the repository is cloned). If the user checks out the repository inside a directory containing single quotes (e.g. `C:\Users\User's Projects\kidgamemaker`), the PowerShell string interpolation will break, causing failures or arbitrary code execution.
- **Remediation**: Use a native Rust ZIP compiler (like the `zip` crate) to assemble the export ZIP file instead of relying on a platform shell.

### ⚠️ Medium: Content Security Policy (CSP) Disabled
- **Location**: [`tauri.conf.json:L22-24`](file:///g:/kidgamemaker/editor/src-tauri/tauri.conf.json#L22-L24)
- **Description**: The Tauri configuration has the CSP set to `null`:
  ```json
  "security": {
    "csp": null
  }
  ```
  Disabling the Content Security Policy allows the frontend webview to execute inline scripts and request external resources without restriction, which exposes the desktop app to Cross-Site Scripting (XSS) risks if asset data or metadata contains malicious HTML.
- **Remediation**: Set a strict Content Security Policy restricting sources to `self` and safe localhost Tauri asset domains.

### ⚠️ Medium: Zip Slip (Path Traversal) during Ingestion
- **Location**: [`inbox.rs:L105-140`](file:///g:/kidgamemaker/editor/src-tauri/src/inbox.rs#L105-L140)
- **Description**: Unzipping archives in `unzip_file` extracts contents directly to the destination directory. There is no validation check to verify if the archived files contain relative paths (such as `../../etc/shadow` or `../../Startup/malicious.bat`) that resolve outside the extraction sandbox.
- **Remediation**: Implement checking of target paths for every extracted file to verify that the target path remains inside `dest_path`.

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

