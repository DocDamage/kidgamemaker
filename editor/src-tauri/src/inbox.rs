use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

pub fn start_inbox_watcher(repo_root: PathBuf) {
    std::thread::spawn(move || {
        let inbox_dir = repo_root.join("_Inbox");
        loop {
            if inbox_dir.exists() {
                if let Err(err) = process_inbox(&inbox_dir, &repo_root) {
                    eprintln!("Error processing asset inbox: {}", err);
                }
            } else {
                // Auto-create _Inbox folder if it doesn't exist
                let _ = fs::create_dir_all(&inbox_dir);
            }
            std::thread::sleep(std::time::Duration::from_secs(3));
        }
    });
}

fn process_inbox(inbox_dir: &Path, repo_root: &Path) -> Result<(), String> {
    for entry in fs::read_dir(inbox_dir).map_err(|err| err.to_string())? {
        let entry = entry.map_err(|err| err.to_string())?;
        let path = entry.path();
        if !path.is_file() {
            continue;
        }

        let name = path.file_name().and_then(|n| n.to_str()).unwrap_or("");
        let lower_name = name.to_lowercase();

        if lower_name.ends_with(".zip") {
            println!("Asset inbox found ZIP package: {}", name);
            let temp_extract = inbox_dir.join(format!("_temp_extract_{}", name.replace('.', "_")));
            
            // Extract the ZIP contents
            if let Err(err) = unzip_file(&path, &temp_extract) {
                eprintln!("Failed to unzip file {}: {}", name, err);
                let _ = fs::remove_dir_all(&temp_extract);
                continue;
            }

            // Process all extracted files recursively
            if let Err(err) = process_extracted_files(&temp_extract, repo_root) {
                eprintln!("Failed to process extracted contents from {}: {}", name, err);
            }

            // Clean up extraction folder and zip file
            let _ = fs::remove_dir_all(&temp_extract);
            let _ = fs::remove_file(&path);
            println!("Successfully processed and cleaned up ZIP package: {}", name);

        } else if is_supported_asset(name) {
            println!("Asset inbox found single asset: {}", name);
            if let Ok(target_path) = process_single_asset(&path, repo_root) {
                println!("Successfully imported asset: {} to {}", name, target_path.display());
                let _ = fs::remove_file(&path);
            }
        }
    }
    Ok(())
}

fn process_extracted_files(extracted_dir: &Path, repo_root: &Path) -> Result<(), String> {
    let mut files_to_process = Vec::new();
    collect_files_recursive(extracted_dir, &mut files_to_process)?;
    
    for file_path in files_to_process {
        let name = file_path.file_name().and_then(|n| n.to_str()).unwrap_or("");
        if is_supported_asset(name) {
            let _ = process_single_asset(&file_path, repo_root);
        }
    }
    Ok(())
}

fn collect_files_recursive(dir: &Path, files: &mut Vec<PathBuf>) -> Result<(), String> {
    if dir.is_dir() {
        for entry in fs::read_dir(dir).map_err(|err| err.to_string())? {
            let entry = entry.map_err(|err| err.to_string())?;
            let path = entry.path();
            if path.is_dir() {
                collect_files_recursive(&path, files)?;
            } else {
                files.push(path);
            }
        }
    }
    Ok(())
}

fn is_supported_asset(filename: &str) -> bool {
    let lower = filename.to_lowercase();
    lower.ends_with(".png")
        || lower.ends_with(".jpg")
        || lower.ends_with(".jpeg")
        || lower.ends_with(".svg")
        || lower.ends_with(".webp")
        || lower.ends_with(".wav")
        || lower.ends_with(".mp3")
        || lower.ends_with(".ogg")
}

fn unzip_file(zip_path: &Path, dest_path: &Path) -> Result<(), String> {
    fs::create_dir_all(dest_path).map_err(|err| err.to_string())?;

    if cfg!(target_os = "windows") {
        let zip_str = zip_path.to_str().ok_or("Invalid zip path")?;
        let dest_str = dest_path.to_str().ok_or("Invalid dest path")?;
        
        let output = Command::new("powershell")
            .arg("-Command")
            .arg(format!("Expand-Archive -Path '{}' -DestinationPath '{}' -Force", zip_str, dest_str))
            .output()
            .map_err(|err| format!("Failed to run PowerShell Expand-Archive: {err}"))?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            return Err(format!("Expand-Archive failed: {stderr}"));
        }
    } else {
        let zip_str = zip_path.to_str().ok_or("Invalid zip path")?;
        let dest_str = dest_path.to_str().ok_or("Invalid dest path")?;
        
        let output = Command::new("unzip")
            .arg("-o")
            .arg(zip_str)
            .arg("-d")
            .arg(dest_str)
            .output()
            .map_err(|err| format!("Failed to run unzip command: {err}"))?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            return Err(format!("unzip failed: {stderr}"));
        }
    }
    Ok(())
}

