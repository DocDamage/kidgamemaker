use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{
    collections::BTreeMap,
    fs,
    io,
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AssetSummary {
    pub id: String,
    pub name: String,
    pub category: String,
    pub visual: Option<String>,
    #[serde(rename = "type")]
    pub asset_type: Option<String>,
    pub sidecar_path: String,
    pub is_spritesheet: Option<bool>,
    pub frames: Option<Vec<Value>>,
    pub snapping_type: Option<String>,
    pub parallax_bucket: Option<String>,
}

#[tauri::command(rename_all = "camelCase")]
pub fn compile_and_play(room_payload: Value) -> Result<String, String> {
    let json_string = serde_json::to_string(&room_payload)
        .map_err(|err| format!("Failed to serialize payload: {err}"))?;
    save_game_state(json_string)?;
    match launch_runner() {
        Ok(msg) => Ok(msg),
        Err(err) => {
            if err.contains("executable path is not configured") {
                let repo_root = locate_repo_root()?;
                let game_state_path = repo_root
                    .join("engine")
                    .join("data")
                    .join("game_state.json");
                Ok(format!(
                    "Game state written: {}. Godot runner executable not found yet.",
                    game_state_path.display()
                ))
            } else {
                Err(err)
            }
        }
    }
}

#[tauri::command]
pub fn save_game_state(json_string: String) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let engine_dir = repo_root.join("engine");
    let data_dir = engine_dir.join("data");

    fs::create_dir_all(&data_dir)
        .map_err(|err| format!("Failed to create engine data dir: {err}"))?;

    let game_state_path = data_dir.join("game_state.json");

    let json_value: Value =
        serde_json::from_str(&json_string).map_err(|err| format!("Invalid JSON payload: {err}"))?;

    let pretty_json = serde_json::to_string_pretty(&json_value)
        .map_err(|err| format!("Failed to serialize JSON: {err}"))?;

    fs::write(&game_state_path, pretty_json)
        .map_err(|err| format!("Failed to write game_state.json: {err}"))?;

    Ok(format!(
        "Game state successfully saved to {}",
        game_state_path.display()
    ))
}

#[tauri::command]
pub fn load_game_state() -> Result<Value, String> {
    let repo_root = locate_repo_root()?;
    let data_dir = repo_root.join("engine").join("data");
    let game_state_path = data_dir.join("game_state.json");
    let dummy_level_path = data_dir.join("dummy_level.json");

    let path_to_load = if game_state_path.exists() {
        game_state_path
    } else if dummy_level_path.exists() {
        dummy_level_path
    } else {
        return Err("Neither game_state.json nor dummy_level.json exists.".to_string());
    };

    let content = fs::read_to_string(&path_to_load).map_err(|err| {
        format!(
            "Failed to read game state file {}: {err}",
            path_to_load.display()
        )
    })?;

    let json_value: Value = serde_json::from_str(&content)
        .map_err(|err| format!("Invalid JSON in {}: {err}", path_to_load.display()))?;

    Ok(json_value)
}

#[tauri::command]
pub fn get_project_paths() -> Result<Value, String> {
    let repo_root = locate_repo_root()?;

    let mut paths = BTreeMap::new();
    paths.insert(
        "workspace_root".to_string(),
        repo_root.display().to_string(),
    );
    paths.insert(
        "editor_dir".to_string(),
        repo_root.join("editor").display().to_string(),
    );
    paths.insert(
        "engine_dir".to_string(),
        repo_root.join("engine").display().to_string(),
    );
    paths.insert(
        "game_state_json".to_string(),
        repo_root
            .join("engine")
            .join("data")
            .join("game_state.json")
            .display()
            .to_string(),
    );

    serde_json::to_value(&paths).map_err(|err| format!("Failed to serialize paths: {err}"))
}

