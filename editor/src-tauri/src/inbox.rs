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
    
    let (category, template, snapping, parallax) = classify_asset(filename);
    
    // Determine default sizes based on template
    let (mut width, mut height) = match template {
        "terrain" => (128, 32),
        "player" => (32, 48),
        "enemy" => (32, 32),
        "collectible" => (24, 24),
        _ => (48, 48),
    };

    // If it's a PNG image, parse the header to read actual dimensions and run slicing
    let mut is_spritesheet = false;
    let mut is_uniform = false;
    let mut grid_cell_size = None;
    let mut confidence = 1.0;
    let mut frames = Vec::new();

    if filename.to_lowercase().ends_with(".png") {
        if let Ok(slice_res) = crate::slicer::slice_sprite_sheet(file_path, category) {
            is_spritesheet = slice_res.is_spritesheet;
            is_uniform = slice_res.is_uniform;
            grid_cell_size = slice_res.grid_cell_size;
            confidence = slice_res.confidence;
            frames = slice_res.frames;

            if let Some(first_frame) = frames.first() {
                width = first_frame.w;
                height = first_frame.h;
            }
        } else if let Some((w, h)) = read_png_dimensions(file_path) {
            width = w;
            height = h;
            frames = vec![crate::slicer::SpriteFrame {
                x: 0,
                y: 0,
                w,
                h,
            }];
        }
    } else {
        frames = vec![crate::slicer::SpriteFrame {
            x: 0,
            y: 0,
            w: width,
            h: height,
        }];
    }

    let dest_dir = repo_root.join("engine").join("data").join("assets").join(category).join(asset_id);
    fs::create_dir_all(&dest_dir).map_err(|err| err.to_string())?;

    let target_file_path = dest_dir.join(filename);
    fs::copy(file_path, &target_file_path).map_err(|err| err.to_string())?;

    // Create sidecar JSON
    let asset_name = humanize_name(asset_id);
    let tags = extract_tags(asset_id);
    
    let mut sidecar_value = serde_json::json!({
        "schema_version": 1,
        "asset_id": asset_id,
        "asset_name": asset_name,
        "category": category,
        "runtime_template": template,
        "visual": filename,
        "visual_tags": tags,
        "is_spritesheet": is_spritesheet,
        "is_uniform_grid": is_uniform,
        "grid_cell_size": grid_cell_size,
        "slicing_confidence": confidence,
        "frames": frames,
        "placement_logic": {
            "snapping_type": snapping,
            "parallax_bucket": parallax
        },
        "collision": {
            "shape": "rectangle",
            "size": [width, height]
        }
    });

    let lower_id = asset_id.to_lowercase();

    // 1. Lighting logic
    if lower_id.contains("torch") || lower_id.contains("light") || lower_id.contains("lamp") || lower_id.contains("candle") || lower_id.contains("fire") || lower_id.contains("lantern") {
        sidecar_value["lighting_logic"] = serde_json::json!({
            "emits_light": true,
            "light_color": "#ffae34",
            "light_energy": 1.2,
            "light_radius": 150.0
        });
    }

    // 2. Baseline attributes for player/enemies
    if template == "player" {
        sidecar_value["baseline_attributes"] = serde_json::json!({
            "max_health": 100,
            "movement_speed": 220.0,
            "jump_force": -460.0,
            "gravity_scale": 1.0
        });
    } else if template == "enemy" {
        let max_health = if lower_id.contains("boss") { 500 } else { 20 };
        let speed = if lower_id.contains("boss") { 50.0 } else { 70.0 };
        let damage = if lower_id.contains("boss") { 25 } else { 10 };
        sidecar_value["baseline_attributes"] = serde_json::json!({
            "max_health": max_health,
            "movement_speed": speed,
            "damage_value": damage,
            "gravity_scale": 1.0
        });
    }

    // 3. Gameplay logic for collectibles
    if template == "collectible" {
        if lower_id.contains("ruby") || lower_id.contains("gem") {
            sidecar_value["gameplay_logic"] = serde_json::json!({
                "score_value": 50
            });
        } else if lower_id.contains("heart") || lower_id.contains("heal") {
            sidecar_value["gameplay_logic"] = serde_json::json!({
                "heal_value": 25
            });
        } else {
            sidecar_value["gameplay_logic"] = serde_json::json!({
                "score_value": 10
            });
        }
    }

    let sidecar_content = serde_json::to_string_pretty(&sidecar_value).unwrap_or_default();
    let sidecar_path = dest_dir.join(format!("{}.json", asset_id));
    fs::write(&sidecar_path, sidecar_content).map_err(|err| err.to_string())?;

    Ok(target_file_path)
}

