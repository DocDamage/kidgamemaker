use super::utils::{copy_dir_all, locate_godot_runner, locate_repo_root, zip_dir_to_file};
use serde_json::Value;
use std::collections::BTreeMap;
use std::fs;
use std::process::Command;

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
            let mut cmd = if runner_path.to_string_lossy() == "godot" {
                let mut c = Command::new("godot");
                c.arg("--path").arg(&engine_dir);
                c
            } else {
                Command::new(&runner_path)
            };

            cmd.arg("--level-json")
                .arg(&game_state_path)
                .spawn()
                .map_err(|err| format!("Failed to launch Godot runner: {err}"))?;

            Ok(format!("Godot runner launched with {}", game_state_path.display()))
        }
        None => Err("Godot runner executable path is not configured or built yet. Please open the engine folder in Godot 4 and run the scene manually, or export the project.".to_string()),
    }
}

#[tauri::command]
pub fn export_game(project_id: String) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let engine_dir = repo_root.join("engine");
    let exports_dir = repo_root.join("exports");

    fs::create_dir_all(&exports_dir)
        .map_err(|err| format!("Failed to create exports directory: {err}"))?;

    let safe_project_id =
        project_id.replace(|c: char| !c.is_alphanumeric() && c != '_' && c != '-', "_");
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
        Some(runner_path) if runner_path.to_string_lossy() != "godot" => {
            let exe_name = if cfg!(target_os = "windows") {
                "PlayGame.exe"
            } else {
                "PlayGame"
            };
            let exe_dst = package_dir.join(exe_name);
            fs::copy(&runner_path, &exe_dst)
                .map_err(|err| format!("Failed to copy Godot runner executable: {err}"))?;
        }
        _ => {
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

#[tauri::command]
pub fn package_game_project() -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let data_dir = repo_root.join("engine").join("data");
    let exports_dir = repo_root.join("exports");

    fs::create_dir_all(&exports_dir)
        .map_err(|err| format!("Failed to create exports directory: {err}"))?;

    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);

    let temp_dir = exports_dir.join(format!("toybox_temp_{}", timestamp));
    if temp_dir.exists() {
        let _ = fs::remove_dir_all(&temp_dir);
    }
    fs::create_dir_all(&temp_dir)
        .map_err(|err| format!("Failed to create temp packaging directory: {err}"))?;

    let src_rooms = data_dir.join("rooms");
    if src_rooms.exists() {
        let dst_rooms = temp_dir.join("rooms");
        copy_dir_all(&src_rooms, &dst_rooms)
            .map_err(|err| format!("Failed to copy rooms folder: {err}"))?;
    }

    let src_assets = data_dir.join("assets");
    if src_assets.exists() {
        let dst_assets = temp_dir.join("assets");
        copy_dir_all(&src_assets, &dst_assets)
            .map_err(|err| format!("Failed to copy assets folder: {err}"))?;
    }

    let ktoy_filename = format!("toybox_game_{}.ktoy", timestamp);
    let ktoy_path = exports_dir.join(&ktoy_filename);

    if ktoy_path.exists() {
        let _ = fs::remove_file(&ktoy_path);
    }

    zip_dir_to_file(&temp_dir, &ktoy_path)
        .map_err(|err| format!("Failed to package ktoy ZIP: {err}"))?;

    let _ = fs::remove_dir_all(&temp_dir);

    Ok(ktoy_path.to_string_lossy().to_string())
}

#[tauri::command]
pub fn build_web_runner() -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let engine_dir = repo_root.join("engine");
    let web_export_dir = repo_root.join("editor").join("public").join("game");

    fs::create_dir_all(&web_export_dir)
        .map_err(|err| format!("Failed to create web export directory: {err}"))?;

    let output_html = web_export_dir.join("index.html");

    let output = Command::new("godot")
        .arg("--headless")
        .arg("--path")
        .arg(&engine_dir)
        .arg("--export-release")
        .arg("Web")
        .arg(&output_html)
        .output()
        .map_err(|err| format!("Failed to run godot compiler: {err}"))?;

    if output.status.success() {
        Ok("Web runner built successfully!".to_string())
    } else {
        let err_msg = String::from_utf8_lossy(&output.stderr);
        Err(format!("Godot Web export failed: {err_msg}"))
    }
}