fn process_single_asset(file_path: &Path, repo_root: &Path) -> Result<PathBuf, String> {
    let filename = file_path.file_name().and_then(|n| n.to_str()).ok_or("Invalid filename")?;
    let asset_id = file_path.file_stem().and_then(|s| s.to_str()).ok_or("Invalid asset stem")?;
    
    let (category, template, snapping) = classify_asset(filename);
    
    // Determine default sizes based on template
    let (mut width, mut height) = match template {
        "terrain" => (128, 32),
        "player" => (32, 48),
        "enemy" => (32, 32),
        "collectible" => (24, 24),
        _ => (48, 48),
    };

    // If it's a PNG image, parse the header to read actual dimensions
    if filename.to_lowercase().ends_with(".png") {
        if let Some((w, h)) = read_png_dimensions(file_path) {
            width = w;
            height = h;
        }
    }

    let dest_dir = repo_root.join("engine").join("data").join("assets").join(category).join(asset_id);
    fs::create_dir_all(&dest_dir).map_err(|err| err.to_string())?;

    let target_file_path = dest_dir.join(filename);
    fs::copy(file_path, &target_file_path).map_err(|err| err.to_string())?;

    // Create sidecar JSON
    let asset_name = humanize_name(asset_id);
    let tags = extract_tags(asset_id);
    
    let sidecar_content = format!(
        r#"{{
  "schema_version": 1,
  "asset_id": "{asset_id}",
  "asset_name": "{asset_name}",
  "category": "{category}",
  "runtime_template": "{template}",
  "visual": "{filename}",
  "visual_tags": {tags_json},
  "placement_logic": {{
    "snapping_type": "{snapping}",
    "parallax_bucket": "play_layer"
  }},
  "collision": {{
    "shape": "rectangle",
    "size": [
      {width},
      {height}
    ]
  }}
}}"#,
        asset_id = asset_id,
        asset_name = asset_name,
        category = category,
        template = template,
        filename = filename,
        snapping = snapping,
        width = width,
        height = height,
        tags_json = serde_json::to_string(&tags).unwrap_or_else(|_| "[]".to_string())
    );

    let sidecar_path = dest_dir.join(format!("{}.json", asset_id));
    fs::write(&sidecar_path, sidecar_content).map_err(|err| err.to_string())?;

    Ok(target_file_path)
}

fn classify_asset(filename: &str) -> (&'static str, &'static str, &'static str) {
    let lower = filename.to_lowercase();
    
    if lower.contains("hero") || lower.contains("knight") || lower.contains("player") || lower.contains("character") {
        ("heroes", "player", "gravity_snap")
    } else if lower.contains("enemy") || lower.contains("slime") || lower.contains("boss") || lower.contains("monster") || lower.contains("hazard") {
        ("enemies", "enemy", "gravity_snap")
    } else if lower.contains("floor") || lower.contains("tile") || lower.contains("block") || lower.contains("ground") || lower.contains("platform") || lower.contains("wall") || lower.contains("brick") || lower.contains("stone") {
        ("terrain", "terrain", "edge_to_edge")
    } else if lower.contains("coin") || lower.contains("ruby") || lower.contains("gold") || lower.contains("gem") || lower.contains("collectible") || lower.contains("item") || lower.contains("heart") {
        ("collectibles", "collectible", "free_float")
    } else if lower.contains("checkpoint") || lower.contains("flag") || lower.contains("savepoint") {
        ("decorations", "checkpoint", "free_float")
    } else {
        ("decorations", "decoration", "free_float")
    }
}

fn extract_tags(stem: &str) -> Vec<String> {
    stem.split(|c: char| c == '_' || c == '-' || c == ' ')
        .filter(|part| !part.is_empty())
        .map(|part| part.to_lowercase())
        .collect()
}

fn humanize_name(stem: &str) -> String {
    let parts: Vec<String> = stem.split(|c: char| c == '_' || c == '-' || c == ' ')
        .filter(|part| !part.is_empty())
        .map(|part| {
            let mut c = part.chars();
            match c.next() {
                None => String::new(),
                Some(f) => f.to_uppercase().collect::<String>() + c.as_str(),
            }
        })
        .collect();
    parts.join(" ")
}