#[tauri::command]
pub fn launch_runner() -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let engine_dir = repo_root.join("engine");
    let game_state_path = engine_dir.join("data").join("game_state.json");

    if !game_state_path.exists() {
        return Err(
            "Cannot launch runner: game_state.json does not exist. Save the game first!"
                .to_string(),
        );
    }

    match locate_godot_runner(&engine_dir) {
        Some(runner_path) => {
            Command::new(&runner_path)
                .arg("--level-json")
                .arg(&game_state_path)
                .spawn()
                .map_err(|err| format!("Failed to launch Godot runner: {err}"))?;

            Ok(format!("Godot runner launched with {}", game_state_path.display()))
        }
        None => Err("Godot runner executable path is not configured or built yet. Please open the engine folder in Godot 4 and run the scene manually, or export the project.".to_string()),
    }
}

#[tauri::command]
pub fn get_asset_inventory() -> Result<BTreeMap<String, Vec<AssetSummary>>, String> {
    let repo_root = locate_repo_root()?;
    let asset_root = repo_root.join("engine").join("data").join("assets");

    if !asset_root.exists() {
        return Ok(fallback_inventory());
    }

    let mut inventory: BTreeMap<String, Vec<AssetSummary>> = BTreeMap::new();

    for entry in fs::read_dir(&asset_root)
        .map_err(|err| format!("Failed to read asset root {}: {err}", asset_root.display()))?
    {
        let entry = entry.map_err(|err| err.to_string())?;
        let path = entry.path();

        if path.is_dir() {
            let category = path
                .file_name()
                .and_then(|name| name.to_str())
                .unwrap_or("unknown")
                .to_string();

            for asset_entry in fs::read_dir(&path).map_err(|err| err.to_string())? {
                let asset_entry = asset_entry.map_err(|err| err.to_string())?;
                let asset_dir = asset_entry.path();
                if !asset_dir.is_dir() {
                    continue;
                }

                let asset_id = asset_dir
                    .file_name()
                    .and_then(|name| name.to_str())
                    .unwrap_or("unknown")
                    .to_string();

                let sidecar_path = asset_dir.join(format!("{asset_id}.json"));
                if !sidecar_path.exists() {
                    continue;
                }

                if let Ok(summary) = read_asset_summary(&sidecar_path, &category, &asset_id) {
                    inventory.entry(category.clone()).or_default().push(summary);
                }
            }
        } else if path.is_file() && path.extension().and_then(|ext| ext.to_str()) == Some("json") {
            let asset_id = path
                .file_stem()
                .and_then(|name| name.to_str())
                .unwrap_or("unknown")
                .to_string();

            if let Ok(summary) = read_asset_summary(&path, "general", &asset_id) {
                let category = summary.category.clone();
                inventory.entry(category).or_default().push(summary);
            }
        }
    }

    if inventory.is_empty() {
        Ok(fallback_inventory())
    } else {
        Ok(inventory)
    }
}

fn read_asset_summary(
    sidecar_path: &Path,
    fallback_category: &str,
    fallback_id: &str,
) -> Result<AssetSummary, String> {
    let raw = fs::read_to_string(sidecar_path)
        .map_err(|err| format!("Failed to read sidecar {}: {err}", sidecar_path.display()))?;
    let json: Value = serde_json::from_str(&raw)
        .map_err(|err| format!("Invalid sidecar JSON {}: {err}", sidecar_path.display()))?;

    let id = json
        .get("asset_id")
        .and_then(Value::as_str)
        .unwrap_or(fallback_id)
        .to_string();

    let name = json
        .get("asset_name")
        .and_then(Value::as_str)
        .unwrap_or(&id)
        .to_string();

    let category = json
        .get("category")
        .and_then(Value::as_str)
        .unwrap_or(fallback_category)
        .to_string();

    let visual = json
        .get("visual")
        .and_then(Value::as_str)
        .map(ToString::to_string);

    let asset_type = json
        .get("runtime_template")
        .or_else(|| json.get("type"))
        .and_then(Value::as_str)
        .map(ToString::to_string);

    let is_spritesheet = json.get("is_spritesheet").and_then(Value::as_bool);
    let frames = json.get("frames").and_then(Value::as_array).cloned();

    let snapping_type = json.get("placement_logic")
        .and_then(|p| p.get("snapping_type"))
        .and_then(Value::as_str)
        .map(ToString::to_string);
    let parallax_bucket = json.get("placement_logic")
        .and_then(|p| p.get("parallax_bucket"))
        .and_then(Value::as_str)
        .map(ToString::to_string);

    Ok(AssetSummary {
        id,
        name,
        category,
        visual,
        asset_type,
        sidecar_path: sidecar_path.display().to_string(),
        is_spritesheet,
        frames,
        snapping_type,
        parallax_bucket,
    })
}

