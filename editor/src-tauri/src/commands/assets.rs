use super::utils::locate_repo_root;
use base64::{engine::general_purpose, Engine as _};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::BTreeMap;
use std::fs;
use std::path::Path;

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

    let snapping_type = json
        .get("placement_logic")
        .and_then(|p| p.get("snapping_type"))
        .and_then(Value::as_str)
        .map(ToString::to_string);
    let parallax_bucket = json
        .get("placement_logic")
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
            visual: Some("hero_knight.svg".to_string()),
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
            visual: Some("stone_floor.svg".to_string()),
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
            visual: Some(
                "res://data/assets/enemies/red_slime_enemy/red_slime_enemy.png".to_string(),
            ),
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

#[tauri::command]
pub fn load_child_sprite(
    asset_id: String,
    category: String,
) -> Result<Vec<Vec<Vec<String>>>, String> {
    let repo_root = locate_repo_root()?;
    let png_path = repo_root
        .join("engine")
        .join("data")
        .join("assets")
        .join(&category)
        .join(&asset_id)
        .join(format!("{}.png", asset_id));

    let default_grid = vec![vec!["transparent".to_string(); 16]; 16];
    let mut frames_grids = vec![default_grid];

    if !png_path.exists() {
        return Ok(frames_grids);
    }

    let file = fs::File::open(&png_path).map_err(|e| e.to_string())?;
    let decoder = png::Decoder::new(file);
    let mut reader = decoder.read_info().map_err(|e| e.to_string())?;
    let mut buf = vec![0; reader.output_buffer_size()];
    let info = reader.next_frame(&mut buf).map_err(|e| e.to_string())?;

    let img_w = info.width as usize;
    let img_h = info.height as usize;

    if img_w == 0 || img_h == 0 {
        return Ok(frames_grids);
    }

    // Number of 16x16 frames
    let num_frames = (img_w / 16).max(1);
    frames_grids.clear();

    for f_idx in 0..num_frames {
        let mut grid = vec![vec!["transparent".to_string(); 16]; 16];
        let offset_x = f_idx * 16;

        if info.color_type == png::ColorType::Rgba {
            for y in 0..img_h.min(16) {
                for x in 0..16 {
                    let orig_x = offset_x + x;
                    if orig_x >= img_w {
                        continue;
                    }
                    let idx = ((y * img_w + orig_x) * 4) as usize;
                    if idx + 3 < buf.len() {
                        let r = buf[idx];
                        let g = buf[idx + 1];
                        let b = buf[idx + 2];
                        let a = buf[idx + 3];

                        if a > 10 {
                            let hex = format!("#{:02x}{:02x}{:02x}", r, g, b);
                            grid[y][x] = hex;
                        }
                    }
                }
            }
        } else if info.color_type == png::ColorType::Rgb {
            for y in 0..img_h.min(16) {
                for x in 0..16 {
                    let orig_x = offset_x + x;
                    if orig_x >= img_w {
                        continue;
                    }
                    let idx = ((y * img_w + orig_x) * 3) as usize;
                    if idx + 2 < buf.len() {
                        let r = buf[idx];
                        let g = buf[idx + 1];
                        let b = buf[idx + 2];
                        let hex = format!("#{:02x}{:02x}{:02x}", r, g, b);
                        grid[y][x] = hex;
                    }
                }
            }
        }
        frames_grids.push(grid);
    }

    if frames_grids.is_empty() {
        frames_grids.push(vec![vec!["transparent".to_string(); 16]; 16]);
    }
    Ok(frames_grids)
}

