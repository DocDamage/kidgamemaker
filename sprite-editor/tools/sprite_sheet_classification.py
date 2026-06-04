from __future__ import annotations

import os
from pathlib import Path
import numpy as np
from PIL import Image

try:
    from tools.sprite_cutter_types import DetectedSprite, DetectionSettings
    from tools.sprite_background_detector import detect_background, grouped_components, extract_detections
except ModuleNotFoundError:
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_cutter_types import DetectedSprite, DetectionSettings
    from tools.sprite_background_detector import detect_background, grouped_components, extract_detections


def coefficient_of_variation(values: list[int]) -> float:
    if not values:
        return 0.0
    mean = float(np.mean(values))
    if mean == 0:
        return 0.0
    return float(np.std(values) / mean)


def cluster_animation_rows(detections: list[DetectedSprite]) -> list[list[DetectedSprite]]:
    if not detections:
        return []

    median_height = float(np.median([detection.height for detection in detections]))
    row_tolerance = max(8.0, median_height * 0.65)
    rows: list[list[DetectedSprite]] = []
    row_centers: list[float] = []

    for detection in sorted(detections, key=lambda item: (item.center_y, item.x)):
        best_index: int | None = None
        best_distance = row_tolerance + 1
        for index, center in enumerate(row_centers):
            distance = abs(detection.center_y - center)
            if distance <= row_tolerance and distance < best_distance:
                best_index = index
                best_distance = distance

        if best_index is None:
            rows.append([detection])
            row_centers.append(detection.center_y)
        else:
            rows[best_index].append(detection)
            row_centers[best_index] = float(np.mean([item.center_y for item in rows[best_index]]))

    rows.sort(key=lambda row: min(item.y for item in row))
    for row in rows:
        row.sort(key=lambda item: item.x)
    return rows


def row_is_animation_like(row: list[DetectedSprite]) -> bool:
    if len(row) < 2:
        return False
    widths = [item.width for item in row]
    heights = [item.height for item in row]
    width_cv = coefficient_of_variation(widths)
    height_cv = coefficient_of_variation(heights)
    return width_cv <= 0.38 and height_cv <= 0.38


def looks_like_animation_sheet(detections: list[DetectedSprite], min_frames: int) -> bool:
    if len(detections) < min_frames:
        return False

    rows = cluster_animation_rows(detections)
    candidate_rows = [row for row in rows if len(row) >= min_frames]
    if not candidate_rows:
        return False

    covered = sum(len(row) for row in candidate_rows) / max(1, len(detections))
    if covered < 0.7:
        return False

    similar_rows = [row for row in candidate_rows if row_is_animation_like(row)]
    if not similar_rows:
        return False

    if len(candidate_rows) == 1:
        return len(similar_rows[0]) >= min_frames and covered >= 0.85

    frame_counts = [len(row) for row in similar_rows]
    frame_count_cv = coefficient_of_variation(frame_counts)
    return len(similar_rows) == len(candidate_rows) and frame_count_cv <= 0.35


def resolve_sheet_mode(requested_mode: str, detections: list[DetectedSprite], min_frames: int) -> str:
    if requested_mode != "auto":
        return requested_mode
    return "animation" if looks_like_animation_sheet(detections, min_frames) else "tileset"


