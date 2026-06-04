from __future__ import annotations

from pathlib import Path
import cv2
import numpy as np

try:
    from tools.sprite_cutter_types import DetectionSettings, DetectedSprite
except ModuleNotFoundError:
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_cutter_types import DetectionSettings, DetectedSprite


def detect_background(rgb: np.ndarray, alpha: np.ndarray, settings: DetectionSettings | None = None) -> np.ndarray:
    settings = settings or DetectionSettings()
    white = (
        (rgb[:, :, 0] >= settings.white_threshold)
        & (rgb[:, :, 1] >= settings.white_threshold)
        & (rgb[:, :, 2] >= settings.white_threshold)
        & ((rgb.max(axis=2) - rgb.min(axis=2)) <= settings.white_tolerance)
    )
    transparent = alpha <= settings.alpha_threshold

    dark_flat = (rgb.max(axis=2) <= settings.dark_artifact_threshold) & (alpha > settings.alpha_threshold)
    black_background = np.zeros(dark_flat.shape, dtype=bool)
    num, labels, stats, _ = cv2.connectedComponentsWithStats(dark_flat.astype(np.uint8), 8)
    near_transparent = cv2.dilate(transparent.astype(np.uint8), np.ones((3, 3), np.uint8), iterations=1).astype(bool)
    for label in range(1, num):
        x, y, w, h, area = stats[label]
        fill = area / max(1, w * h)
        component = labels == label
        touches_edge = x == 0 or y == 0 or x + w == rgb.shape[1] or y + h == rgb.shape[0]
        touches_transparent = bool((component & near_transparent).any())
        if area >= 350 and (w >= 18 or h >= 18) and (fill >= 0.18 or area >= 900) and (touches_edge or touches_transparent):
            black_background[component] = True

    if black_background.any():
        expanded = cv2.dilate(black_background.astype(np.uint8), np.ones((3, 3), np.uint8), iterations=2).astype(bool)
        black_background = expanded & (alpha > settings.alpha_threshold) & (rgb.max(axis=2) <= 105)

    return white | transparent | black_background


def grouped_components(foreground: np.ndarray) -> tuple[np.ndarray, np.ndarray, int]:
    num, labels, stats, _ = cv2.connectedComponentsWithStats(foreground.astype(np.uint8), 8)
    return labels, stats, num


def extract_detections(
    foreground: np.ndarray,
    labels: np.ndarray,
    stats: np.ndarray,
    num: int,
    settings: DetectionSettings | None = None,
) -> list[DetectedSprite]:
    settings = settings or DetectionSettings()
    detections: list[DetectedSprite] = []
    height, width = foreground.shape
    for label in range(1, num):
        x, y, w, h, _area = stats[label]
        if w < settings.min_sprite_width or h < settings.min_sprite_height:
            continue

        component_region = labels[y : y + h, x : x + w] == label
        exact_foreground = foreground[y : y + h, x : x + w] & component_region
        foreground_pixels = int(exact_foreground.sum())
        if foreground_pixels < settings.min_sprite_pixels:
            continue

        x0 = max(0, int(x) - settings.crop_padding)
        y0 = max(0, int(y) - settings.crop_padding)
        x1 = min(width, int(x + w) + settings.crop_padding)
        y1 = min(height, int(y + h) + settings.crop_padding)
        detections.append(
            DetectedSprite(
                label=int(label),
                x=x0,
                y=y0,
                width=int(x1 - x0),
                height=int(y1 - y0),
                foreground_pixels=foreground_pixels,
            )
        )

    return sorted(detections, key=lambda item: (item.y, item.x))
