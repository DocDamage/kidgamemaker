use std::fs;
use std::io::{self, Read};
use std::path::{Path, PathBuf};

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

        if lower_name.ends_with(".ktoy") {
            println!("Asset inbox found .ktoy package: {}", name);
            let temp_extract =
                inbox_dir.join(format!("_temp_extract_ktoy_{}", name.replace('.', "_")));

            // Extract the ZIP contents
            if let Err(err) = unzip_file(&path, &temp_extract) {
                eprintln!("Failed to unzip .ktoy file {}: {}", name, err);
                let _ = fs::remove_dir_all(&temp_extract);
                continue;
            }

            // Ingest rooms
            let temp_rooms = temp_extract.join("rooms");
            if temp_rooms.exists() {
                let dest_rooms = repo_root.join("engine").join("data").join("rooms");
                let _ = fs::create_dir_all(&dest_rooms);
                if let Err(err) = copy_dir_all(&temp_rooms, &dest_rooms) {
                    eprintln!("Failed to copy rooms from .ktoy: {}", err);
                }
            }

            // Ingest assets
            let temp_assets = temp_extract.join("assets");
            if temp_assets.exists() {
                let dest_assets = repo_root.join("engine").join("data").join("assets");
                let _ = fs::create_dir_all(&dest_assets);
                if let Err(err) = copy_dir_all(&temp_assets, &dest_assets) {
                    eprintln!("Failed to copy assets from .ktoy: {}", err);
                }
            }

            // Clean up extraction folder and .ktoy file
            let _ = fs::remove_dir_all(&temp_extract);
            let _ = fs::remove_file(&path);
            println!(
                "Successfully processed and cleaned up .ktoy package: {}",
                name
            );
        } else if lower_name.ends_with(".zip") {
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
                eprintln!(
                    "Failed to process extracted contents from {}: {}",
                    name, err
                );
            }

            // Clean up extraction folder and zip file
            let _ = fs::remove_dir_all(&temp_extract);
            let _ = fs::remove_file(&path);
            println!(
                "Successfully processed and cleaned up ZIP package: {}",
                name
            );
        } else if is_supported_asset(name) {
            println!("Asset inbox found single asset: {}", name);
            if let Ok(target_path) = process_single_asset(&path, repo_root) {
                println!(
                    "Successfully imported asset: {} to {}",
                    name,
                    target_path.display()
                );
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

    // Canonicalize the destination so we can validate extracted paths (Zip Slip protection).
    let canonical_dest = fs::canonicalize(dest_path).map_err(|err| {
        format!(
            "Failed to canonicalize dest path '{}': {err}",
            dest_path.display()
        )
    })?;

    let zip_file = fs::File::open(zip_path)
        .map_err(|err| format!("Failed to open zip file '{}': {err}", zip_path.display()))?;
    let mut archive = zip::ZipArchive::new(zip_file)
        .map_err(|err| format!("Failed to read zip archive: {err}"))?;

    for i in 0..archive.len() {
        let mut entry = archive
            .by_index(i)
            .map_err(|err| format!("Failed to read zip entry {i}: {err}"))?;

        // Resolve the sanitized entry name (zip::ZipFile::enclosed_name strips leading '/' and '..').
        let entry_path = match entry.enclosed_name() {
            Some(p) => p.to_path_buf(),
            None => {
                eprintln!("Skipping zip entry with unsafe name: {:?}", entry.name());
                continue;
            }
        };

        let target_path = dest_path.join(&entry_path);

        // Zip Slip guard: make sure the resolved target stays inside dest_path.
        // We construct the canonical parent by appending components one by one.
        // Using `fs::canonicalize` would fail for paths that don't exist yet, so
        // we normalise manually by stripping '.' and collapsing '..' via PathBuf.
        let mut normalised = canonical_dest.clone();
        let mut is_unsafe = false;
        for component in entry_path.components() {
            use std::path::Component;
            match component {
                Component::Normal(name) => normalised.push(name),
                Component::ParentDir => {
                    // '..' would escape the sandbox — skip this entry.
                    eprintln!(
                        "Zip Slip guard: rejecting entry '{}' which would escape destination.",
                        entry.name()
                    );
                    is_unsafe = true;
                    break;
                }
                _ => {}
            }
        }
        if is_unsafe || !normalised.starts_with(&canonical_dest) {
            eprintln!(
                "Zip Slip guard: rejecting entry '{}' — resolved path is outside destination.",
                entry.name()
            );
            continue;
        }

        if entry.is_dir() {
            fs::create_dir_all(&target_path).map_err(|err| {
                format!(
                    "Failed to create directory '{}': {err}",
                    target_path.display()
                )
            })?;
        } else {
            if let Some(parent) = target_path.parent() {
                fs::create_dir_all(parent).map_err(|err| {
                    format!("Failed to create parent dir '{}': {err}", parent.display())
                })?;
            }
            let mut out_file = fs::File::create(&target_path).map_err(|err| {
                format!("Failed to create file '{}': {err}", target_path.display())
            })?;
            io::copy(&mut entry, &mut out_file).map_err(|err| {
                format!("Failed to write file '{}': {err}", target_path.display())
            })?;
        }
    }

    Ok(())
}

fn process_single_asset(file_path: &Path, repo_root: &Path) -> Result<PathBuf, String> {
    let filename = file_path
        .file_name()
        .and_then(|n| n.to_str())
        .ok_or("Invalid filename")?;
    let asset_id = file_path
        .file_stem()
        .and_then(|s| s.to_str())
        .ok_or("Invalid asset stem")?;

    let (category, template, snapping, parallax) = classify_asset(filename);

    // Determine default sizes based on template
    let (mut width, mut height) = match template {
        "terrain" => (128, 32),
        "player" => (32, 48),
        "enemy" => (32, 32),
        "collectible" => (24, 24),
        _ => (48, 48),
    };

    // PNG files can be sliced. Other supported image formats still get real dimensions.
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
        } else if let Some((w, h)) = read_image_dimensions(file_path) {
            width = w;
            height = h;
            frames = vec![crate::slicer::SpriteFrame { x: 0, y: 0, w, h }];
        }
    } else if let Some((w, h)) = read_image_dimensions(file_path) {
        width = w;
        height = h;
        frames = vec![crate::slicer::SpriteFrame { x: 0, y: 0, w, h }];
    } else {
        frames = vec![crate::slicer::SpriteFrame {
            x: 0,
            y: 0,
            w: width,
            h: height,
        }];
    }

    let dest_dir = repo_root
        .join("engine")
        .join("data")
        .join("assets")
        .join(category)
        .join(asset_id);
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
    if lower_id.contains("torch")
        || lower_id.contains("light")
        || lower_id.contains("lamp")
        || lower_id.contains("candle")
        || lower_id.contains("fire")
        || lower_id.contains("lantern")
    {
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
        let speed = if lower_id.contains("boss") {
            50.0
        } else {
            70.0
        };
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

    // 4. Key collectible gameplay logic
    if template == "key_collectible" {
        let key_color = if lower_id.contains("gold") || lower_id.contains("yellow") {
            "gold"
        } else if lower_id.contains("red") {
            "red"
        } else if lower_id.contains("blue") {
            "blue"
        } else if lower_id.contains("silver") || lower_id.contains("white") {
            "silver"
        } else {
            "gold"
        };
        sidecar_value["gameplay_logic"] = serde_json::json!({
            "on_pickup": "collect_key",
            "score_value": 0,
            "heal_value": 0,
            "key_color": key_color
        });
    }

    // 5. Locked door gameplay logic
    if template == "locked_door" {
        let key_color = if lower_id.contains("gold") || lower_id.contains("yellow") {
            "gold"
        } else if lower_id.contains("red") {
            "red"
        } else if lower_id.contains("blue") {
            "blue"
        } else if lower_id.contains("silver") || lower_id.contains("white") {
            "silver"
        } else {
            "gold"
        };
        sidecar_value["gameplay_logic"] = serde_json::json!({
            "requires_key": true,
            "key_color": key_color
        });
    }

    let sidecar_content = serde_json::to_string_pretty(&sidecar_value)
        .map_err(|err| format!("Failed to serialize sidecar for {asset_id}: {err}"))?;
    let sidecar_path = dest_dir.join(format!("{}.json", asset_id));
    fs::write(&sidecar_path, sidecar_content).map_err(|err| err.to_string())?;

    Ok(target_file_path)
}