def _border_pixels(rgb: np.ndarray, alpha: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    if rgb.size == 0:
        return rgb.reshape(0, 3), alpha.reshape(0)
    top = rgb[0, :, :]
    bottom = rgb[-1, :, :]
    left = rgb[:, 0, :]
    right = rgb[:, -1, :]
    top_alpha = alpha[0, :]
    bottom_alpha = alpha[-1, :]
    left_alpha = alpha[:, 0]
    right_alpha = alpha[:, -1]
    return np.concatenate([top, bottom, left, right], axis=0), np.concatenate([top_alpha, bottom_alpha, left_alpha, right_alpha], axis=0)


def _auto_sheet_stats(sheet: Path) -> dict[str, object] | None:
    try:
        with Image.open(sheet) as image:
            image = image.convert("RGBA")
            image.thumbnail((1024, 1024), Image.Resampling.NEAREST)
            rgba = np.array(image)
    except (OSError, ValueError):
        return None

    rgb = rgba[:, :, :3]
    alpha = rgba[:, :, 3]
    border_rgb, border_alpha = _border_pixels(rgb, alpha)
    opaque_border = border_alpha > 10
    if opaque_border.any():
        opaque_rgb = border_rgb[opaque_border]
        white_border_ratio = float(
            np.mean(
                (opaque_rgb[:, 0] >= 245)
                & (opaque_rgb[:, 1] >= 245)
                & (opaque_rgb[:, 2] >= 245)
                & ((opaque_rgb.max(axis=1) - opaque_rgb.min(axis=1)) <= 14)
            )
        )
        dark_border_ratio = float(np.mean(opaque_rgb.max(axis=1) <= 64))
    else:
        white_border_ratio = 0.0
        dark_border_ratio = 0.0

    transparent_ratio = float(np.mean(alpha <= 10))
    settings = DetectionSettings(alpha_threshold=10, white_threshold=248, white_tolerance=12, dark_artifact_threshold=60, min_sprite_pixels=16, crop_padding=1)
    background = detect_background(rgb, alpha, settings)
    foreground = ~background
    labels, stats, num = grouped_components(foreground)
    detections = extract_detections(foreground, labels, stats, num, settings)
    return {
        "transparent_ratio": transparent_ratio,
        "white_border_ratio": white_border_ratio,
        "dark_border_ratio": dark_border_ratio,
        "animation_like": looks_like_animation_sheet(detections, min_frames=3),
        "detections": len(detections),
    }


def infer_auto_defaults(sheets: list[Path], sample_limit: int = 8) -> dict[str, object]:
    defaults: dict[str, object] = {
        "auto_detect_all": True,
        "mode": "auto",
        "animation_names": "",
        "animation_frame_mode": "fixed",
        "animation_anchor": "bottom-center",
        "animation_min_frames": 3,
        "animation_fps": 8,
        "pack_atlases": True,
        "atlas_padding": 2,
        "atlas_allow_rotation": False,
        "engine_exports": "all",
        "alpha_threshold": 10,
        "white_threshold": 250,
        "white_tolerance": 8,
        "dark_artifact_threshold": 45,
        "min_sprite_pixels": 24,
        "min_sprite_width": 3,
        "min_sprite_height": 3,
        "crop_padding": 1,
        "on_error": "skip",
        "workers": min(4, max(1, os.cpu_count() or 1)) if len(sheets) > 1 else 1,
    }

    stats = [stat for sheet in sheets[:sample_limit] if (stat := _auto_sheet_stats(sheet)) is not None]
    if not stats:
        return defaults

    transparent_ratio = float(np.mean([float(stat["transparent_ratio"]) for stat in stats]))
    white_border_ratio = float(np.mean([float(stat["white_border_ratio"]) for stat in stats]))
    dark_border_ratio = float(np.mean([float(stat["dark_border_ratio"]) for stat in stats]))
    animation_votes = sum(1 for stat in stats if stat["animation_like"])

    if transparent_ratio >= 0.18:
        defaults["min_sprite_pixels"] = 16
        defaults["crop_padding"] = 1

    if dark_border_ratio >= 0.35 and dark_border_ratio >= white_border_ratio:
        defaults["dark_artifact_threshold"] = 60
        defaults["crop_padding"] = 2
        defaults["atlas_padding"] = 3
        defaults["min_sprite_pixels"] = max(int(defaults["min_sprite_pixels"]), 32)
    elif white_border_ratio >= 0.35:
        defaults["white_threshold"] = 248
        defaults["white_tolerance"] = 12

    if animation_votes >= max(1, len(stats) // 2):
        defaults["animation_fps"] = 12
        defaults["min_sprite_pixels"] = min(int(defaults["min_sprite_pixels"]), 16)
    return defaults


def option_was_provided(argv: list[str], *names: str) -> bool:
    prefixes = tuple(f"{name}=" for name in names)
    return any(arg in names or arg.startswith(prefixes) for arg in argv)


AUTO_DEFAULT_FLAGS: dict[str, tuple[str, ...]] = {
    "mode": ("--mode",),
    "animation_names": ("--animation-names",),
    "animation_frame_mode": ("--animation-frame-mode",),
    "animation_anchor": ("--animation-anchor",),
    "animation_min_frames": ("--animation-min-frames",),
    "animation_fps": ("--animation-fps",),
    "pack_atlases": ("--pack-atlases", "--no-pack-atlases"),
    "atlas_padding": ("--atlas-padding",),
    "atlas_allow_rotation": ("--atlas-allow-rotation",),
    "engine_exports": ("--engine-exports", "--no-engine-exports"),
    "alpha_threshold": ("--alpha-threshold",),
    "white_threshold": ("--white-threshold",),
    "white_tolerance": ("--white-tolerance",),
    "dark_artifact_threshold": ("--dark-artifact-threshold",),
    "min_sprite_pixels": ("--min-sprite-pixels",),
    "min_sprite_width": ("--min-sprite-width",),
    "min_sprite_height": ("--min-sprite-height",),
    "crop_padding": ("--crop-padding",),
    "on_error": ("--on-error",),
    "workers": ("--workers",),
}


def apply_auto_defaults(args: object, defaults: dict[str, object], config_defaults: dict[str, object], argv: list[str]) -> dict[str, object]:
    applied: dict[str, object] = {}
    for key, value in defaults.items():
        if key == "auto_detect_all":
            continue
        if key in config_defaults:
            continue
        if option_was_provided(argv, *AUTO_DEFAULT_FLAGS.get(key, ())):
            continue
        setattr(args, key, value)
        applied[key] = value
    return applied