#[tauri::command]
pub fn save_child_sprite(
    asset_id: String,
    category: String,
    base64_data: String,
    is_spritesheet: Option<bool>,
    frames: Option<Vec<serde_json::Value>>,
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
                        if x < min_x {
                            min_x = x;
                        }
                        if x > max_x {
                            max_x = x;
                        }
                        if y < min_y {
                            min_y = y;
                        }
                        if y > max_y {
                            max_y = y;
                        }
                    }
                }
            }
        }
    }

    let is_sheet_val = is_spritesheet.unwrap_or(false);

    // Determine final dimensions (skip cropping if it is a spritesheet to maintain frame spacing)
    let (crop_x, crop_y, crop_w, crop_h) = if is_sheet_val {
        (0, 0, img_w, img_h)
    } else if has_pixels {
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
    let mut w = std::io::BufWriter::new(file);

    let mut encoder = png::Encoder::new(&mut w, crop_w as u32, crop_h as u32);
    encoder.set_color(png::ColorType::Rgba);
    encoder.set_depth(png::BitDepth::Eight);
    let mut writer = encoder.write_header().map_err(|e| e.to_string())?;
    writer
        .write_image_data(&cropped_buf)
        .map_err(|e| e.to_string())?;

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

    let mut sidecar_payload = serde_json::json!({
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

    if is_sheet_val {
        sidecar_payload["is_spritesheet"] = serde_json::json!(true);
    }
    if let Some(frs) = frames {
        sidecar_payload["frames"] = serde_json::json!(frs);
    }

    fs::write(
        &sidecar_path,
        serde_json::to_string_pretty(&sidecar_payload)
            .map_err(|err| format!("Failed to serialize sprite sidecar: {err}"))?,
    )
    .map_err(|e| e.to_string())?;

    Ok(format!("Asset {} successfully saved.", asset_id))
}

#[tauri::command]
pub fn save_custom_audio(
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

    let wav_filename = format!("{}_custom.wav", asset_id);
    let wav_path = target_dir.join(&wav_filename);
    fs::write(&wav_path, &decoded_bytes).map_err(|e| e.to_string())?;

    let sidecar_filename = format!("{}.json", asset_id);
    let sidecar_path = target_dir.join(&sidecar_filename);

    if sidecar_path.exists() {
        let sidecar_content = fs::read_to_string(&sidecar_path).map_err(|e| e.to_string())?;
        let mut sidecar_data: serde_json::Value =
            serde_json::from_str(&sidecar_content).map_err(|e| e.to_string())?;

        if let Some(obj) = sidecar_data.as_object_mut() {
            obj.insert(
                "audio_logic".to_string(),
                serde_json::json!({
                    "stream_file": wav_filename,
                    "loop": false,
                    "global_bgm": false
                }),
            );
        }

        fs::write(
            &sidecar_path,
            serde_json::to_string_pretty(&sidecar_data)
                .map_err(|err| format!("Failed to serialize audio sidecar: {err}"))?,
        )
        .map_err(|e| e.to_string())?;
    }

    Ok(format!("Custom SFX for {} successfully saved.", asset_id))
}

fn get_color_from_prompt(prompt: &str) -> &str {
    let p = prompt.to_lowercase();
    if p.contains("red") || p.contains("fire") || p.contains("lava") || p.contains("ruby") || p.contains("hot") {
        "#ff4b4b"
    } else if p.contains("blue") || p.contains("water") || p.contains("ice") || p.contains("sapphire") || p.contains("sky") || p.contains("cold") {
        "#3b82f6"
    } else if p.contains("green") || p.contains("grass") || p.contains("herb") || p.contains("emerald") || p.contains("slime") || p.contains("nature") {
        "#10b981"
    } else if p.contains("yellow") || p.contains("gold") || p.contains("sun") || p.contains("coin") || p.contains("star") {
        "#eab308"
    } else if p.contains("purple") || p.contains("magic") || p.contains("shadow") || p.contains("void") || p.contains("poison") {
        "#8b5cf6"
    } else if p.contains("orange") || p.contains("sunset") || p.contains("autumn") || p.contains("bronze") {
        "#f97316"
    } else if p.contains("pink") || p.contains("love") || p.contains("cute") {
        "#ec4899"
    } else if p.contains("white") || p.contains("snow") || p.contains("cloud") || p.contains("light") {
        "#f8fafc"
    } else if p.contains("black") || p.contains("dark") || p.contains("shadow") {
        "#0f172a"
    } else if p.contains("grey") || p.contains("gray") || p.contains("stone") || p.contains("iron") || p.contains("metal") {
        "#64748b"
    } else {
        "#fbbf24"
    }
}

fn parse_hex_color(hex: &str) -> (u8, u8, u8) {
    let hex = hex.trim_start_matches('#');
    if hex.len() == 6 {
        let r = u8::from_str_radix(&hex[0..2], 16).unwrap_or(0);
        let g = u8::from_str_radix(&hex[2..4], 16).unwrap_or(0);
        let b = u8::from_str_radix(&hex[4..6], 16).unwrap_or(0);
        (r, g, b)
    } else {
        (255, 255, 255)
    }
}

fn generate_procedural_pixel_grid(prompt: &str) -> Vec<Vec<String>> {
    let mut grid = vec![vec!["transparent".to_string(); 16]; 16];
    let p = prompt.to_lowercase();
    let main_color = get_color_from_prompt(&p).to_string();
    let sec_color = if main_color == "#eab308" { "#ff4b4b".to_string() } else { "#eab308".to_string() };
    let outline_color = "#1e293b".to_string();
    let highlight_color = "#ffffff".to_string();

    if p.contains("sword") || p.contains("blade") || p.contains("dagger") || p.contains("saber") || p.contains("weapon") || p.contains("knife") {
        for i in 0..9 {
            let x = 3 + i;
            let y = 12 - i;
            grid[y][x] = main_color.clone();
            if y > 0 && x > 0 {
                grid[y - 1][x] = highlight_color.clone();
            }
        }
        grid[12][3] = sec_color.clone();
        grid[10][5] = sec_color.clone();
        grid[13][2] = "#78350f".to_string();
        grid[14][1] = outline_color.clone();
    } else if p.contains("potion") || p.contains("bottle") || p.contains("flask") || p.contains("elixir") || p.contains("drink") || p.contains("poison") {
        for y in 2..15 {
            for x in 3..13 {
                if y >= 2 && y <= 4 {
                    if x == 6 || x == 9 {
                        grid[y][x] = outline_color.clone();
                    } else if x == 7 || x == 8 {
                        grid[y][x] = "#93c5fd".to_string();
                    }
                }
                if y == 5 {
                    if x == 5 || x == 10 {
                        grid[y][x] = outline_color.clone();
                    } else if x >= 6 && x <= 9 {
                        grid[y][x] = "#93c5fd".to_string();
                    }
                }
                if y >= 6 && y <= 13 {
                    if x == 4 || x == 11 {
                        grid[y][x] = outline_color.clone();
                    } else if x > 4 && x < 11 {
                        if y >= 9 {
                            grid[y][x] = main_color.clone();
                        } else {
                            grid[y][x] = "#93c5fd".to_string();
                        }
                    }
                }
                if y == 14 {
                    if x >= 5 && x <= 10 {
                        grid[y][x] = outline_color.clone();
                    }
                }
            }
        }
        grid[7][6] = highlight_color.clone();
        grid[8][6] = highlight_color.clone();
        grid[1][7] = "#78350f".to_string();
        grid[1][8] = "#78350f".to_string();
    } else if p.contains("gem") || p.contains("crystal") || p.contains("ruby") || p.contains("diamond") || p.contains("jewel") || p.contains("emerald") || p.contains("sapphire") {
        for y in 2..14 {
            for x in 2..14 {
                let dist_x = (x as i32 - 8).abs();
                let dist_y = (y as i32 - 8).abs();
                if dist_x + dist_y <= 6 {
                    if dist_x + dist_y == 6 {
                        grid[y][x] = outline_color.clone();
                    } else {
                        grid[y][x] = main_color.clone();
                    }
                }
            }
        }
        grid[5][7] = highlight_color.clone();
        grid[6][6] = highlight_color.clone();
    } else if p.contains("heart") || p.contains("love") || p.contains("health") || p.contains("life") {
        let heart_pixels = [
            (3, 5), (3, 6), (3, 10), (3, 11),
            (4, 4), (4, 5), (4, 6), (4, 7), (4, 9), (4, 10), (4, 11), (4, 12),
            (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8), (5, 9), (5, 10), (5, 11), (5, 12), (5, 13),
            (6, 3), (6, 4), (6, 5), (6, 6), (6, 7), (6, 8), (6, 9), (6, 10), (6, 11), (6, 12), (6, 13),
            (7, 3), (7, 4), (7, 5), (7, 6), (7, 7), (7, 8), (7, 9), (7, 10), (7, 11), (7, 12), (7, 13),
            (8, 4), (8, 5), (8, 6), (8, 7), (8, 8), (8, 9), (8, 10), (8, 11), (8, 12),
            (9, 5), (9, 6), (9, 7), (9, 8), (9, 9), (9, 10), (9, 11),
            (10, 6), (10, 7), (10, 8), (10, 9), (10, 10),
            (11, 7), (11, 8), (11, 9),
            (12, 8)
        ];
        for &(y, x) in &heart_pixels {
            grid[y][x] = main_color.clone();
        }
        for y in 2..14 {
            for x in 2..14 {
                if grid[y][x] == main_color {
                    let mut is_edge = false;
                    for &(dx, dy) in &[(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let nx = (x as i32 + dx) as usize;
                        let ny = (y as i32 + dy) as usize;
                        if grid[ny][nx] == "transparent" {
                            is_edge = true;
                        }
                    }
                    if is_edge {
                        grid[y][x] = outline_color.clone();
                    }
                }
            }
        }
        for &(y, x) in &heart_pixels {
            if grid[y][x] != outline_color {
                grid[y][x] = main_color.clone();
            }
        }
        grid[5][5] = highlight_color.clone();
        grid[6][5] = highlight_color.clone();
    } else if p.contains("star") || p.contains("sun") || p.contains("sparkle") || p.contains("wish") || p.contains("light") {
        let star_pixels = [
            (2, 8),
            (3, 8),
            (4, 7), (4, 8), (4, 9),
            (5, 7), (5, 8), (5, 9),
            (6, 2), (6, 3), (6, 4), (6, 5), (6, 6), (6, 7), (6, 8), (6, 9), (6, 10), (6, 11), (6, 12), (6, 13), (6, 14),
            (7, 3), (7, 4), (7, 5), (7, 6), (7, 7), (7, 8), (7, 9), (7, 10), (7, 11), (7, 12), (7, 13),
            (8, 4), (8, 5), (8, 6), (8, 7), (8, 8), (8, 9), (8, 10), (8, 11), (8, 12),
            (9, 5), (9, 6), (9, 7), (9, 8), (9, 9), (9, 10), (9, 11),
            (10, 5), (10, 6), (10, 7), (10, 9), (10, 10), (10, 11),
            (11, 4), (11, 5), (11, 11), (11, 12),
            (12, 4), (12, 12)
        ];
        for &(y, x) in &star_pixels {
            grid[y][x] = main_color.clone();
        }
        for y in 1..14 {
            for x in 1..15 {
                if grid[y][x] == main_color {
                    let mut is_edge = false;
                    for &(dx, dy) in &[(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let nx = (x as i32 + dx) as usize;
                        let ny = (y as i32 + dy) as usize;
                        if grid[ny][nx] == "transparent" {
                            is_edge = true;
                        }
                    }
                    if is_edge {
                        grid[y][x] = outline_color.clone();
                    }
                }
            }
        }
        for &(y, x) in &star_pixels {
            if grid[y][x] != outline_color {
                grid[y][x] = main_color.clone();
            }
        }
        grid[5][8] = highlight_color.clone();
    } else if p.contains("shield") || p.contains("buckler") || p.contains("plate") || p.contains("barrier") {
        for y in 2..14 {
            for x in 3..13 {
                let is_edge = x == 3 || x == 12 || y == 2 || (y == 13 && x == 8) || (y == 12 && (x == 7 || x == 9)) || (y == 11 && (x == 6 || x == 10)) || (y == 10 && (x == 5 || x == 11)) || (y == 9 && (x == 4 || x == 12));
                if is_edge {
                    grid[y][x] = outline_color.clone();
                } else {
                    if x >= 4 && x <= 11 && y <= (8 + (11 - x as i32) as usize) && y <= (8 + (x as i32 - 4) as usize) {
                        if x == 7 || x == 8 || y == 7 || y == 8 {
                            grid[y][x] = sec_color.clone();
                        } else {
                            grid[y][x] = main_color.clone();
                        }
                    }
                }
            }
        }
        grid[3][5] = highlight_color.clone();
    } else if p.contains("key") || p.contains("lock") {
        for y in 3..9 {
            for x in 3..9 {
                let dist_x = (x as i32 - 5).abs();
                let dist_y = (y as i32 - 5).abs();
                if dist_x == 2 || dist_y == 2 {
                    grid[y][x] = main_color.clone();
                }
            }
        }
        for i in 0..7 {
            let x = 7 + i;
            let y = 7 + i;
            grid[y][x] = main_color.clone();
        }
        grid[11][13] = main_color.clone();
        grid[12][12] = main_color.clone();
        grid[13][11] = main_color.clone();
        grid[10][12] = main_color.clone();

        for y in 1..15 {
            for x in 1..15 {
                if grid[y][x] == main_color {
                    let mut is_edge = false;
                    for &(dx, dy) in &[(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let nx = (x as i32 + dx) as usize;
                        let ny = (y as i32 + dy) as usize;
                        if grid[ny][nx] == "transparent" {
                            is_edge = true;
                        }
                    }
                    if is_edge {
                        grid[y][x] = outline_color.clone();
                    }
                }
            }
        }
    } else if p.contains("slime") || p.contains("monster") || p.contains("ghost") || p.contains("creature") || p.contains("beast") || p.contains("dragon") || p.contains("enemy") {
        for y in 4..14 {
            for x in 2..14 {
                if y == 4 && (x < 5 || x > 10) { continue; }
                if y == 5 && (x < 4 || x > 11) { continue; }
                if y == 13 && (x < 3 || x > 12) { continue; }
                grid[y][x] = main_color.clone();
            }
        }
        grid[7][5] = "#ffffff".to_string();
        grid[7][6] = "#000000".to_string();
        grid[7][9] = "#ffffff".to_string();
        grid[7][10] = "#000000".to_string();
        grid[10][7] = "#000000".to_string();
        grid[10][8] = "#000000".to_string();
        grid[9][4] = "#ec4899".to_string();
        grid[9][11] = "#ec4899".to_string();

        for y in 3..15 {
            for x in 1..15 {
                if grid[y][x] == main_color {
                    let mut is_edge = false;
                    for &(dx, dy) in &[(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let nx = (x as i32 + dx) as usize;
                        let ny = (y as i32 + dy) as usize;
                        if grid[ny][nx] == "transparent" {
                            is_edge = true;
                        }
                    }
                    if is_edge {
                        grid[y][x] = outline_color.clone();
                    }
                }
            }
        }
    } else if p.contains("block") || p.contains("brick") || p.contains("floor") || p.contains("wall") || p.contains("tile") || p.contains("stone") || p.contains("dirt") {
        for y in 0..16 {
            for x in 0..16 {
                if x == 0 || x == 15 || y == 0 || y == 15 {
                    grid[y][x] = outline_color.clone();
                } else if x == 1 || y == 1 {
                    grid[y][x] = highlight_color.clone();
                } else if x == 14 || y == 14 {
                    grid[y][x] = "#334155".to_string();
                } else {
                    grid[y][x] = main_color.clone();
                }
            }
        }
        if p.contains("brick") {
            for x in 1..15 {
                grid[8][x] = outline_color.clone();
            }
            for y in 1..8 {
                grid[y][8] = outline_color.clone();
            }
            for y in 8..15 {
                grid[y][4] = outline_color.clone();
                grid[y][12] = outline_color.clone();
            }
        }
    } else if p.contains("flower") || p.contains("tree") || p.contains("plant") || p.contains("leaf") || p.contains("bush") {
        for y in 9..15 {
            grid[y][8] = "#10b981".to_string();
        }
        grid[11][7] = "#10b981".to_string();
        grid[12][9] = "#10b981".to_string();
        grid[6][8] = "#eab308".to_string();
        grid[5][8] = main_color.clone();
        grid[7][8] = main_color.clone();
        grid[6][7] = main_color.clone();
        grid[6][9] = main_color.clone();
        grid[5][7] = main_color.clone();
        grid[5][9] = main_color.clone();
        grid[7][7] = main_color.clone();
        grid[7][9] = main_color.clone();
    } else if p.contains("coin") {
        for y in 2..14 {
            for x in 2..14 {
                let dist_x = (x as i32 - 8).abs();
                let dist_y = (y as i32 - 8).abs();
                if dist_x * dist_x + dist_y * dist_y <= 25 {
                    if dist_x * dist_x + dist_y * dist_y >= 20 {
                        grid[y][x] = outline_color.clone();
                    } else if dist_x == 0 || dist_y == 0 {
                        grid[y][x] = highlight_color.clone();
                    } else {
                        grid[y][x] = main_color.clone();
                    }
                }
            }
        }
    } else {
        for y in 3..13 {
            for x in 3..13 {
                if x == 3 || x == 12 || y == 3 || y == 12 {
                    grid[y][x] = outline_color.clone();
                } else if x == 4 || y == 4 {
                    grid[y][x] = highlight_color.clone();
                } else if x == 7 || x == 8 || y == 7 || y == 8 {
                    grid[y][x] = sec_color.clone();
                } else {
                    grid[y][x] = main_color.clone();
                }
            }
        }
    }

    grid
}

#[tauri::command]
pub fn generate_magic_stamp(
    asset_id: String,
    category: String,
    prompt: String,
) -> Result<Vec<Vec<String>>, String> {
    let grid = generate_procedural_pixel_grid(&prompt);
    let repo_root = locate_repo_root()?;
    let target_dir = repo_root
        .join("engine")
        .join("data")
        .join("assets")
        .join(&category)
        .join(&asset_id);

    fs::create_dir_all(&target_dir).map_err(|e| e.to_string())?;

    let mut rgba_buf = vec![0u8; 16 * 16 * 4];
    for y in 0..16 {
        for x in 0..16 {
            let color = &grid[y][x];
            let idx = (y * 16 + x) * 4;
            if color == "transparent" {
                rgba_buf[idx] = 0;
                rgba_buf[idx + 1] = 0;
                rgba_buf[idx + 2] = 0;
                rgba_buf[idx + 3] = 0;
            } else {
                let (r, g, b) = parse_hex_color(color);
                rgba_buf[idx] = r;
                rgba_buf[idx + 1] = g;
                rgba_buf[idx + 2] = b;
                rgba_buf[idx + 3] = 255;
            }
        }
    }

    let png_filename = format!("{}.png", asset_id);
    let png_path = target_dir.join(&png_filename);
    let file = fs::File::create(&png_path).map_err(|e| e.to_string())?;
    let mut w = std::io::BufWriter::new(file);

    let mut encoder = png::Encoder::new(&mut w, 16, 16);
    encoder.set_color(png::ColorType::Rgba);
    encoder.set_depth(png::BitDepth::Eight);
    let mut writer = encoder.write_header().map_err(|e| e.to_string())?;
    writer
        .write_image_data(&rgba_buf)
        .map_err(|e| e.to_string())?;

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
        _ => (48, 48),
    };

    let sidecar_filename = format!("{}.json", asset_id);
    let sidecar_path = target_dir.join(&sidecar_filename);

    let sidecar_payload = serde_json::json!({
        "schema_version": 1,
        "asset_id": asset_id,
        "asset_name": format!("Magic {}", asset_id),
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
        serde_json::to_string_pretty(&sidecar_payload)
            .map_err(|err| format!("Failed to serialize sprite sidecar: {err}"))?,
    )
    .map_err(|e| e.to_string())?;

    Ok(grid)
}

