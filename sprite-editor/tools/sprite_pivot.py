from __future__ import annotations

from pathlib import Path
import cv2
import numpy as np
from PIL import Image, ImageDraw

try:
    from tools.sprite_reports import render_checker
except ModuleNotFoundError:
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_reports import render_checker


def detect_pivot_centroid(rgba: np.ndarray, category: str, bias_strength: float = 1.0) -> dict[str, float | str]:
    alpha = rgba[:, :, 3].astype(np.float32)
    mask = alpha > 20
    height, width = alpha.shape
    if not mask.any():
        return {"x": 0.5, "y": 0.5, "method": "centroid"}

    weights = alpha * mask
    ys, xs = np.indices(alpha.shape)
    total = float(weights.sum())
    pivot_x = float((xs * weights).sum() / total) / max(1, width - 1)
    pivot_y = float((ys * weights).sum() / total) / max(1, height - 1)

    bottom_categories = {"animation", "tall_shelves_and_racks", "wide_cases_and_counters", "large_fixtures", "fixtures_and_displays"}
    if category in bottom_categories:
        pivot_x = pivot_x * (1 - 0.35 * bias_strength) + 0.5 * (0.35 * bias_strength)
        pivot_y = pivot_y * (1 - 0.65 * bias_strength) + 0.88 * (0.65 * bias_strength)
    elif category in {"signs_and_labels"}:
        pivot_x = pivot_x * (1 - 0.25 * bias_strength) + 0.5 * (0.25 * bias_strength)
        pivot_y = pivot_y * (1 - 0.6 * bias_strength) + 0.2 * (0.6 * bias_strength)

    return {"x": round(max(0.05, min(0.95, pivot_x)), 4), "y": round(max(0.05, min(0.95, pivot_y)), 4), "method": "centroid"}


def detect_pivot_contour(rgba: np.ndarray, category: str, bias_strength: float = 1.0) -> dict[str, float | str]:
    alpha = rgba[:, :, 3]
    height, width = alpha.shape
    _, binary = cv2.threshold(alpha, 20, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return detect_pivot_centroid(rgba, category, bias_strength)

    contour = max(contours, key=cv2.contourArea)
    moments = cv2.moments(contour)
    if moments["m00"] > 0:
        pivot_x = float(moments["m10"] / moments["m00"]) / max(1, width - 1)
        pivot_y = float(moments["m01"] / moments["m00"]) / max(1, height - 1)
    else:
        x, y, w, h = cv2.boundingRect(contour)
        pivot_x = (x + w / 2) / max(1, width)
        pivot_y = (y + h / 2) / max(1, height)

    bottom_categories = {"animation", "tall_shelves_and_racks", "wide_cases_and_counters", "large_fixtures", "fixtures_and_displays"}
    if category in bottom_categories:
        bottom_y = float(contour[:, 0, 1].max()) / max(1, height - 1)
        pivot_x = pivot_x * (1 - 0.4 * bias_strength) + 0.5 * (0.4 * bias_strength)
        pivot_y = bottom_y * 0.96
    elif category in {"signs_and_labels"}:
        pivot_x = pivot_x * (1 - 0.25 * bias_strength) + 0.5 * (0.25 * bias_strength)
        pivot_y = 0.18

    return {"x": round(max(0.05, min(0.95, pivot_x)), 4), "y": round(max(0.05, min(0.95, pivot_y)), 4), "method": "contour"}


def detect_pivot(rgba: np.ndarray, category: str) -> dict[str, float | str]:
    contour = detect_pivot_contour(rgba, category)
    centroid = detect_pivot_centroid(rgba, category)
    contour_weight = 0.7
    pivot_x = float(contour["x"]) * contour_weight + float(centroid["x"]) * (1 - contour_weight)
    pivot_y = float(contour["y"]) * contour_weight + float(centroid["y"]) * (1 - contour_weight)
    return {"x": round(max(0.05, min(0.95, pivot_x)), 4), "y": round(max(0.05, min(0.95, pivot_y)), 4), "method": "hybrid"}


def save_pivot_debug(rgba: np.ndarray, pivot: dict[str, float | str], out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    image = Image.fromarray(rgba, "RGBA")
    base = render_checker(image.size)
    base.alpha_composite(image)
    debug = np.array(base.convert("RGB"))

    alpha = rgba[:, :, 3]
    _, binary = cv2.threshold(alpha, 20, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if contours:
        cv2.drawContours(debug, contours, -1, (0, 210, 80), 1)

    debug_image = Image.fromarray(debug, "RGB")
    draw = ImageDraw.Draw(debug_image)
    px = int(float(pivot["x"]) * max(1, image.width - 1))
    py = int(float(pivot["y"]) * max(1, image.height - 1))
    size = 8
    draw.line((px - size, py, px + size, py), fill=(255, 0, 0), width=2)
    draw.line((px, py - size, px, py + size), fill=(255, 0, 0), width=2)
    debug_image.save(out_path)