fn read_png_dimensions(path: &Path) -> Option<(u32, u32)> {
    let mut file = fs::File::open(path).ok()?;
    use std::io::Read;
    let mut header = [0u8; 24];
    file.read_exact(&mut header).ok()?;
    
    if &header[0..8] != &[137, 80, 78, 71, 13, 10, 26, 10] {
        return None;
    }
    
    if &header[12..16] != b"IHDR" {
        return None;
    }
    
    let width = u32::from_be_bytes([header[16], header[17], header[18], header[19]]);
    let height = u32::from_be_bytes([header[20], header[21], header[22], header[23]]);
    
    Some((width, height))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_classify_asset() {
        assert_eq!(classify_asset("hero_knight.png"), ("heroes", "player", "gravity_snap"));
        assert_eq!(classify_asset("slime_enemy.png"), ("enemies", "enemy", "gravity_snap"));
        assert_eq!(classify_asset("stone_floor.png"), ("terrain", "terrain", "edge_to_edge"));
        assert_eq!(classify_asset("ruby_coin.png"), ("collectibles", "collectible", "free_float"));
        assert_eq!(classify_asset("bg_tree.png"), ("decorations", "decoration", "free_float"));
    }

    #[test]
    fn test_humanize_name() {
        assert_eq!(humanize_name("red_slime_enemy"), "Red Slime Enemy");
        assert_eq!(humanize_name("hero-knight"), "Hero Knight");
        assert_eq!(humanize_name("stone floor"), "Stone Floor");
    }

    #[test]
    fn test_extract_tags() {
        assert_eq!(extract_tags("red_slime_enemy"), vec!["red", "slime", "enemy"]);
        assert_eq!(extract_tags("hero-knight"), vec!["hero", "knight"]);
    }

    #[test]
    fn test_read_png_dimensions() {
        let mut mock_png = vec![0u8; 24];
        mock_png[0..8].copy_from_slice(&[137, 80, 78, 71, 13, 10, 26, 10]);
        mock_png[12..16].copy_from_slice(b"IHDR");
        mock_png[16..20].copy_from_slice(&u32::to_be_bytes(64));
        mock_png[20..24].copy_from_slice(&u32::to_be_bytes(32));

        let temp_dir = std::env::temp_dir();
        let test_file = temp_dir.join("test_mock.png");
        fs::write(&test_file, &mock_png).unwrap();

        let dims = read_png_dimensions(&test_file);
        let _ = fs::remove_file(&test_file);

        assert_eq!(dims, Some((64, 32)));
    }

    #[test]
    fn test_process_single_asset() {
        let temp_base = std::env::temp_dir().join("kdm_test_repo");
        let _ = fs::remove_dir_all(&temp_base);
        fs::create_dir_all(&temp_base).unwrap();

        let source_file = temp_base.join("blue_slime_enemy.png");
        
        let mut mock_png = vec![0u8; 24];
        mock_png[0..8].copy_from_slice(&[137, 80, 78, 71, 13, 10, 26, 10]);
        mock_png[12..16].copy_from_slice(b"IHDR");
        mock_png[16..20].copy_from_slice(&u32::to_be_bytes(64));
        mock_png[20..24].copy_from_slice(&u32::to_be_bytes(64));
        fs::write(&source_file, &mock_png).unwrap();

        let res = process_single_asset(&source_file, &temp_base);
        assert!(res.is_ok());

        let dest_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("enemies")
            .join("blue_slime_enemy")
            .join("blue_slime_enemy.png");
        assert!(dest_file.exists());

        let sidecar_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("enemies")
            .join("blue_slime_enemy")
            .join("blue_slime_enemy.json");
        assert!(sidecar_file.exists());

        let sidecar_content = fs::read_to_string(&sidecar_file).unwrap();
        let sidecar_json: serde_json::Value = serde_json::from_str(&sidecar_content).unwrap();

        assert_eq!(sidecar_json["asset_id"], "blue_slime_enemy");
        assert_eq!(sidecar_json["asset_name"], "Blue Slime Enemy");
        assert_eq!(sidecar_json["category"], "enemies");
        assert_eq!(sidecar_json["runtime_template"], "enemy");
        assert_eq!(sidecar_json["visual"], "blue_slime_enemy.png");
        assert_eq!(sidecar_json["collision"]["size"][0], 64);
        assert_eq!(sidecar_json["collision"]["size"][1], 64);

        let _ = fs::remove_dir_all(&temp_base);
    }
}
