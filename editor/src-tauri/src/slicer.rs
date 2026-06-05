use serde::{Deserialize, Serialize};
use std::collections::VecDeque;
use std::fs::File;
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct SpriteFrame {
    pub x: u32,
    pub y: u32,
    pub w: u32,
    pub h: u32,
}

pub struct SlicingResult {
    pub frames: Vec<SpriteFrame>,
    pub is_spritesheet: bool,
    pub is_uniform: bool,
    pub grid_cell_size: Option<u32>,
    pub confidence: f32,
}

pub fn slice_sprite_sheet(path: &Path, category: &str) -> Result<SlicingResult, String> {
    let (width, height, rgba) = load_png_pixels(path)?;

    // 1. Find connected components using BFS
    let cc_frames = find_connected_components(width, height, &rgba);

    // 2. Perform uniform-grid analysis
    let (best_size, grid_score) = detect_uniform_grid(width, height, &rgba, &cc_frames, category);

    // 3. Extract frames based on analysis
    let mut frames = Vec::new();
    let is_uniform;
    let grid_cell_size;
    let confidence;

    if let Some(size) = best_size {
        is_uniform = true;
        grid_cell_size = Some(size);
        confidence = grid_score;

        let cols = width / size;
        let rows = height / size;

        for r in 0..rows {
            for c in 0..cols {
                let cell_x = c * size;
                let cell_y = r * size;

                if is_cell_occupied(cell_x, cell_y, size, width, &rgba) {
                    frames.push(SpriteFrame {
                        x: cell_x,
                        y: cell_y,
                        w: size,
                        h: size,
                    });
                }
            }
        }
    } else {
        is_uniform = false;
        grid_cell_size = None;

        if cc_frames.is_empty() {
            confidence = 1.0;
        } else {
            // Sort organic bounding boxes top-to-bottom, left-to-right
            let mut sorted = cc_frames;
            sort_sprite_frames(&mut sorted);
            frames = sorted;

            // Calculate confidence: higher if all CC boxes have similar sizes
            confidence = calculate_organic_confidence(&frames);
        }
    }

    let is_spritesheet = frames.len() > 1;

    // Apply manual/single-frame fallback if confidence is low
    if confidence < 0.6 {
        println!(
            "Slicing confidence too low ({:.2}). Falling back to single frame.",
            confidence
        );
        Ok(SlicingResult {
            frames: vec![SpriteFrame {
                x: 0,
                y: 0,
                w: width,
                h: height,
            }],
            is_spritesheet: false,
            is_uniform: false,
            grid_cell_size: None,
            confidence,
        })
    } else {
        // If no frames detected at all, default to single frame
        if frames.is_empty() {
            Ok(SlicingResult {
                frames: vec![SpriteFrame {
                    x: 0,
                    y: 0,
                    w: width,
                    h: height,
                }],
                is_spritesheet: false,
                is_uniform: false,
                grid_cell_size: None,
                confidence: 1.0,
            })
        } else {
            Ok(SlicingResult {
                frames,
                is_spritesheet,
                is_uniform,
                grid_cell_size,
                confidence,
            })
        }
    }
}

pub fn load_png_pixels(path: &Path) -> Result<(u32, u32, Vec<u8>), String> {
    let file = File::open(path).map_err(|e| format!("Failed to open file: {e}"))?;
    let mut decoder = png::Decoder::new(file);
    decoder.set_transformations(png::Transformations::EXPAND);

    let mut reader = decoder
        .read_info()
        .map_err(|e| format!("Failed to read PNG info: {e}"))?;
    let mut buf = vec![0; reader.output_buffer_size()];
    let info = reader
        .next_frame(&mut buf)
        .map_err(|e| format!("Failed to read PNG frame: {e}"))?;

    let bytes = &buf[..info.buffer_size()];
    let width = info.width;
    let height = info.height;

    let mut rgba = Vec::with_capacity((width * height * 4) as usize);
    match info.color_type {
        png::ColorType::Rgba => {
            rgba.extend_from_slice(bytes);
        }
        png::ColorType::Rgb => {
            for chunk in bytes.chunks_exact(3) {
                rgba.push(chunk[0]);
                rgba.push(chunk[1]);
                rgba.push(chunk[2]);
                rgba.push(255);
            }
        }
        png::ColorType::Grayscale => {
            for &v in bytes {
                rgba.push(v);
                rgba.push(v);
                rgba.push(v);
                rgba.push(255);
            }
        }
        png::ColorType::GrayscaleAlpha => {
            for chunk in bytes.chunks_exact(2) {
                let v = chunk[0];
                let a = chunk[1];
                rgba.push(v);
                rgba.push(v);
                rgba.push(v);
                rgba.push(a);
            }
        }
        _ => return Err("Unsupported PNG color format".to_string()),
    }

    Ok((width, height, rgba))
}

