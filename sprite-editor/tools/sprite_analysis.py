from __future__ import annotations

import re
from pathlib import Path
import numpy as np

try:
    from tools.sprite_cutter_types import DetectedSprite
except ModuleNotFoundError:
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_cutter_types import DetectedSprite


def safe_name(value: str) -> str:
    value = re.sub(r"[^a-zA-Z0-9_]+", "_", value.strip().lower())
    return re.sub(r"_+", "_", value).strip("_")


def _source_taxonomy_tokens(source_path: Path, sheet_stem: str) -> set[str]:
    ignored = {"g", "all", "2d", "assets", "stay", "here", "_organized_sprites", "_extracted_archives", "sprites", "organized", "separated"}
    text = " ".join([*source_path.parts, sheet_stem]).lower()
    parts = re.split(r"[^a-z0-9]+", text)
    return {part for part in parts if part and part not in ignored}


def classify_sprite(source_path: Path | str, sheet_stem: str, x: int, y: int, w: int, h: int, foreground_pixels: int) -> str:
    tokens = _source_taxonomy_tokens(Path(source_path), sheet_stem)
    if tokens & {"tree", "trees", "bush", "bushes", "plant", "plants", "grass", "flower", "flowers", "foliage", "vegetation"}:
        return "vegetation_and_trees"
    if tokens & {"character", "characters", "hero", "knight", "enemy", "enemies", "zombie", "npc", "player", "monster", "robot", "bots"}:
        return "characters_and_creatures"
    if tokens & {"portrait", "portraits", "face", "faces", "avatar", "avatars"}:
        return "portraits_and_faces"
    if tokens & {"font", "fonts", "ui", "gui", "icon", "icons", "button", "buttons", "cursor", "cursors"}:
        return "ui_icons_and_fonts"
    if tokens & {"tile", "tiles", "tileset", "autotile", "auto", "floor", "floors", "wall", "walls", "terrain", "ground"}:
        return "tiles_and_terrain"
    if tokens & {"background", "backgrounds", "parallax", "sky", "skies"}:
        return "backgrounds_and_parallax"
    if tokens & {"weapon", "weapons", "sword", "swords", "gun", "guns", "projectile", "projectiles"}:
        return "weapons_and_projectiles"
    if tokens & {"object", "objects", "prop", "props", "item", "items", "crate", "crates", "barrel", "barrels", "chest", "chests"}:
        return "props_and_items"

    area = w * h
    fill = foreground_pixels / max(1, area)
    aspect = w / max(1, h)

    if (w >= 300 and h >= 160) or (h >= 300 and w >= 300):
        return "environment_and_large_composites"
    if w >= 110 and h <= 105:
        return "wide_cases_and_counters"
    if h >= 110 and w <= 100:
        return "tall_shelves_and_racks"
    if (w >= 135 and h >= 88) or area >= 18_000:
        return "large_fixtures"
    if 0.75 <= aspect <= 1.35 and 34 <= w <= 78 and 30 <= h <= 78 and fill >= 0.23:
        return "baskets_crates_and_bins"
    if w <= 52 and h <= 52:
        if y <= 150:
            return "signs_and_labels"
        return "small_goods_and_debris"
    if w <= 85 and h <= 80:
        return "medium_props"
    return "fixtures_and_displays"


def should_use_full_alpha(category: str, w: int, h: int, foreground_pixels: int) -> bool:
    fill = foreground_pixels / max(1, w * h)
    if category in {"environment_and_large_composites", "large_fixtures"}:
        return fill >= 0.18
    if category in {"wide_cases_and_counters", "tall_shelves_and_racks", "fixtures_and_displays"}:
        return fill >= 0.38
    return False


def is_partial_detection(detection: DetectedSprite, sheet_width: int, sheet_height: int) -> bool:
    return detection.x <= 0 or detection.y <= 0 or detection.right >= sheet_width or detection.bottom >= sheet_height


def dominant_colors(rgba: np.ndarray, max_colors: int = 5) -> list[str]:
    alpha = rgba[:, :, 3]
    visible = rgba[:, :, :3][alpha > 20]
    if visible.size == 0:
        return []

    quantized = (visible // 16) * 16
    colors, counts = np.unique(quantized.reshape(-1, 3), axis=0, return_counts=True)
    order = np.argsort(counts)[::-1][:max_colors]
    return [f"#{int(colors[index][0]):02x}{int(colors[index][1]):02x}{int(colors[index][2]):02x}" for index in order]


def analyze_sprite_pixels(rgba: np.ndarray) -> tuple[float, float, list[str]]:
    height, width = rgba.shape[:2]
    alpha = rgba[:, :, 3]
    transparency_ratio = 1.0 - float(np.count_nonzero(alpha > 20) / max(1, width * height))
    aspect_ratio = float(width / max(1, height))
    return round(transparency_ratio, 4), round(aspect_ratio, 4), dominant_colors(rgba)


def assess_sprite_quality(
    detection: DetectedSprite,
    sheet_width: int,
    sheet_height: int,
    transparency_ratio: float,
    aspect_ratio: float,
) -> tuple[float, list[str], str]:
    flags: list[str] = []
    score = 1.0

    if is_partial_detection(detection, sheet_width, sheet_height):
        flags.append("touches_edge")
        score -= 0.25
    if detection.foreground_pixels < 96 or detection.width < 8 or detection.height < 8:
        flags.append("tiny_component")
        score -= 0.2
    if transparency_ratio >= 0.78:
        flags.append("transparent_heavy")
        score -= 0.15
    if aspect_ratio < 0.25 or aspect_ratio > 4.0:
        flags.append("odd_aspect")
        score -= 0.15
    if detection.width >= sheet_width * 0.8 or detection.height >= sheet_height * 0.8:
        flags.append("large_region")
        score -= 0.1

    confidence = round(max(0.0, min(1.0, score)), 3)
    review_status = "needs_review" if flags else "approved"
    return confidence, flags, review_status