fn classify_asset(filename: &str) -> (&'static str, &'static str, &'static str, &'static str) {
    let lower = filename.to_lowercase();

    let parallax = if lower.contains("bg")
        || lower.contains("sky")
        || lower.contains("cloud")
        || lower.contains("mountain")
        || lower.contains("background")
    {
        "deep_background"
    } else if lower.contains("midground")
        || lower.contains("bush")
        || lower.contains("tree")
        || lower.contains("hill")
    {
        "midground"
    } else if lower.contains("fg") || lower.contains("foreground") {
        "foreground"
    } else {
        "play_layer"
    };

    if lower.contains("hero")
        || lower.contains("knight")
        || lower.contains("player")
        || lower.contains("character")
    {
        ("heroes", "player", "gravity_snap", parallax)
    } else if lower.contains("enemy")
        || lower.contains("slime")
        || lower.contains("boss")
        || lower.contains("monster")
        || lower.contains("hazard")
    {
        ("enemies", "enemy", "gravity_snap", parallax)
    } else if (lower.contains("lock") || lower.contains("locked"))
        && (lower.contains("door") || lower.contains("gate"))
    {
        ("portals", "locked_door", "gravity_snap", parallax)
    } else if lower.contains("portal")
        || lower.contains("door")
        || lower.contains("gate")
        || lower.contains("warp")
        || lower.contains("exit")
    {
        ("portals", "portal", "gravity_snap", parallax)
    } else if lower.contains("checkpoint") || lower.contains("flag") || lower.contains("savepoint")
    {
        ("decorations", "checkpoint", "free_float", parallax)
    } else if lower.contains("floor")
        || lower.contains("tile")
        || lower.contains("block")
        || lower.contains("ground")
        || lower.contains("platform")
        || lower.contains("wall")
        || lower.contains("brick")
        || lower.contains("stone")
    {
        ("terrain", "terrain", "edge_to_edge", parallax)
    } else if lower.contains("_key")
        || lower.starts_with("key_")
        || lower.ends_with("_key.png")
        || lower.ends_with("_key.wav")
    {
        ("collectibles", "key_collectible", "free_float", parallax)
    } else if lower.contains("coin")
        || lower.contains("ruby")
        || lower.contains("gold")
        || lower.contains("gem")
        || lower.contains("collectible")
        || lower.contains("item")
        || lower.contains("heart")
    {
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
    let parts: Vec<String> = stem
        .split(|c: char| c == '_' || c == '-' || c == ' ')
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

fn read_image_dimensions(path: &Path) -> Option<(u32, u32)> {
    let ext = path.extension()?.to_str()?.to_lowercase();
    match ext.as_str() {
        "png" => read_png_dimensions(path),
        "jpg" | "jpeg" => read_jpeg_dimensions(path),
        "webp" => read_webp_dimensions(path),
        "svg" => read_svg_dimensions(path),
        _ => None,
    }
}

fn read_jpeg_dimensions(path: &Path) -> Option<(u32, u32)> {
    let bytes = fs::read(path).ok()?;
    if bytes.len() < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8 {
        return None;
    }

    let mut i = 2usize;
    while i + 9 < bytes.len() {
        while i < bytes.len() && bytes[i] != 0xFF {
            i += 1;
        }
        while i < bytes.len() && bytes[i] == 0xFF {
            i += 1;
        }
        if i >= bytes.len() {
            return None;
        }

        let marker = bytes[i];
        i += 1;
        if marker == 0xD9 || marker == 0xDA {
            return None;
        }
        if i + 2 > bytes.len() {
            return None;
        }
        let segment_len = u16::from_be_bytes([bytes[i], bytes[i + 1]]) as usize;
        if segment_len < 2 || i + segment_len > bytes.len() {
            return None;
        }

        let is_sof = matches!(
            marker,
            0xC0 | 0xC1
                | 0xC2
                | 0xC3
                | 0xC5
                | 0xC6
                | 0xC7
                | 0xC9
                | 0xCA
                | 0xCB
                | 0xCD
                | 0xCE
                | 0xCF
        );
        if is_sof && segment_len >= 7 {
            let height = u16::from_be_bytes([bytes[i + 3], bytes[i + 4]]) as u32;
            let width = u16::from_be_bytes([bytes[i + 5], bytes[i + 6]]) as u32;
            return Some((width, height));
        }
        i += segment_len;
    }

    None
}

fn read_webp_dimensions(path: &Path) -> Option<(u32, u32)> {
    let bytes = fs::read(path).ok()?;
    if bytes.len() < 30 || &bytes[0..4] != b"RIFF" || &bytes[8..12] != b"WEBP" {
        return None;
    }

    match &bytes[12..16] {
        b"VP8X" if bytes.len() >= 30 => {
            let width = 1 + u32::from_le_bytes([bytes[24], bytes[25], bytes[26], 0]);
            let height = 1 + u32::from_le_bytes([bytes[27], bytes[28], bytes[29], 0]);
            Some((width, height))
        }
        b"VP8 " if bytes.len() >= 30 => {
            if bytes[23] != 0x9D || bytes[24] != 0x01 || bytes[25] != 0x2A {
                return None;
            }
            let raw_width = u16::from_le_bytes([bytes[26], bytes[27]]) & 0x3FFF;
            let raw_height = u16::from_le_bytes([bytes[28], bytes[29]]) & 0x3FFF;
            Some((raw_width as u32, raw_height as u32))
        }
        b"VP8L" if bytes.len() >= 25 => {
            if bytes[20] != 0x2F {
                return None;
            }
            let b0 = bytes[21] as u32;
            let b1 = bytes[22] as u32;
            let b2 = bytes[23] as u32;
            let b3 = bytes[24] as u32;
            let width = 1 + (((b1 & 0x3F) << 8) | b0);
            let height = 1 + ((b3 << 6) | (b2 >> 2));
            Some((width, height))
        }
        _ => None,
    }
}

fn read_svg_dimensions(path: &Path) -> Option<(u32, u32)> {
    let text = fs::read_to_string(path).ok()?;
    let width = read_svg_numeric_attr(&text, "width");
    let height = read_svg_numeric_attr(&text, "height");
    if let (Some(w), Some(h)) = (width, height) {
        return Some((w, h));
    }

    let view_box = read_svg_attr(&text, "viewBox").or_else(|| read_svg_attr(&text, "viewbox"))?;
    let values: Vec<f32> = view_box
        .split(|c: char| c.is_whitespace() || c == ',')
        .filter_map(|part| part.parse::<f32>().ok())
        .collect();
    if values.len() == 4 && values[2] > 0.0 && values[3] > 0.0 {
        return Some((values[2].round() as u32, values[3].round() as u32));
    }
    None
}

fn read_svg_numeric_attr(text: &str, attr: &str) -> Option<u32> {
    let value = read_svg_attr(text, attr)?;
    let number: String = value
        .chars()
        .take_while(|c| c.is_ascii_digit() || *c == '.')
        .collect();
    let parsed = number.parse::<f32>().ok()?;
    if parsed > 0.0 {
        Some(parsed.round() as u32)
    } else {
        None
    }
}

fn read_svg_attr(text: &str, attr: &str) -> Option<String> {
    let needle = format!("{attr}=");
    let start = text.find(&needle)? + needle.len();
    let quote = text[start..].chars().next()?;
    if quote != '"' && quote != '\'' {
        return None;
    }
    let value_start = start + quote.len_utf8();
    let value_end = text[value_start..].find(quote)? + value_start;
    Some(text[value_start..value_end].to_string())
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::error::Error;
    use std::fs;

    fn mock_png_header(width: u32, height: u32) -> Vec<u8> {
        let mut mock_png = vec![0u8; 24];
        mock_png[0..8].copy_from_slice(&[137, 80, 78, 71, 13, 10, 26, 10]);
        mock_png[12..16].copy_from_slice(b"IHDR");
        mock_png[16..20].copy_from_slice(&u32::to_be_bytes(width));
        mock_png[20..24].copy_from_slice(&u32::to_be_bytes(height));
        mock_png
    }

    fn test_error(error: String) -> std::io::Error {
        std::io::Error::new(std::io::ErrorKind::Other, error)
    }

    #[test]
    fn test_classify_asset() {
        assert_eq!(
            classify_asset("hero_knight.png"),
            ("heroes", "player", "gravity_snap", "play_layer")
        );
        assert_eq!(
            classify_asset("slime_enemy.png"),
            ("enemies", "enemy", "gravity_snap", "play_layer")
        );
        assert_eq!(
            classify_asset("stone_floor.png"),
            ("terrain", "terrain", "edge_to_edge", "play_layer")
        );
        assert_eq!(
            classify_asset("ruby_coin.png"),
            ("collectibles", "collectible", "free_float", "play_layer")
        );
        assert_eq!(
            classify_asset("bg_tree.png"),
            ("decorations", "decoration", "free_float", "deep_background")
        );
        assert_eq!(
            classify_asset("gold_portal.png"),
            ("portals", "portal", "gravity_snap", "play_layer")
        );
    }

    #[test]
    fn test_humanize_name() {
        assert_eq!(humanize_name("red_slime_enemy"), "Red Slime Enemy");
        assert_eq!(humanize_name("hero-knight"), "Hero Knight");
        assert_eq!(humanize_name("stone floor"), "Stone Floor");
    }

    #[test]
    fn test_extract_tags() {
        assert_eq!(
            extract_tags("red_slime_enemy"),
            vec!["red", "slime", "enemy"]
        );
        assert_eq!(extract_tags("hero-knight"), vec!["hero", "knight"]);
    }

    #[test]
    fn test_read_png_dimensions() -> Result<(), Box<dyn Error>> {
        let mock_png = mock_png_header(64, 32);

        let temp_dir = std::env::temp_dir();
        let test_file = temp_dir.join("test_mock.png");
        fs::write(&test_file, &mock_png)?;

        let dims = read_png_dimensions(&test_file);
        let _ = fs::remove_file(&test_file);

        assert_eq!(dims, Some((64, 32)));
        Ok(())
    }

    #[test]
    fn test_read_non_png_dimensions() -> Result<(), Box<dyn Error>> {
        let temp_dir = std::env::temp_dir();

        let jpg_file = temp_dir.join("test_mock.jpg");
        let mock_jpg = vec![
            0xFF, 0xD8, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x2A, 0x00, 0x50, 0x03, 0x01, 0x00,
            0x00, 0x02, 0x11, 0x00, 0x03, 0x11, 0x00,
        ];
        fs::write(&jpg_file, &mock_jpg)?;
        assert_eq!(read_image_dimensions(&jpg_file), Some((80, 42)));
        let _ = fs::remove_file(&jpg_file);

        let webp_file = temp_dir.join("test_mock.webp");
        let mut mock_webp = vec![0u8; 30];
        mock_webp[0..4].copy_from_slice(b"RIFF");
        mock_webp[8..12].copy_from_slice(b"WEBP");
        mock_webp[12..16].copy_from_slice(b"VP8X");
        mock_webp[24..27].copy_from_slice(&(95u32).to_le_bytes()[0..3]);
        mock_webp[27..30].copy_from_slice(&(47u32).to_le_bytes()[0..3]);
        fs::write(&webp_file, &mock_webp)?;
        assert_eq!(read_image_dimensions(&webp_file), Some((96, 48)));
        let _ = fs::remove_file(&webp_file);

        let svg_file = temp_dir.join("test_mock.svg");
        fs::write(
            &svg_file,
            r#"<svg xmlns="http://www.w3.org/2000/svg" width="128px" height="64px"></svg>"#,
        )?;
        assert_eq!(read_image_dimensions(&svg_file), Some((128, 64)));
        let _ = fs::remove_file(&svg_file);
        Ok(())
    }

    #[test]
    fn test_process_single_svg_asset_uses_real_dimensions() -> Result<(), Box<dyn Error>> {
        let temp_base = std::env::temp_dir().join("kdm_test_repo_svg");
        let _ = fs::remove_dir_all(&temp_base);
        fs::create_dir_all(&temp_base)?;

        let source_file = temp_base.join("bg_mountain.svg");
        fs::write(
            &source_file,
            r#"<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 96"></svg>"#,
        )?;

        process_single_asset(&source_file, &temp_base).map_err(test_error)?;

        let sidecar_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("decorations")
            .join("bg_mountain")
            .join("bg_mountain.json");
        let sidecar_content = fs::read_to_string(&sidecar_file)?;
        let sidecar_json: serde_json::Value = serde_json::from_str(&sidecar_content)?;

        assert_eq!(sidecar_json["collision"]["size"][0], 192);
        assert_eq!(sidecar_json["collision"]["size"][1], 96);
        assert_eq!(sidecar_json["frames"][0]["w"], 192);
        assert_eq!(sidecar_json["frames"][0]["h"], 96);

        let _ = fs::remove_dir_all(&temp_base);
        Ok(())
    }

    #[test]
    fn test_process_single_asset() -> Result<(), Box<dyn Error>> {
        let temp_base = std::env::temp_dir().join("kdm_test_repo");
        let _ = fs::remove_dir_all(&temp_base);
        fs::create_dir_all(&temp_base)?;

        let source_file = temp_base.join("blue_slime_enemy.png");

        let mock_png = mock_png_header(64, 64);
        fs::write(&source_file, &mock_png)?;

        process_single_asset(&source_file, &temp_base).map_err(test_error)?;

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

        let sidecar_content = fs::read_to_string(&sidecar_file)?;
        let sidecar_json: serde_json::Value = serde_json::from_str(&sidecar_content)?;

        assert_eq!(sidecar_json["asset_id"], "blue_slime_enemy");
        assert_eq!(sidecar_json["asset_name"], "Blue Slime Enemy");
        assert_eq!(sidecar_json["category"], "enemies");
        assert_eq!(sidecar_json["runtime_template"], "enemy");
        assert_eq!(sidecar_json["visual"], "blue_slime_enemy.png");
        assert_eq!(sidecar_json["collision"]["size"][0], 64);
        assert_eq!(sidecar_json["collision"]["size"][1], 64);

        let _ = fs::remove_dir_all(&temp_base);
        Ok(())
    }

    #[test]
    fn test_behavior_enrichment() -> Result<(), Box<dyn Error>> {
        let temp_base = std::env::temp_dir().join("kdm_test_repo_enrich");
        let _ = fs::remove_dir_all(&temp_base);
        fs::create_dir_all(&temp_base)?;

        // Test light source enrichment
        let source_file = temp_base.join("yellow_torch.png");
        let mock_png = mock_png_header(32, 32);
        fs::write(&source_file, &mock_png)?;

        process_single_asset(&source_file, &temp_base).map_err(test_error)?;

        let sidecar_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("decorations")
            .join("yellow_torch")
            .join("yellow_torch.json");
        assert!(sidecar_file.exists());

        let sidecar_content = fs::read_to_string(&sidecar_file)?;
        let sidecar_json: serde_json::Value = serde_json::from_str(&sidecar_content)?;

        assert_eq!(
            sidecar_json["placement_logic"]["snapping_type"],
            "free_float"
        );
        assert_eq!(sidecar_json["lighting_logic"]["emits_light"], true);
        assert_eq!(sidecar_json["lighting_logic"]["light_energy"], 1.2);

        // Test boss enemy enrichment
        let boss_file = temp_base.join("dragon_boss.png");
        fs::write(&boss_file, &mock_png)?;
        process_single_asset(&boss_file, &temp_base).map_err(test_error)?;

        let boss_sidecar = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("enemies")
            .join("dragon_boss")
            .join("dragon_boss.json");
        let boss_content = fs::read_to_string(&boss_sidecar)?;
        let boss_json: serde_json::Value = serde_json::from_str(&boss_content)?;

        assert_eq!(boss_json["baseline_attributes"]["max_health"], 500);
        assert_eq!(boss_json["baseline_attributes"]["damage_value"], 25);

        let _ = fs::remove_dir_all(&temp_base);
        Ok(())
    }
}