fn find_connected_components(width: u32, height: u32, rgba: &[u8]) -> Vec<SpriteFrame> {
    let mut visited = vec![false; (width * height) as usize];
    let mut components = Vec::new();

    for y in 0..height {
        for x in 0..width {
            let idx = (y * width + x) as usize;
            if visited[idx] {
                continue;
            }

            let alpha = rgba[idx * 4 + 3];
            if alpha <= 10 {
                visited[idx] = true;
                continue;
            }

            // BFS Flood Fill
            let mut min_x = x;
            let mut max_x = x;
            let mut min_y = y;
            let mut max_y = y;

            let mut queue = VecDeque::new();
            queue.push_back((x, y));
            visited[idx] = true;

            while let Some((cx, cy)) = queue.pop_front() {
                for dy in -1..=1 {
                    for dx in -1..=1 {
                        if dx == 0 && dy == 0 {
                            continue;
                        }
                        let nx = cx as i32 + dx;
                        let ny = cy as i32 + dy;

                        if nx >= 0 && nx < width as i32 && ny >= 0 && ny < height as i32 {
                            let nx = nx as u32;
                            let ny = ny as u32;
                            let nidx = (ny * width + nx) as usize;

                            if !visited[nidx] {
                                let nalpha = rgba[nidx * 4 + 3];
                                if nalpha > 10 {
                                    visited[nidx] = true;
                                    queue.push_back((nx, ny));

                                    min_x = min_x.min(nx);
                                    max_x = max_x.max(nx);
                                    min_y = min_y.min(ny);
                                    max_y = max_y.max(ny);
                                } else {
                                    visited[nidx] = true;
                                }
                            }
                        }
                    }
                }
            }

            let w = max_x - min_x + 1;
            let h = max_y - min_y + 1;

            // Filter small noise
            if w >= 4 && h >= 4 {
                components.push(SpriteFrame {
                    x: min_x,
                    y: min_y,
                    w,
                    h,
                });
            }
        }
    }

    components
}

fn detect_uniform_grid(
    width: u32,
    height: u32,
    rgba: &[u8],
    cc_frames: &[SpriteFrame],
    category: &str,
) -> (Option<u32>, f32) {
    if category.to_lowercase() == "terrain" {
        if width % 32 == 0 && height % 32 == 0 {
            return (Some(32), 1.0);
        } else if width % 16 == 0 && height % 16 == 0 {
            return (Some(16), 1.0);
        }
    }

    if cc_frames.is_empty() {
        return (None, 1.0);
    }

    let candidate_sizes = [16, 32, 48, 64, 128];
    let mut best_size = None;
    let mut best_score = 0.0;

    for &size in &candidate_sizes {
        if width % size == 0 && height % size == 0 {
            let mut fits_count = 0;
            let mut occupied_cells_count = 0;

            let cols = width / size;
            let rows = height / size;

            for r in 0..rows {
                for c in 0..cols {
                    if is_cell_occupied(c * size, r * size, size, width, rgba) {
                        occupied_cells_count += 1;
                    }
                }
            }

            for cc in cc_frames {
                if cc.w <= size && cc.h <= size {
                    fits_count += 1;
                }
            }

            let fit_ratio = fits_count as f32 / cc_frames.len() as f32;

            if fit_ratio > 0.85 && occupied_cells_count > 0 {
                let score = fit_ratio * 0.7 + 0.3;
                if score > best_score {
                    best_score = score;
                    best_size = Some(size);
                }
            }
        }
    }

    (best_size, best_score)
}

fn is_cell_occupied(cell_x: u32, cell_y: u32, size: u32, width: u32, rgba: &[u8]) -> bool {
    for cy in cell_y..(cell_y + size) {
        for cx in cell_x..(cell_x + size) {
            let idx = (cy * width + cx) as usize;
            if rgba[idx * 4 + 3] > 10 {
                return true;
            }
        }
    }
    false
}

fn sort_sprite_frames(frames: &mut [SpriteFrame]) {
    frames.sort_by(|a, b| {
        let avg_h = (a.h + b.h) as i32 / 2;
        let diff_y = (a.y as i32 - b.y as i32).abs();

        if diff_y < avg_h / 2 {
            a.x.cmp(&b.x)
        } else {
            a.y.cmp(&b.y)
        }
    });
}

