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

    Ok(AssetSummary {
        id,
        name,
        category,
        visual,
        asset_type,
        sidecar_path: sidecar_path.display().to_string(),
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
        }],
    );

    inventory
}

fn locate_repo_root() -> Result<PathBuf, String> {
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