fn fallback_inventory() -> BTreeMap<String, Vec<AssetSummary>> {
    let mut inventory = BTreeMap::new();

    inventory.insert(
        "heroes".to_string(),
        vec![AssetSummary {
            id: "hero_knight".to_string(),
            name: "Hero Knight".to_string(),
            category: "heroes".to_string(),
            visual: Some("🛡️".to_string()),
            asset_type: Some("player".to_string()),
            sidecar_path: "engine/data/assets/heroes/hero_knight/hero_knight.json".to_string(),
            is_spritesheet: None,
            frames: None,
            snapping_type: Some("gravity_snap".to_string()),
            parallax_bucket: Some("play_layer".to_string()),
        }],
    );

    inventory.insert(
        "terrain".to_string(),
        vec![AssetSummary {
            id: "stone_floor".to_string(),
            name: "Stone Floor".to_string(),
            category: "terrain".to_string(),
            visual: Some("🪨".to_string()),
            asset_type: Some("terrain".to_string()),
            sidecar_path: "engine/data/assets/terrain/stone_floor/stone_floor.json".to_string(),
            is_spritesheet: None,
            frames: None,
            snapping_type: Some("edge_to_edge".to_string()),
            parallax_bucket: Some("play_layer".to_string()),
        }],
    );

    inventory.insert(
        "enemies".to_string(),
        vec![AssetSummary {
            id: "slime_patrol".to_string(),
            name: "Slime Patrol".to_string(),
            category: "enemies".to_string(),
            visual: Some("👾".to_string()),
            asset_type: Some("enemy".to_string()),
            sidecar_path: "engine/data/assets/enemies/slime_patrol/slime_patrol.json".to_string(),
            is_spritesheet: None,
            frames: None,
            snapping_type: Some("gravity_snap".to_string()),
            parallax_bucket: Some("play_layer".to_string()),
        }],
    );

    inventory
}

pub fn locate_repo_root() -> Result<PathBuf, String> {
    let current = std::env::current_dir()
        .map_err(|err| format!("Could not read current directory: {err}"))?;

    for candidate in current.ancestors() {
        if candidate.join("engine").exists() && candidate.join("editor").exists() {
            return Ok(candidate.to_path_buf());
        }
    }

    current
        .parent()
        .map(Path::to_path_buf)
        .ok_or_else(|| "Could not locate repository root.".to_string())
}

fn locate_godot_runner(engine_dir: &Path) -> Option<PathBuf> {
    let candidates = if cfg!(target_os = "windows") {
        vec![
            engine_dir.join("Runner.exe"),
            engine_dir.join("godot_runner.exe"),
            engine_dir
                .join("exports")
                .join("windows")
                .join("Runner.exe"),
        ]
    } else if cfg!(target_os = "macos") {
        vec![
            engine_dir
                .join("Runner.app")
                .join("Contents")
                .join("MacOS")
                .join("Runner"),
            engine_dir.join("godot_runner"),
        ]
    } else {
        vec![
            engine_dir.join("Runner.x86_64"),
            engine_dir.join("godot_runner.x86_64"),
            engine_dir.join("godot_runner"),
        ]
    };

    candidates.into_iter().find(|path| path.exists())
}

#[tauri::command]
pub fn save_room(room_id: String, json_string: String) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let rooms_dir = repo_root.join("engine").join("data").join("rooms");

    fs::create_dir_all(&rooms_dir)
        .map_err(|err| format!("Failed to create rooms directory: {err}"))?;

    let safe_room_id = room_id.replace(|c: char| !c.is_alphanumeric() && c != '_' && c != '-', "_");
    if safe_room_id.is_empty() {
        return Err("Room ID cannot be empty".to_string());
    }

    let room_path = rooms_dir.join(format!("{safe_room_id}.json"));

    let json_value: Value =
        serde_json::from_str(&json_string).map_err(|err| format!("Invalid JSON payload: {err}"))?;

    let pretty_json = serde_json::to_string_pretty(&json_value)
        .map_err(|err| format!("Failed to serialize JSON: {err}"))?;

    fs::write(&room_path, &pretty_json)
        .map_err(|err| format!("Failed to write room file: {err}"))?;

    let active_dir = repo_root.join("engine").join("data");
    fs::create_dir_all(&active_dir)
        .map_err(|err| format!("Failed to create active data dir: {err}"))?;
    fs::write(active_dir.join("game_state.json"), pretty_json)
        .map_err(|err| format!("Failed to write active game_state.json: {err}"))?;

    Ok(format!(
        "Room successfully saved to {}",
        room_path.display()
    ))
}

