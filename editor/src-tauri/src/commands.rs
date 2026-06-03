use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{
    collections::BTreeMap,
    fs,
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

    if cfg!(target_os = "windows") {
        let package_dir_str = package_dir.display().to_string();
        let zip_path_str = zip_path.display().to_string();

        let output = std::process::Command::new("powershell")
            .arg("-NoProfile")
            .arg("-Command")
            .arg(format!(
                "Compress-Archive -Path '{}/*' -DestinationPath '{}' -Force",
                package_dir_str, zip_path_str
            ))
            .output()
            .map_err(|err| format!("Failed to execute PowerShell zip command: {err}"))?;

        if !output.status.success() {
            let err_msg = String::from_utf8_lossy(&output.stderr);
            return Err(format!("PowerShell zip execution failed: {err_msg}"));
        }
    } else {
        let zip_path_str = zip_path.display().to_string();

        let output = std::process::Command::new("zip")
            .arg("-r")
            .arg(&zip_path_str)
            .arg(".")
            .current_dir(&package_dir)
            .output()
            .map_err(|err| format!("Failed to execute zip command: {err}"))?;

        if !output.status.success() {
            let err_msg = String::from_utf8_lossy(&output.stderr);
            return Err(format!("Zip command execution failed: {err_msg}"));
        }
    }

    let _ = fs::remove_dir_all(&package_dir);

    Ok(format!(
        "Game successfully exported to: {}{}",
        zip_path.display(),
        notice
    ))
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
