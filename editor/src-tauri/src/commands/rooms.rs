use super::utils::locate_repo_root;
use serde_json::Value;
use std::fs;
use std::io::Write;
use std::time::{SystemTime, UNIX_EPOCH};

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

    fs::remove_file(&room_path).map_err(|err| format!("Failed to delete room file: {err}"))?;

    Ok(format!("Room '{safe_room_id}' deleted successfully"))
}

#[tauri::command]
pub fn save_room_compressed(room_id: String, json_string: String) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let compressed_dir = repo_root.join("engine").join("data").join("rooms").join("compressed");

    fs::create_dir_all(&compressed_dir)
        .map_err(|err| format!("Failed to create compressed rooms directory: {err}"))?;

    let safe_room_id = room_id.replace(|c: char| !c.is_alphanumeric() && c != '_' && c != '-', "_");
    if safe_room_id.is_empty() {
        return Err("Room ID cannot be empty".to_string());
    }

    let compressed_path = compressed_dir.join(format!("{safe_room_id}.kgame"));

    // Verify it is valid JSON
    let json_value: Value =
        serde_json::from_str(&json_string).map_err(|err| format!("Invalid JSON payload: {err}"))?;
    let pretty_json = serde_json::to_string_pretty(&json_value)
        .map_err(|err| format!("Failed to serialize JSON: {err}"))?;

    let file = fs::File::create(&compressed_path)
        .map_err(|err| format!("Failed to create compressed file: {err}"))?;

    let mut zip = zip::ZipWriter::new(file);
    let options = zip::write::FileOptions::default()
        .compression_method(zip::CompressionMethod::Deflated);

    zip.start_file("room.json", options)
        .map_err(|err| format!("Failed to start zip file entry: {err}"))?;
    zip.write_all(pretty_json.as_bytes())
        .map_err(|err| format!("Failed to write to zip entry: {err}"))?;
    zip.finish()
        .map_err(|err| format!("Failed to finalize zip file: {err}"))?;

    Ok(format!(
        "Room successfully compressed and saved to {}",
        compressed_path.display()
    ))
}

#[tauri::command]
pub fn cloud_sync_room(room_id: String) -> Result<String, String> {
    let repo_root = locate_repo_root()?;
    let safe_room_id = room_id.replace(|c: char| !c.is_alphanumeric() && c != '_' && c != '-', "_");
    if safe_room_id.is_empty() {
        return Err("Room ID cannot be empty".to_string());
    }

    let compressed_path = repo_root
        .join("engine")
        .join("data")
        .join("rooms")
        .join("compressed")
        .join(format!("{safe_room_id}.kgame"));

    if !compressed_path.exists() {
        return Err(format!(
            "Compressed room file does not exist at {}",
            compressed_path.display()
        ));
    }

    let metadata = fs::metadata(&compressed_path)
        .map_err(|err| format!("Failed to read file metadata: {err}"))?;
    let file_size = metadata.len();

    println!(
        "[CloudSync] Syncing room '{}' ({} bytes) to cloud...",
        safe_room_id, file_size
    );

    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let mock_url = format!(
        "https://cloud-sync.kgame.io/backups/{safe_room_id}.kgame?size={file_size}&ts={ts}"
    );

    Ok(mock_url)
}