#[tauri::command]
pub fn load_room(room_id: String) -> Result<Value, String> {
    let repo_root = locate_repo_root()?;
    let rooms_dir = repo_root.join("engine").join("data").join("rooms");

    let safe_room_id = room_id.replace(|c: char| !c.is_alphanumeric() && c != '_' && c != '-', "_");
    let room_path = rooms_dir.join(format!("{safe_room_id}.json"));

    if !room_path.exists() {
        return Err(format!("Room file does not exist: {}", room_path.display()));
    }

    let content = fs::read_to_string(&room_path)
        .map_err(|err| format!("Failed to read room file {}: {err}", room_path.display()))?;

    let json_value: Value = serde_json::from_str(&content)
        .map_err(|err| format!("Invalid JSON in room file {}: {err}", room_path.display()))?;

    Ok(json_value)
}

#[tauri::command]
pub fn list_rooms() -> Result<Vec<String>, String> {
    let repo_root = locate_repo_root()?;
    let rooms_dir = repo_root.join("engine").join("data").join("rooms");

    if !rooms_dir.exists() {
        fs::create_dir_all(&rooms_dir)
            .map_err(|err| format!("Failed to create rooms directory: {err}"))?;
        return Ok(Vec::new());
    }

    let mut rooms = Vec::new();
    for entry in
        fs::read_dir(&rooms_dir).map_err(|err| format!("Failed to read rooms dir: {err}"))?
    {
        let entry = entry.map_err(|err| err.to_string())?;
        let path = entry.path();
        if path.is_file() && path.extension().and_then(|ext| ext.to_str()) == Some("json") {
            if let Some(stem) = path.file_stem().and_then(|s| s.to_str()) {
                rooms.push(stem.to_string());
            }
        }
    }
    rooms.sort();
    Ok(rooms)
}

#[tauri::command]
pub fn delete_room(room_id: String) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let rooms_dir = repo_root.join("engine").join("data").join("rooms");

    let safe_room_id = room_id.replace(|c: char| !c.is_alphanumeric() && c != '_' && c != '-', "_");
    if safe_room_id.is_empty() {
        return Err("Room ID cannot be empty".to_string());
    }

    let room_path = rooms_dir.join(format!("{safe_room_id}.json"));

    if !room_path.exists() {
        return Err(format!("Room does not exist: {safe_room_id}"));
    }

    fs::remove_file(&room_path)
        .map_err(|err| format!("Failed to delete room file: {err}"))?;

    Ok(format!("Room '{safe_room_id}' deleted successfully"))
}

