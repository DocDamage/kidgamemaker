use std::fs;
use std::io::Read;
use std::path::Path;

pub fn read_image_dimensions(path: &Path) -> Option<(u32, u32)> {
    let ext = path.extension()?.to_str()?.to_lowercase();
    match ext.as_str() {
        "png" => read_png_dimensions(path),
        "jpg" | "jpeg" => read_jpeg_dimensions(path),
        "webp" => read_webp_dimensions(path),
        "svg" => read_svg_dimensions(path),
        _ => None,
    }
}

pub fn read_png_dimensions(path: &Path) -> Option<(u32, u32)> {
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

pub fn read_jpeg_dimensions(path: &Path) -> Option<(u32, u32)> {
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

pub fn read_webp_dimensions(path: &Path) -> Option<(u32, u32)> {
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

pub fn read_svg_dimensions(path: &Path) -> Option<(u32, u32)> {
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
