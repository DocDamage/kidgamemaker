use super::dimensions::read_image_dimensions;
use crate::slicer::SpriteFrame;
use std::fs;
use std::path::{Path, PathBuf};

pub fn process_single_asset(file_path: &Path, repo_root: &Path) -> Result<PathBuf, String> {
    let filename = file_path
        .file_name()
        .and_then(|n| n.to_str())
        .ok_or("Invalid filename")?;
    let asset_id = file_path
        .file_stem()
        .and_then(|s| s.to_str())
        .ok_or("Invalid asset stem")?;

    let (category, template, snapping, parallax) = classify_asset(filename);

    let lower_name = filename.to_lowercase();
    let is_audio = lower_name.ends_with(".wav")
        || lower_name.ends_with(".mp3")
        || lower_name.ends_with(".ogg");

    // Audio assets are routed to a dedicated sidecar with audio_logic.
    // They skip PNG slicing and image-dimension detection entirely.
    if is_audio {
        let dest_dir = repo_root
            .join("engine")
            .join("data")
            .join("assets")
            .join(category)
            .join(asset_id);
        fs::create_dir_all(&dest_dir).map_err(|e| e.to_string())?;

        let target_file_path = dest_dir.join(filename);
        fs::copy(file_path, &target_file_path).map_err(|err| err.to_string())?;

        let asset_name = humanize_name(asset_id);
        let tags = extract_tags(asset_id);
        let loop_audio = lower_name.contains("bgm")
            || lower_name.contains("music")
            || lower_name.contains("ambient")
            || lower_name.contains("loop");

        let sidecar_value = serde_json::json!({
            "schema_version": 1,
            "asset_id": asset_id,
            "asset_name": asset_name,
            "category": category,
            "runtime_template": template,
            "visual": null,
            "visual_tags": tags,
            "audio_logic": {
                "stream_file": filename,
                "loop": loop_audio,
                "global_bgm": loop_audio
            }
        });

        let sidecar_content = serde_json::to_string_pretty(&sidecar_value)
            .map_err(|err| format!("Failed to serialize audio sidecar for {asset_id}: {err}"))?;
        let sidecar_path = dest_dir.join(format!("{}.json", asset_id));
        fs::write(&sidecar_path, sidecar_content).map_err(|err| err.to_string())?;

        return Ok(target_file_path);
    }

    // --- Image asset path below ---

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

    if lower_name.ends_with(".png") {
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
            frames = vec![SpriteFrame { x: 0, y: 0, w, h }];
        }
    } else if let Some((w, h)) = read_image_dimensions(file_path) {
        width = w;
        height = h;
        frames = vec![SpriteFrame { x: 0, y: 0, w, h }];
    } else {
        frames = vec![SpriteFrame {
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

pub fn classify_asset(filename: &str) -> (&'static str, &'static str, &'static str, &'static str) {
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

pub fn extract_tags(stem: &str) -> Vec<String> {
    stem.split(|c: char| c == '_' || c == '-' || c == ' ')
        .filter(|part| !part.is_empty())
        .map(|part| part.to_lowercase())
        .collect()
}

pub fn humanize_name(stem: &str) -> String {
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