fn copy_dir_all(src: impl AsRef<Path>, dst: impl AsRef<Path>) -> std::io::Result<()> {
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        if ty.is_dir() {
            copy_dir_all(entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }
    Ok(())
}

#[tauri::command]
pub fn export_game(project_id: String) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let engine_dir = repo_root.join("engine");
    let exports_dir = repo_root.join("exports");

    fs::create_dir_all(&exports_dir)
        .map_err(|err| format!("Failed to create exports directory: {err}"))?;

    let safe_project_id = project_id.replace(|c: char| !c.is_alphanumeric() && c != '_' && c != '-', "_");
    if safe_project_id.is_empty() {
        return Err("Project ID cannot be empty".to_string());
    }

    let package_dir = exports_dir.join(format!("{safe_project_id}_export"));

    if package_dir.exists() {
        fs::remove_dir_all(&package_dir)
            .map_err(|err| format!("Failed to clean existing export directory: {err}"))?;
    }
    fs::create_dir_all(&package_dir)
        .map_err(|err| format!("Failed to create package directory: {err}"))?;

    let data_src = engine_dir.join("data");
    let data_dst = package_dir.join("data");
    if data_src.exists() {
        copy_dir_all(&data_src, &data_dst)
            .map_err(|err| format!("Failed to copy data folder: {err}"))?;
    }

    let mut notice = String::new();
    match locate_godot_runner(&engine_dir) {
        Some(runner_path) => {
            let exe_name = if cfg!(target_os = "windows") {
                "PlayGame.exe"
            } else {
                "PlayGame"
            };
            let exe_dst = package_dir.join(exe_name);
            fs::copy(&runner_path, &exe_dst)
                .map_err(|err| format!("Failed to copy Godot runner executable: {err}"))?;
        }
        None => {
            let files_to_copy = vec!["project.godot", "icon.svg"];
            for file in files_to_copy {
                let src_file = engine_dir.join(file);
                if src_file.exists() {
                    fs::copy(&src_file, package_dir.join(file))
                        .map_err(|err| format!("Failed to copy {file} fallback: {err}"))?;
                }
            }
            let scripts_src = engine_dir.join("scripts");
            let scripts_dst = package_dir.join("scripts");
            if scripts_src.exists() {
                copy_dir_all(&scripts_src, &scripts_dst)
                    .map_err(|err| format!("Failed to copy scripts folder fallback: {err}"))?;
            }
            notice = " (Notice: Godot runner binary not found, exported as standalone Godot project instead)".to_string();
        }
    }

    let zip_path = exports_dir.join(format!("{safe_project_id}_export.zip"));

    if zip_path.exists() {
        let _ = fs::remove_file(&zip_path);
    }

    zip_dir_to_file(&package_dir, &zip_path)
        .map_err(|err| format!("Failed to create export ZIP: {err}"))?;

    let _ = fs::remove_dir_all(&package_dir);

    Ok(format!(
        "Game successfully exported to: {}{}",
        zip_path.display(),
        notice
    ))
}

/// Walk `source_dir` recursively and write all files into a ZIP archive at `zip_path`.
fn zip_dir_to_file(source_dir: &Path, zip_path: &Path) -> Result<(), String> {
    let out_file = fs::File::create(zip_path)
        .map_err(|err| format!("Cannot create zip file '{}': {err}", zip_path.display()))?;
    let out_buf = io::BufWriter::new(out_file);
    let mut zip_writer = zip::ZipWriter::new(out_buf);
    let options =
        zip::write::FileOptions::default().compression_method(zip::CompressionMethod::Deflated);

    let mut stack: Vec<PathBuf> = vec![source_dir.to_path_buf()];
    while let Some(dir) = stack.pop() {
        for entry in fs::read_dir(&dir)
            .map_err(|err| format!("Cannot read dir '{}': {err}", dir.display()))?
        {
            let entry = entry.map_err(|err| err.to_string())?;
            let path = entry.path();
            // Relative path inside the ZIP (strip the source_dir prefix)
            let relative = path
                .strip_prefix(source_dir)
                .map_err(|_| format!("Path prefix error for '{}'", path.display()))?;
            let zip_name = relative.to_string_lossy().replace('\\', "/");

            if path.is_dir() {
                zip_writer
                    .add_directory(&zip_name, options)
                    .map_err(|err| format!("Failed to add dir '{zip_name}': {err}"))?;
                stack.push(path);
            } else {
                zip_writer
                    .start_file(&zip_name, options)
                    .map_err(|err| format!("Failed to start zip entry '{zip_name}': {err}"))?;
                let mut file = fs::File::open(&path)
                    .map_err(|err| format!("Cannot read file '{}': {err}", path.display()))?;
                io::copy(&mut file, &mut zip_writer)
                    .map_err(|err| format!("Failed to write '{zip_name}' into zip: {err}"))?;
            }
        }
    }

    zip_writer
        .finish()
        .map_err(|err| format!("Failed to finalize zip: {err}"))?;
    Ok(())
}

use base64::{Engine as _, engine::general_purpose};