fn calculate_organic_confidence(frames: &[SpriteFrame]) -> f32 {
    if frames.len() <= 1 {
        return 1.0;
    }

    // Measure variance in frame dimensions
    let mut total_w = 0;
    let mut total_h = 0;
    for f in frames {
        total_w += f.w;
        total_h += f.h;
    }

    let avg_w = total_w as f32 / frames.len() as f32;
    let avg_h = total_h as f32 / frames.len() as f32;

    let mut dev_w = 0.0;
    let mut dev_h = 0.0;
    for f in frames {
        dev_w += (f.w as f32 - avg_w).abs();
        dev_h += (f.h as f32 - avg_h).abs();
    }

    let var_w = dev_w / frames.len() as f32 / avg_w;
    let var_h = dev_h / frames.len() as f32 / avg_h;

    // Confidence drops as variance increases
    let variance = (var_w + var_h) / 2.0;
    (1.0 - variance * 2.0).max(0.1).min(1.0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::error::Error;
    use std::fs;

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
                    pixels[idx * 4] = 255; // R
                    pixels[idx * 4 + 1] = 0; // G
                    pixels[idx * 4 + 2] = 0; // B
                    pixels[idx * 4 + 3] = 255; // A (opaque)
                }
            }
        }

        // Compress pixels to valid PNG file bytes
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
    fn test_bfs_connected_components() -> Result<(), Box<dyn Error>> {
        // Create 2 components: one at (4,4) size 10x10, and one at (20,20) size 8x8
        let bytes = create_mock_png_bytes(32, 32, &[(4, 4, 10, 10), (20, 20, 8, 8)])?;

        let temp = std::env::temp_dir().join("test_bfs.png");
        fs::write(&temp, &bytes)?;

        let (w, h, rgba) = load_png_pixels(&temp)?;
        let _ = fs::remove_file(&temp);

        assert_eq!(w, 32);
        assert_eq!(h, 32);

        let mut comps = find_connected_components(w, h, &rgba);
        sort_sprite_frames(&mut comps);

        assert_eq!(comps.len(), 2);
        assert_eq!(
            comps[0],
            SpriteFrame {
                x: 4,
                y: 4,
                w: 10,
                h: 10
            }
        );
        assert_eq!(
            comps[1],
            SpriteFrame {
                x: 20,
                y: 20,
                w: 8,
                h: 8
            }
        );
        Ok(())
    }

    #[test]
    fn test_uniform_grid_detection() -> Result<(), Box<dyn Error>> {
        // Grid size 16x16 on a 48x16 canvas. Occupy cells 0 and 2.
        let bytes = create_mock_png_bytes(
            48,
            16,
            &[
                (2, 2, 12, 12),  // Cell 0: occupied
                (34, 2, 12, 12), // Cell 2: occupied
            ],
        )?;

        let temp = std::env::temp_dir().join("test_uniform.png");
        fs::write(&temp, &bytes)?;

        let res = slice_sprite_sheet(&temp, "enemies")?;
        let _ = fs::remove_file(&temp);

        assert!(res.is_uniform);
        assert_eq!(res.grid_cell_size, Some(16));
        assert_eq!(res.frames.len(), 2);
        assert_eq!(
            res.frames[0],
            SpriteFrame {
                x: 0,
                y: 0,
                w: 16,
                h: 16
            }
        );
        assert_eq!(
            res.frames[1],
            SpriteFrame {
                x: 32,
                y: 0,
                w: 16,
                h: 16
            }
        );
        Ok(())
    }

    #[test]
    fn test_organic_sorting() {
        let mut frames = vec![
            SpriteFrame {
                x: 20,
                y: 22,
                w: 10,
                h: 10,
            },
            SpriteFrame {
                x: 5,
                y: 5,
                w: 10,
                h: 10,
            },
            SpriteFrame {
                x: 5,
                y: 20,
                w: 10,
                h: 10,
            },
            SpriteFrame {
                x: 20,
                y: 5,
                w: 10,
                h: 10,
            },
        ];

        sort_sprite_frames(&mut frames);

        // Should be sorted:
        // 1. (5,5)
        // 2. (20,5)
        // 3. (5,20)
        // 4. (20,22) (Y coordinates 20 and 22 are close, so sorted by X)
        assert_eq!(frames[0].x, 5);
        assert_eq!(frames[0].y, 5);
        assert_eq!(frames[1].x, 20);
        assert_eq!(frames[1].y, 5);
        assert_eq!(frames[2].x, 5);
        assert_eq!(frames[2].y, 20);
        assert_eq!(frames[3].x, 20);
        assert_eq!(frames[3].y, 22);
    }
}
