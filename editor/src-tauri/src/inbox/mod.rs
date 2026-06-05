pub mod dimensions;
pub mod ingest;

use std::fs;
use std::io;
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
            match ingest::process_single_asset(&path, repo_root) {
                Ok(target_path) => {
                    println!(
                        "Successfully imported asset: {} to {}",
                        name,
                        target_path.display()
                    );
                    let _ = fs::remove_file(&path);
                }
                Err(err) => {
                    eprintln!("Failed to ingest asset {}: {}", name, err);
                    // Rename to .failed so the watcher doesn't retry endlessly
                    let failed_path = path.with_extension(
                        format!("{}.failed", path.extension().and_then(|e| e.to_str()).unwrap_or(""))
                    );
                    let _ = fs::rename(&path, &failed_path);
                    eprintln!("Renamed {} to {} to prevent retry loop", name, failed_path.display());
                }
            }
        }
    }
    Ok(())
}

fn process_extracted_files(extracted_dir: &Path, repo_root: &Path) -> Result<(), String> {
    let mut files_to_process = Vec::new();
    collect_files_recursive(extracted_dir, &mut files_to_process)?;

    let mut errors = Vec::new();
    for file_path in files_to_process {
        let name = file_path.file_name().and_then(|n| n.to_str()).unwrap_or("");
        if is_supported_asset(name) {
            if let Err(err) = ingest::process_single_asset(&file_path, repo_root) {
                errors.push(format!("{}: {}", name, err));
            }
        }
    }

    if !errors.is_empty() {
        return Err(format!("Failed to ingest assets inside package: {}", errors.join(", ")));
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
            ingest::classify_asset("hero_knight.png"),
            ("heroes", "player", "gravity_snap", "play_layer")
        );
        assert_eq!(
            ingest::classify_asset("slime_enemy.png"),
            ("enemies", "enemy", "gravity_snap", "play_layer")
        );
        assert_eq!(
            ingest::classify_asset("stone_floor.png"),
            ("terrain", "terrain", "edge_to_edge", "play_layer")
        );
        assert_eq!(
            ingest::classify_asset("ruby_coin.png"),
            ("collectibles", "collectible", "free_float", "play_layer")
        );
        assert_eq!(
            ingest::classify_asset("bg_tree.png"),
            ("decorations", "decoration", "free_float", "deep_background")
        );
        assert_eq!(
            ingest::classify_asset("gold_portal.png"),
            ("portals", "portal", "gravity_snap", "play_layer")
        );
    }

    #[test]
    fn test_humanize_name() {
        assert_eq!(ingest::humanize_name("red_slime_enemy"), "Red Slime Enemy");
        assert_eq!(ingest::humanize_name("hero-knight"), "Hero Knight");
        assert_eq!(ingest::humanize_name("stone floor"), "Stone Floor");
    }

    #[test]
    fn test_extract_tags() {
        assert_eq!(
            ingest::extract_tags("red_slime_enemy"),
            vec!["red", "slime", "enemy"]
        );
        assert_eq!(ingest::extract_tags("hero-knight"), vec!["hero", "knight"]);
    }

    #[test]
    fn test_read_png_dimensions() -> Result<(), Box<dyn Error>> {
        let mock_png = mock_png_header(64, 32);

        let temp_dir = std::env::temp_dir();
        let test_file = temp_dir.join("test_mock.png");
        fs::write(&test_file, &mock_png)?;

        let dims = dimensions::read_png_dimensions(&test_file);
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
        assert_eq!(dimensions::read_image_dimensions(&jpg_file), Some((80, 42)));
        let _ = fs::remove_file(&jpg_file);

        let webp_file = temp_dir.join("test_mock.webp");
        let mut mock_webp = vec![0u8; 30];
        mock_webp[0..4].copy_from_slice(b"RIFF");
        mock_webp[8..12].copy_from_slice(b"WEBP");
        mock_webp[12..16].copy_from_slice(b"VP8X");
        mock_webp[24..27].copy_from_slice(&(95u32).to_le_bytes()[0..3]);
        mock_webp[27..30].copy_from_slice(&(47u32).to_le_bytes()[0..3]);
        fs::write(&webp_file, &mock_webp)?;
        assert_eq!(dimensions::read_image_dimensions(&webp_file), Some((96, 48)));
        let _ = fs::remove_file(&webp_file);

        let svg_file = temp_dir.join("test_mock.svg");
        fs::write(
            &svg_file,
            r#"<svg xmlns="http://www.w3.org/2000/svg" width="128px" height="64px"></svg>"#,
        )?;
        assert_eq!(dimensions::read_image_dimensions(&svg_file), Some((128, 64)));
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

        ingest::process_single_asset(&source_file, &temp_base).map_err(test_error)?;

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

        ingest::process_single_asset(&source_file, &temp_base).map_err(test_error)?;

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

        ingest::process_single_asset(&source_file, &temp_base).map_err(test_error)?;

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
        ingest::process_single_asset(&boss_file, &temp_base).map_err(test_error)?;

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

    #[test]
    fn test_process_single_audio_asset() -> Result<(), Box<dyn Error>> {
        let temp_base = std::env::temp_dir().join("kdm_test_repo_audio");
        let _ = fs::remove_dir_all(&temp_base);
        fs::create_dir_all(&temp_base)?;

        let source_file = temp_base.join("jungle_bgm.wav");
        // A minimal dummy wav header (at least 44 bytes)
        let mut mock_wav = vec![0u8; 100];
        mock_wav[0..4].copy_from_slice(b"RIFF");
        mock_wav[8..12].copy_from_slice(b"WAVE");
        fs::write(&source_file, &mock_wav)?;

        ingest::process_single_asset(&source_file, &temp_base).map_err(test_error)?;

        let dest_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("decorations")
            .join("jungle_bgm")
            .join("jungle_bgm.wav");
        assert!(dest_file.exists());

        let sidecar_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("decorations")
            .join("jungle_bgm")
            .join("jungle_bgm.json");
        assert!(sidecar_file.exists());

        let sidecar_content = fs::read_to_string(&sidecar_file)?;
        let sidecar_json: serde_json::Value = serde_json::from_str(&sidecar_content)?;

        assert_eq!(sidecar_json["asset_id"], "jungle_bgm");
        assert_eq!(sidecar_json["asset_name"], "Jungle Bgm");
        assert_eq!(sidecar_json["category"], "decorations");
        assert_eq!(sidecar_json["runtime_template"], "decoration");
        assert_eq!(sidecar_json["visual"], serde_json::Value::Null);
        assert_eq!(sidecar_json["audio_logic"]["stream_file"], "jungle_bgm.wav");
        assert_eq!(sidecar_json["audio_logic"]["loop"], true);
        assert_eq!(sidecar_json["audio_logic"]["global_bgm"], true);

        let _ = fs::remove_dir_all(&temp_base);
        Ok(())
    }

    fn create_mock_png_bytes(
        width: u32,
        height: u32,
        active_rects: &[(u32, u32, u32, u32)],
    ) -> Result<Vec<u8>, Box<dyn Error>> {
        let mut pixels = vec![0u8; (width * height * 4) as usize];
        for &(rx, ry, rw, rh) in active_rects {
            for y in ry..(ry + rh) {
                for x in rx..(rx + rw) {
                    let idx = (y * width + x) as usize;
                    pixels[idx * 4] = 255;
                    pixels[idx * 4 + 1] = 0;
                    pixels[idx * 4 + 2] = 0;
                    pixels[idx * 4 + 3] = 255;
                }
            }
        }
        let mut file_bytes = Vec::new();
        {
            let mut encoder = png::Encoder::new(&mut file_bytes, width, height);
            encoder.set_color(png::ColorType::Rgba);
            encoder.set_depth(png::BitDepth::Eight);
            let mut writer = encoder.write_header()?;
            writer.write_image_data(&pixels)?;
        }
        Ok(file_bytes)
    }

    #[test]
    fn test_process_spritesheet_tile_slicing() -> Result<(), Box<dyn Error>> {
        let temp_base = std::env::temp_dir().join("kdm_test_repo_spritesheet");
        let _ = fs::remove_dir_all(&temp_base);
        fs::create_dir_all(&temp_base)?;

        // Create 2 uniform components: one at (0,0) size 16x16, and one at (16,0) size 16x16 on a 32x16 image
        let bytes = create_mock_png_bytes(32, 16, &[(0, 0, 16, 16), (16, 0, 16, 16)])?;
        let source_file = temp_base.join("mossy_stones_sheet.png");
        fs::write(&source_file, &bytes)?;

        ingest::process_single_asset(&source_file, &temp_base).map_err(test_error)?;

        // 1. Verify original spritesheet asset exists
        let orig_dest_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("terrain")
            .join("mossy_stones_sheet")
            .join("mossy_stones_sheet.png");
        assert!(orig_dest_file.exists());

        // 2. Verify extracted individual tile assets exist
        let tile0_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("terrain")
            .join("mossy_stones_sheet_tile_0")
            .join("mossy_stones_sheet_tile_0.png");
        assert!(tile0_file.exists());

        let tile1_file = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("terrain")
            .join("mossy_stones_sheet_tile_1")
            .join("mossy_stones_sheet_tile_1.png");
        assert!(tile1_file.exists());

        // Verify sidecar for tile 0
        let tile0_sidecar = temp_base
            .join("engine")
            .join("data")
            .join("assets")
            .join("terrain")
            .join("mossy_stones_sheet_tile_0")
            .join("mossy_stones_sheet_tile_0.json");
        assert!(tile0_sidecar.exists());

        let content = fs::read_to_string(&tile0_sidecar)?;
        let json: serde_json::Value = serde_json::from_str(&content)?;
        assert_eq!(json["asset_id"], "mossy_stones_sheet_tile_0");
        assert_eq!(json["is_spritesheet"], false);
        assert_eq!(json["frames"][0]["w"], 16);
        assert_eq!(json["frames"][0]["h"], 16);

        let _ = fs::remove_dir_all(&temp_base);
        Ok(())
    }
}