#[tauri::command]
pub fn load_child_sprite(asset_id: String, category: String) -> Result<Vec<Vec<String>>, String> {
    let repo_root = locate_repo_root()?;
    let png_path = repo_root
        .join("engine")
        .join("data")
        .join("assets")
        .join(&category)
        .join(&asset_id)
        .join(format!("{}.png", asset_id));

    let mut grid = vec![vec!["transparent".to_string(); 16]; 16];

    if !png_path.exists() {
        return Ok(grid);
    }

    let file = fs::File::open(&png_path).map_err(|e| e.to_string())?;
    let decoder = png::Decoder::new(file);
    let mut reader = decoder.read_info().map_err(|e| e.to_string())?;
    let mut buf = vec![0; reader.output_buffer_size()];
    let info = reader.next_frame(&mut buf).map_err(|e| e.to_string())?;

    let img_w = info.width as usize;
    let img_h = info.height as usize;

    if img_w == 0 || img_h == 0 {
        return Ok(grid);
    }

    // Centering in 16x16 grid
    let start_x = if img_w < 16 { (16 - img_w) / 2 } else { 0 };
    let start_y = if img_h < 16 { (16 - img_h) / 2 } else { 0 };

    if info.color_type == png::ColorType::Rgba {
        for y in 0..img_h.min(16) {
            for x in 0..img_w.min(16) {
                let idx = ((y * img_w + x) * 4) as usize;
                if idx + 3 < buf.len() {
                    let r = buf[idx];
                    let g = buf[idx + 1];
                    let b = buf[idx + 2];
                    let a = buf[idx + 3];

                    if a > 10 { // not transparent
                        let hex = format!("#{:02x}{:02x}{:02x}", r, g, b);
                        if start_y + y < 16 && start_x + x < 16 {
                            grid[start_y + y][start_x + x] = hex;
                        }
                    }
                }
            }
        }
    } else if info.color_type == png::ColorType::Rgb {
        for y in 0..img_h.min(16) {
            for x in 0..img_w.min(16) {
                let idx = ((y * img_w + x) * 3) as usize;
                if idx + 2 < buf.len() {
                    let r = buf[idx];
                    let g = buf[idx + 1];
                    let b = buf[idx + 2];
                    let hex = format!("#{:02x}{:02x}{:02x}", r, g, b);
                    if start_y + y < 16 && start_x + x < 16 {
                        grid[start_y + y][start_x + x] = hex;
                    }
                }
            }
        }
    }

    Ok(grid)
}

