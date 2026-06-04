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