fn classify_asset(filename: &str) -> (&'static str, &'static str, &'static str, &'static str) {
    let lower = filename.to_lowercase();
    
    let parallax = if lower.contains("bg") || lower.contains("sky") || lower.contains("cloud") || lower.contains("mountain") || lower.contains("background") {
        "deep_background"
    } else if lower.contains("midground") || lower.contains("bush") || lower.contains("tree") || lower.contains("hill") {
        "midground"
    } else if lower.contains("fg") || lower.contains("foreground") {
        "foreground"
    } else {
        "play_layer"
    };

    if lower.contains("hero") || lower.contains("knight") || lower.contains("player") || lower.contains("character") {
        ("heroes", "player", "gravity_snap", parallax)
    } else if lower.contains("enemy") || lower.contains("slime") || lower.contains("boss") || lower.contains("monster") || lower.contains("hazard") {
        ("enemies", "enemy", "gravity_snap", parallax)
    } else if lower.contains("portal") || lower.contains("door") || lower.contains("gate") || lower.contains("warp") || lower.contains("exit") {
        ("portals", "portal", "gravity_snap", parallax)
    } else if lower.contains("checkpoint") || lower.contains("flag") || lower.contains("savepoint") {
        ("decorations", "checkpoint", "free_float", parallax)
    } else if lower.contains("floor") || lower.contains("tile") || lower.contains("block") || lower.contains("ground") || lower.contains("platform") || lower.contains("wall") || lower.contains("brick") || lower.contains("stone") {
        ("terrain", "terrain", "edge_to_edge", parallax)
    } else if lower.contains("coin") || lower.contains("ruby") || lower.contains("gold") || lower.contains("gem") || lower.contains("collectible") || lower.contains("item") || lower.contains("heart") {
        ("collectibles", "collectible", "free_float", parallax)
    } else {
        ("decorations", "decoration", "free_float", parallax)
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
        assert_eq!(classify_asset("hero_knight.png"), ("heroes", "player", "gravity_snap", "play_layer"));
        assert_eq!(classify_asset("slime_enemy.png"), ("enemies", "enemy", "gravity_snap", "play_layer"));
        assert_eq!(classify_asset("stone_floor.png"), ("terrain", "terrain", "edge_to_edge", "play_layer"));
        assert_eq!(classify_asset("ruby_coin.png"), ("collectibles", "collectible", "free_float", "play_layer"));
        assert_eq!(classify_asset("bg_tree.png"), ("decorations", "decoration", "free_float", "deep_background"));
        assert_eq!(classify_asset("gold_portal.png"), ("portals", "portal", "gravity_snap", "play_layer"));
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

    #[test]
    fn test_behavior_enrichment() {
        let temp_base = std::env::temp_dir().join("kdm_test_repo_enrich");
        let _ = fs::remove_dir_all(&temp_base);
        fs::create_dir_all(&temp_base).unwrap();

        // Test light source enrichment
        let source_file = temp_base.join("yellow_torch.png");
        let mut mock_png = vec![0u8; 24];
        mock_png[0..8].copy_from_slice(&[137, 80, 78, 71, 13, 10, 26, 10]);
        mock_png[12..16].copy_from_slice(b"IHDR");
        mock_png[16..20].copy_from_slice(&u32::to_be_bytes(32));
        mock_png[20..24].copy_from_slice(&u32::to_be_bytes(32));
        fs::write(&source_file, &mock_png).unwrap();

        let res = process_single_asset(&source_file, &temp_base);
        assert!(res.is_ok());

        let sidecar_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("decorations")
            .join("yellow_torch")
            .join("yellow_torch.json");
        assert!(sidecar_file.exists());

        let sidecar_content = fs::read_to_string(&sidecar_file).unwrap();
        let sidecar_json: serde_json::Value = serde_json::from_str(&sidecar_content).unwrap();

        assert_eq!(sidecar_json["placement_logic"]["snapping_type"], "free_float");
        assert_eq!(sidecar_json["lighting_logic"]["emits_light"], true);
        assert_eq!(sidecar_json["lighting_logic"]["light_energy"], 1.2);

        // Test boss enemy enrichment
        let boss_file = temp_base.join("dragon_boss.png");
        fs::write(&boss_file, &mock_png).unwrap();
        let res = process_single_asset(&boss_file, &temp_base);
        assert!(res.is_ok());

        let boss_sidecar = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("enemies")
            .join("dragon_boss")
            .join("dragon_boss.json");
        let boss_content = fs::read_to_string(&boss_sidecar).unwrap();
        let boss_json: serde_json::Value = serde_json::from_str(&boss_content).unwrap();

        assert_eq!(boss_json["baseline_attributes"]["max_health"], 500);
        assert_eq!(boss_json["baseline_attributes"]["damage_value"], 25);

        let _ = fs::remove_dir_all(&temp_base);
    }
}