#[tauri::command]
pub fn save_child_sprite(
    asset_id: String,
    category: String,
    base64_data: String,
) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let target_dir = repo_root
        .join("engine")
        .join("data")
        .join("assets")
        .join(&category)
        .join(&asset_id);

    fs::create_dir_all(&target_dir).map_err(|e| e.to_string())?;

    let decoded_bytes = general_purpose::STANDARD
        .decode(base64_data.trim())
        .map_err(|e| e.to_string())?;

    // Decode the PNG to scan transparency and crop
    let decoder = png::Decoder::new(&*decoded_bytes);
    let mut reader = decoder.read_info().map_err(|e| e.to_string())?;
    let mut buf = vec![0; reader.output_buffer_size()];
    let info = reader.next_frame(&mut buf).map_err(|e| e.to_string())?;

    let img_w = info.width as usize;
    let img_h = info.height as usize;

    let mut min_x = img_w;
    let mut max_x = 0;
    let mut min_y = img_h;
    let mut max_y = 0;
    let mut has_pixels = false;

    if info.color_type == png::ColorType::Rgba {
        for y in 0..img_h {
            for x in 0..img_w {
                let idx = ((y * img_w + x) * 4) as usize;
                if idx + 3 < buf.len() {
                    let alpha = buf[idx + 3];
                    if alpha > 10 {
                        has_pixels = true;
                        if x < min_x { min_x = x; }
                        if x > max_x { max_x = x; }
                        if y < min_y { min_y = y; }
                        if y > max_y { max_y = y; }
                    }
                }
            }
        }
    }

    // Determine final dimensions (either cropped or default 16x16 if empty)
    let (crop_x, crop_y, crop_w, crop_h) = if has_pixels {
        (min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
    } else {
        (0, 0, img_w, img_h)
    };

    // Crop the pixels into a new RGBA buffer
    let mut cropped_buf = vec![0u8; crop_w * crop_h * 4];
    
    if info.color_type == png::ColorType::Rgba {
        for y in 0..crop_h {
            for x in 0..crop_w {
                let orig_x = crop_x + x;
                let orig_y = crop_y + y;
                let orig_idx = ((orig_y * img_w + orig_x) * 4) as usize;
                let crop_idx = ((y * crop_w + x) * 4) as usize;
                if orig_idx + 3 < buf.len() && crop_idx + 3 < cropped_buf.len() {
                    cropped_buf[crop_idx] = buf[orig_idx];
                    cropped_buf[crop_idx + 1] = buf[orig_idx + 1];
                    cropped_buf[crop_idx + 2] = buf[orig_idx + 2];
                    cropped_buf[crop_idx + 3] = buf[orig_idx + 3];
                }
            }
        }
    } else {
        // Fallback for non-RGBA (fill alpha with 255)
        for y in 0..crop_h {
            for x in 0..crop_w {
                let orig_x = crop_x + x;
                let orig_y = crop_y + y;
                let orig_idx = ((orig_y * img_w + orig_x) * 3) as usize;
                let crop_idx = ((y * crop_w + x) * 4) as usize;
                if orig_idx + 2 < buf.len() && crop_idx + 3 < cropped_buf.len() {
                    cropped_buf[crop_idx] = buf[orig_idx];
                    cropped_buf[crop_idx + 1] = buf[orig_idx + 1];
                    cropped_buf[crop_idx + 2] = buf[orig_idx + 2];
                    cropped_buf[crop_idx + 3] = 255;
                }
            }
        }
    }

    // Save the cropped image on disk
    let png_filename = format!("{}.png", asset_id);
    let png_path = target_dir.join(&png_filename);
    let file = fs::File::create(&png_path).map_err(|e| e.to_string())?;
    let ref mut w = std::io::BufWriter::new(file);

    let mut encoder = png::Encoder::new(w, crop_w as u32, crop_h as u32);
    encoder.set_color(png::ColorType::Rgba);
    encoder.set_depth(png::BitDepth::Eight);
    let mut writer = encoder.write_header().map_err(|e| e.to_string())?;
    writer.write_image_data(&cropped_buf).map_err(|e| e.to_string())?;

    // Determine runtime_template and default collision/size settings based on category
    let template_type = match category.as_str() {
        "heroes" => "player",
        "enemies" => "enemy",
        "terrain" => "terrain",
        "collectibles" => "collectible",
        "portals" => "portal",
        _ => "decoration",
    };

    let (col_w, col_h) = match template_type {
        "player" => (32, 48),
        "terrain" => (128, 32),
        "enemy" => (32, 32),
        "collectible" => (24, 24),
        "portal" => (48, 64),
        _ => (48, 48), // decoration
    };

    let sidecar_filename = format!("{}.json", asset_id);
    let sidecar_path = target_dir.join(&sidecar_filename);

    let sidecar_payload = serde_json::json!({
        "schema_version": 1,
        "asset_id": asset_id,
        "asset_name": format!("Custom {}", asset_id),
        "category": category,
        "runtime_template": template_type,
        "visual": png_filename,
        "placement_logic": {
            "snapping_type": if category == "terrain" { "edge_to_edge" } else { "gravity_snap" },
            "parallax_bucket": "play_layer"
        },
        "collision": {
            "shape": "rectangle",
            "size": [col_w, col_h]
        }
    });

    fs::write(
        &sidecar_path,
        serde_json::to_string_pretty(&sidecar_payload).unwrap(),
    )
    .map_err(|e| e.to_string())?;

    Ok(format!("Asset {} successfully saved.", asset_id))
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_export_game() {
        let result = export_game("test_project_id_123".to_string());
        assert!(result.is_ok());

        let path_str = result.unwrap();
        assert!(path_str.contains("test_project_id_123_export.zip"));

        let repo_root = locate_repo_root().unwrap();
        let zip_path = repo_root.join("exports").join("test_project_id_123_export.zip");
        assert!(zip_path.exists());

        let _ = std::fs::remove_file(&zip_path);
    }
}
