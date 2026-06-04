from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

try:
    from tools.cut_tileset_sprites import DetectionSettings, detect_background, extract_detections, grouped_components
    from tools.golden_sprite_fixtures import create_golden_pack
    from tools.sprite_editor import SpriteEditSession, color_wheel_palette, extract_palette, write_palette_variant_package
    from tools.sprite_studio import asset_browser_index, batch_health_score, build_review_dashboard, diff_projects, search_assets
    from tools.sprite_ui_settings import CutterUiSettings
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.cut_tileset_sprites import DetectionSettings, detect_background, extract_detections, grouped_components
    from tools.golden_sprite_fixtures import create_golden_pack
    from tools.sprite_editor import SpriteEditSession, color_wheel_palette, extract_palette, write_palette_variant_package
    from tools.sprite_studio import asset_browser_index, batch_health_score, build_review_dashboard, diff_projects, search_assets
    from tools.sprite_ui_settings import CutterUiSettings


PREVIEW_ACCESSIBILITY_MODES = ["normal", "grayscale", "protanopia", "deuteranopia", "tritanopia"]
VIEWPORT_SIZE = (1320, 820)
LEFT_PANEL_WIDTH = 300
CENTER_PANEL_WIDTH = 660
RIGHT_PANEL_WIDTH = 340
PREVIEW_MAX_SIZE = (620, 480)
REVIEW_CANVAS_SIZE = (300, 180)
REVIEW_IMAGE_PREVIEW_SIZE = (190, 130)
UI_ACTION_ERRORS = (OSError, RuntimeError, TypeError, ValueError)
PROCESS_RUN_ERRORS = (OSError, subprocess.SubprocessError, UnicodeError, ValueError)
TOOLTIP_TEXT: dict[str, str] = {
    "input_path": "Folder or image file to process. Folder scans skip prior SpriteCut output folders automatically.",
    "add_folder": "Choose a folder containing sprite sheets or nested asset folders.",
    "add_file": "Choose a single sprite sheet image when you want to process just one file.",
    "refresh_files": "Rescan the selected input path and rebuild the sheet list and preview.",
    "create_sample_pack": "Create a small repeatable sample sprite pack for first-run demos and cutter smoke tests.",
    "file_list": "Detected source sheets. Select a sheet to preview auto-detected sprite regions.",
    "preview_accessibility": "Preview the detection overlay in normal or color-vision simulation modes.",
    "process": "Run the cutter with the current settings and write sprites, manifests, reports, and project files.",
    "reset_log": "Clear the run log without changing settings or output files.",
    "cancel": "Stop the active processing run. Finished output from already completed sheets remains on disk.",
    "open_output": "Open the latest output folder created by the cutter.",
    "open_report": "Open the latest HTML report for visual review and filtering.",
    "open_project": "Load the latest generated project file into the Review tab.",
    "out_name": "Name of the output folder created next to the selected input.",
    "auto_detect_all": "Let the tool infer backgrounds, thresholds, atlases, exports, workers, and animation FPS from the source art.",
    "include_archives": "Process supported images found inside .zip asset packs. Extracted sources are kept inside the output folder for review.",
    "builtin_preset": "Optional fixed recipe for repeatable batches. Auto detect all is usually the best first pass.",
    "apply_preset": "Apply the selected preset to the visible settings controls.",
    "mode": "Auto chooses animation rows or tileset crops per sheet. Use fixed modes only for strict batches.",
    "animation_names": "Optional comma-separated names for animation rows, such as idle, run, attack.",
    "animation_frame_mode": "Fixed keeps each animation row on stable same-size canvases; trimmed exports tight crops.",
    "animation_anchor": "Anchor used when placing trimmed animation frames on fixed canvases.",
    "animation_min_frames": "Minimum detections in a row before auto mode treats it as an animation row.",
    "animation_fps": "Frame rate written to generated animation clip metadata.",
    "pivot_debug": "Write debug previews showing contours and pivot crosses for review.",
    "alpha_threshold": "Pixels at or below this alpha value are treated as transparent background.",
    "white_threshold": "RGB values at or above this level may be treated as white sheet background.",
    "white_tolerance": "Allowed channel spread when classifying near-white background pixels.",
    "dark_artifact_threshold": "Dark matte threshold used to remove black or dark sheet backgrounds.",
    "min_sprite_pixels": "Minimum foreground pixel count required to keep a detected component.",
    "min_sprite_width": "Minimum component width required before a detection becomes a sprite crop.",
    "min_sprite_height": "Minimum component height required before a detection becomes a sprite crop.",
    "crop_padding": "Extra pixels added around each detected sprite crop.",
    "on_error": "Skip bad sheets for production batches, or fail fast while tuning settings.",
    "pack_atlases": "Pack extracted sprites into texture atlases grouped by category.",
    "atlas_size": "Square atlas texture size used when packing sprites.",
    "atlas_padding": "Pixels of spacing around sprites in generated atlases.",
    "atlas_allow_rotation": "Allow atlas packing to rotate sprites when it improves fit.",
    "engine_exports": "Choose which engine handoff JSON files to generate.",
    "export_unity": "Generate Unity-oriented sprite import and clip metadata.",
    "export_godot": "Generate Godot-oriented sprite and animation metadata.",
    "export_unreal": "Generate Unreal-oriented sprite and flipbook metadata.",
    "save_preset": "Save the current visible settings as a reusable JSON preset.",
    "load_preset": "Load a JSON preset and apply it to the current controls.",
    "load_project": "Open a project.spritecut.json file for manual review and corrections.",
    "recent_projects": "Recently loaded SpriteCut project files that still exist on disk.",
    "save_project": "Save the current project edits without regenerating output images.",
    "undo": "Undo the last project edit, including structural split and merge edits.",
    "redo": "Redo the last project edit after an undo.",
    "apply_outputs": "Regenerate corrected crops and reviewed engine exports from the current project edits.",
    "review_filter": "Filter the project list by review status.",
    "review_query": "Search sprites by id, display name, category, or review flag.",
    "review_list": "Project sprites. Select one or more for editing, approval, split, or merge operations.",
    "review_source_canvas": "Source sheet preview with draggable bbox overlay for manual crop adjustment.",
    "animation_clip": "Animation clip generated from row-based sheets for playback review.",
    "play_animation": "Play the selected animation clip in the review preview.",
    "stop_animation": "Stop animation playback in the review preview.",
    "review_name": "Display name used for reviewed output files and engine metadata.",
    "review_category": "Folder/category used when applying reviewed sprite outputs.",
    "review_bbox": "Manual source rectangle as x, y, width, height.",
    "review_pivot": "Manual pivot coordinates from 0.0 to 1.0 in sprite-local space.",
    "review_status": "Review state used for filtering and apply-output behavior.",
    "review_flags": "Comma-separated review flags for audit notes and report filtering.",
    "apply_edit": "Apply the edited fields to the selected sprite in project memory.",
    "approve": "Mark the selected sprite approved and clear review flags.",
    "reject": "Mark the selected sprite rejected so Apply Outputs skips it.",
    "split_boxes": "Split boxes in x,y,width,height format separated by semicolons.",
    "split_selected": "Create child sprites from the split boxes and reject the original source sprite.",
    "merge_selected": "Merge selected sprites into one union bbox and reject the sources.",
    "studio_refresh": "Rebuild the studio dashboard, review queue, health score, and asset search rows from the loaded project.",
    "studio_review_apply": "Run the one-click studio pass: auto naming, collision profiles, reviewed crops, import plans, health, and dashboard files.",
    "studio_auto_name": "Apply the taxonomy naming pattern to active sprites and keep rejected sprites untouched.",
    "studio_train_preset": "Write a trained preset suggestion beside the loaded project using categories, settings, and review corrections.",
    "studio_diff_project": "Compare the loaded project against another project file and write a studio_diff.json rerun comparison.",
    "studio_generate_profiles": "Generate collision, anchor, pivot, atlas, and engine import plan metadata for the loaded project.",
    "studio_dashboard": "Current production readiness summary with health score, status counts, and review queue size.",
    "studio_queue": "Priority review queue sorted by low confidence, review flags, duplicate names, and needs-review status.",
    "studio_asset_query": "Search the asset browser by sprite name, category, source sheet, status, kind, or review flags.",
    "studio_asset_list": "Searchable asset browser rows for quickly finding sprites by taxonomy, status, and review notes.",
    "studio_taxonomy_pattern": "Naming template used by Auto Name and Review + Apply, such as category, source sheet, and index tokens.",
    "editor_load_sprite": "Load one sprite PNG into the non-destructive editor session for palette, color, and autotile operations.",
    "editor_save_package": "Save the edited sprite plus an edit manifest and extracted palette JSON package.",
    "editor_fullscreen": "Expand the Editor into a focused workspace inside the app window.",
    "editor_save_project": "Save the current edited sprite or animation frames back into the loaded SpriteCut project outputs.",
    "editor_canvas": "Edit pixels with the active tool. Mouse wheel zooms, space-drag pans, and the status bar shows cursor details.",
    "editor_tool_scope": "Choose whether an edit affects the active layer, selected region, current frame, selected frames, or all frames.",
    "editor_tool_pencil": "Draw pixel-perfect strokes with the foreground color. Shortcut: B.",
    "editor_tool_eraser": "Erase pixels on the active layer to transparent. Shortcut: E.",
    "editor_tool_eyedropper": "Pick a visible canvas color into the active color field. Shortcut: I.",
    "editor_tool_fill": "Flood-fill connected pixels with the foreground color. Shortcut: G.",
    "editor_tool_line": "Drag to draw a straight line. Shortcut: L.",
    "editor_tool_rect_fill": "Drag to draw a filled rectangle. Shortcut: R.",
    "editor_tool_rect_outline": "Drag to draw a rectangle outline. Shortcut: Shift+R.",
    "editor_tool_select_move": "Select pixels or move the selected region. Shortcut: M.",
    "editor_tool_crop": "Drag a crop rectangle and apply it to the current sprite or frame. Shortcut: C.",
    "editor_tool_pan": "Move around the zoomed canvas without changing pixels. Shortcut: H or space-drag.",
    "editor_tool_zoom": "Zoom the canvas around the cursor with mouse wheel or shortcut keys.",
    "editor_tool_palette_swap": "Replace one color with another in the current editing scope.",
    "editor_tool_hue_shift": "Shift hue, saturation, and value for the current editing scope.",
    "editor_tool_palette_variants": "Generate alternate colorway previews for review.",
    "editor_tool_flip": "Flip the current sprite, frame, or selected editing scope.",
    "editor_tool_rotate": "Rotate the current sprite, frame, or selected editing scope by 90 degrees.",
    "editor_tool_resize": "Resize the current sprite or frame with nearest-neighbor scaling.",
    "editor_layers_panel": "Manage layer order, active layer, visibility, opacity, duplication, and deletion.",
    "editor_palette_panel": "Inspect colors, pick foreground/background colors, swap palettes, and generate variants.",
    "editor_help_panel": "Read current tool directions, shortcuts, and quick-start guidance.",
    "editor_timeline_panel": "Preview and edit frames from a loaded character animation clip.",
    "editor_palette_summary": "Palette summary for the current edited sprite, sorted by dominant visible colors.",
    "editor_source_color": "Source color to replace, written as a hex color such as #ff0000.",
    "editor_target_color": "Target replacement color, written as a hex color such as #00ffff.",
    "editor_swap_colors": "Replace the source color with the target color while preserving transparent pixels.",
    "editor_undo": "Undo the most recent non-destructive sprite edit in the current editor session.",
    "editor_redo": "Redo the most recently undone sprite edit in the current editor session.",
    "editor_crop_rect": "Crop rectangle for the current sprite as x,y,width,height or four space-separated numbers.",
    "editor_resize_size": "Resize target for the current sprite as width x height or two comma-separated numbers.",
    "editor_flip_axis": "Flip the current sprite horizontally or vertically using nearest-neighbor pixel handling.",
    "editor_crop": "Apply the crop rectangle to all layers in the current editor session.",
    "editor_resize": "Resize all layers in the current editor session using nearest-neighbor pixel handling.",
    "editor_flip": "Flip all layers in the current editor session across the selected axis.",
    "editor_rotate": "Rotate all layers in the current editor session by 90 degrees.",
    "editor_hue_degrees": "Hue rotation in degrees for color-wheel style sprite recoloring.",
    "editor_hue_shift": "Apply hue, saturation, and value changes to the current sprite session.",
    "editor_color_wheel": "Preview color harmony suggestions such as complementary, analogous, triadic, or tetradic.",
    "editor_palette_variants": "Write colorway PNGs, manifest JSON, and contact sheet using the selected harmony colors.",
    "editor_autotile_name": "Name used when writing a 16-mask cardinal autotile sheet and rule metadata.",
    "editor_generate_autotile": "Generate a 16-variant autotile package from the current edited sprite.",
    "editor_ide_api": "Show IDE-callable JSON actions for scripts, editors, and external tools.",
}


def tooltip_text(key: str) -> str:
    return TOOLTIP_TEXT[key]


def render_detection_preview(image_path: Path, boxes: list[tuple[int, int, int, int]], max_size: tuple[int, int] = (760, 620)) -> Image.Image:
    with Image.open(image_path) as source_image:
        image = source_image.convert("RGBA")
    draw = ImageDraw.Draw(image)
    for index, (x, y, width, height) in enumerate(boxes, start=1):
        draw.rectangle((x, y, x + width - 1, y + height - 1), outline=(255, 90, 60, 255), width=2)
        draw.text((x + 3, y + 3), str(index), fill=(255, 90, 60, 255))
    image.thumbnail(max_size, Image.Resampling.NEAREST)
    return image.copy()


def apply_preview_accessibility_mode(image: Image.Image, mode: str) -> Image.Image:
    if mode == "normal":
        return image.copy()

    rgba = image.convert("RGBA")
    if mode == "grayscale":
        return rgba.convert("LA").convert("RGBA")

    import numpy as np

    matrices = {
        "protanopia": np.array(
            [
                [0.567, 0.433, 0.000],
                [0.558, 0.442, 0.000],
                [0.000, 0.242, 0.758],
            ]
        ),
        "deuteranopia": np.array(
            [
                [0.625, 0.375, 0.000],
                [0.700, 0.300, 0.000],
                [0.000, 0.300, 0.700],
            ]
        ),
        "tritanopia": np.array(
            [
                [0.950, 0.050, 0.000],
                [0.000, 0.433, 0.567],
                [0.000, 0.475, 0.525],
            ]
        ),
    }
    matrix = matrices.get(mode)
    if matrix is None:
        return image.copy()

    pixels = np.array(rgba).astype(np.float32)
    rgb = pixels[:, :, :3]
    transformed = rgb @ matrix.T
    pixels[:, :, :3] = np.clip(transformed, 0, 255)
    return Image.fromarray(pixels.astype(np.uint8), "RGBA")


def detection_settings_from_ui(settings: CutterUiSettings | None) -> DetectionSettings:
    if settings is None:
        return DetectionSettings()
    return DetectionSettings(
        alpha_threshold=max(0, settings.alpha_threshold),
        white_threshold=max(0, min(255, settings.white_threshold)),
        white_tolerance=max(0, settings.white_tolerance),
        dark_artifact_threshold=max(0, settings.dark_artifact_threshold),
        min_sprite_pixels=max(1, settings.min_sprite_pixels),
        min_sprite_width=max(1, settings.min_sprite_width),
        min_sprite_height=max(1, settings.min_sprite_height),
        crop_padding=max(0, settings.crop_padding),
    )


def detect_preview_boxes(image_path: Path, settings: CutterUiSettings | None = None) -> list[tuple[int, int, int, int]]:
    import numpy as np

    with Image.open(image_path) as source_image:
        image = source_image.convert("RGBA")
    rgba = np.array(image)
    detection_settings = detection_settings_from_ui(settings)
    background = detect_background(rgba[:, :, :3], rgba[:, :, 3], detection_settings)
    foreground = ~background
    labels, stats, num = grouped_components(foreground)
    detections = extract_detections(foreground, labels, stats, num, detection_settings)
    return [(detection.x, detection.y, detection.width, detection.height) for detection in detections]


def parse_flags_text(value: str) -> list[str]:
    return [part.strip() for part in re.split(r"[,|]", value) if part.strip()]


def parse_bbox_fields(x: str, y: str, width: str, height: str) -> dict[str, int]:
    bbox = {"x": int(x), "y": int(y), "width": int(width), "height": int(height)}
    if bbox["width"] <= 0 or bbox["height"] <= 0:
        raise ValueError("Bounding box width and height must be positive.")
    return bbox


def parse_pivot_fields(x: str, y: str) -> dict[str, float | str]:
    pivot_x = float(x)
    pivot_y = float(y)
    if not 0.0 <= pivot_x <= 1.0 or not 0.0 <= pivot_y <= 1.0:
        raise ValueError("Pivot x and y must be between 0.0 and 1.0.")
    return {"x": pivot_x, "y": pivot_y, "method": "manual"}


def format_project_sprite_label(sprite: dict[str, object]) -> str:
    display_name = str(sprite.get("display_name") or sprite.get("id") or "sprite")
    status = str(sprite.get("review_status", "unknown"))
    confidence = float(sprite.get("confidence", 0.0))
    flags = sprite.get("review_flags", [])
    flags_text = ",".join(str(flag) for flag in flags) if isinstance(flags, list) and flags else "none"
    return f"{display_name} | {status} | {confidence:.2f} | {flags_text}"


def project_sprite_preview_path_text(sprite: dict[str, object]) -> str:
    applied_output = str(sprite.get("applied_output_file") or "").strip()
    if applied_output:
        return applied_output
    return str(sprite.get("output_file") or "").strip()


def project_sprite_rows(project: dict[str, object], status_filter: str = "all", query: str = "") -> list[dict[str, object]]:
    sprites = project.get("sprites", [])
    if not isinstance(sprites, list):
        return []
    normalized_query = query.strip().lower()
    rows: list[dict[str, object]] = []
    for sprite in sprites:
        if not isinstance(sprite, dict):
            continue
        status = str(sprite.get("review_status", "unknown"))
        if status_filter != "all" and status != status_filter:
            continue
        haystack = " ".join(
            [
                str(sprite.get("id", "")),
                str(sprite.get("display_name", "")),
                str(sprite.get("category", "")),
                " ".join(str(flag) for flag in sprite.get("review_flags", []) if isinstance(flag, str)),
            ]
        ).lower()
        if normalized_query and normalized_query not in haystack:
            continue
        rows.append(sprite)
    return rows


def studio_default_taxonomy_rules(pattern: str) -> dict[str, object]:
    normalized = pattern.strip() or "{category}_{source_sheet}_{index:03d}"
    return {"display_name_pattern": normalized, "include_rejected": False}


def studio_project_diff_text(old_project: dict[str, object], new_project: dict[str, object]) -> str:
    diff = diff_projects(old_project, new_project)  # type: ignore[arg-type]
    summary = diff.get("summary", {})
    if not isinstance(summary, dict):
        summary = {}
    return (
        "Diff "
        f"added={int(summary.get('added', 0))} "
        f"removed={int(summary.get('removed', 0))} "
        f"changed={int(summary.get('changed', 0))}"
    )


def studio_dashboard_text(project: dict[str, object]) -> str:
    health = batch_health_score(project)  # type: ignore[arg-type]
    dashboard = build_review_dashboard(project)  # type: ignore[arg-type]
    counts = health.get("counts", {})
    if not isinstance(counts, dict):
        counts = {}
    return (
        f"Health {health['grade']} {health['score']}/100 | "
        f"queue={len(dashboard['queue'])} | "
        f"approved={int(counts.get('approved', 0))} | "
        f"needs_review={int(counts.get('needs_review', 0))} | "
        f"rejected={int(counts.get('rejected', 0))}"
    )


def studio_queue_labels(project: dict[str, object], limit: int = 50) -> list[str]:
    dashboard = build_review_dashboard(project)  # type: ignore[arg-type]
    labels: list[str] = []
    for item in dashboard.get("queue", [])[:limit]:
        if not isinstance(item, dict):
            continue
        reasons = item.get("reasons", [])
        reason_text = ", ".join(str(reason) for reason in reasons) if isinstance(reasons, list) else str(reasons)
        labels.append(f"{item.get('sprite_id', '')} | p{item.get('priority', 0)} | {reason_text}")
    return labels


def studio_asset_rows(project: dict[str, object], query: str = "", status_filter: str = "all", category_filter: str = "all") -> list[dict[str, object]]:
    status = None if status_filter == "all" else status_filter
    category = None if category_filter == "all" else category_filter
    index = asset_browser_index(project)  # type: ignore[arg-type]
    return search_assets(index, query, status=status, category=category)  # type: ignore[return-value]


def studio_asset_label(item: dict[str, object]) -> str:
    flags = item.get("flags", [])
    flags_text = ",".join(str(flag) for flag in flags) if isinstance(flags, list) and flags else "none"
    return (
        f"{item.get('display_name', item.get('sprite_id', 'sprite'))} | "
        f"{item.get('category', 'sprites')} | "
        f"{item.get('status', 'unknown')} | "
        f"{flags_text}"
    )


def editor_palette_summary(image: Image.Image, max_colors: int = 8) -> str:
    palette = extract_palette(image, max_colors=max_colors)
    colors = ", ".join(f"{entry['hex']}:{entry['count']}" for entry in palette[:max_colors])
    return f"colors={len(palette)} | {colors or 'empty'}"


def editor_color_wheel_preview(base: str, harmony: str = "complementary") -> str:
    wheel = color_wheel_palette(base, harmony=harmony, steps=5)
    return f"{wheel['harmony']} | colors={', '.join(wheel['colors'])} | ramp={', '.join(wheel['ramp'])}"


def _editor_numbers(text: str, expected: int, label: str) -> tuple[int, ...]:
    parts = [part for part in re.split(r"[,\sxX]+", text.strip()) if part]
    if len(parts) != expected:
        raise ValueError(f"{label} must contain {expected} numbers.")
    values = tuple(int(part) for part in parts)
    if any(value < 0 for value in values):
        raise ValueError(f"{label} cannot contain negative values.")
    return values


def editor_parse_rect_text(text: str) -> tuple[int, int, int, int]:
    x, y, width, height = _editor_numbers(text, 4, "Crop rectangle")
    if width < 1 or height < 1:
        raise ValueError("Crop rectangle width and height must be at least 1.")
    return x, y, width, height


def editor_parse_size_text(text: str) -> tuple[int, int]:
    width, height = _editor_numbers(text, 2, "Resize size")
    if width < 1 or height < 1:
        raise ValueError("Resize width and height must be at least 1.")
    return width, height


def editor_variant_package(
    session: SpriteEditSession,
    output_dir: Path,
    *,
    name: str,
    base_color: str,
    harmony: str,
) -> dict[str, Any]:
    wheel = color_wheel_palette(base_color, harmony=harmony, steps=5)
    colors = [str(color) for color in wheel.get("colors", [])]
    targets = colors[:2] if len(colors) >= 2 else colors
    variants = [
        {"name": f"{harmony}_{index + 1}", "swaps": {base_color: target}}
        for index, target in enumerate(targets)
    ]
    return write_palette_variant_package(session.composite(), output_dir, name=name, variants=variants)


def editor_callable_actions() -> list[str]:
    return ["sprite.edit", "sprite.batch_edit", "palette.extract", "palette.swap", "palette.hue_shift", "palette.variants", "autotile.generate"]


def default_recent_projects_state_path() -> Path:
    return Path.home() / ".spritecut" / "recent_projects.json"


def load_recent_projects(state_file: Path | None = None, *, limit: int = 8) -> list[Path]:
    state_path = state_file or default_recent_projects_state_path()
    if not state_path.exists():
        return []
    try:
        data = json.loads(state_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return []
    raw_paths = data.get("projects", []) if isinstance(data, dict) else []
    if not isinstance(raw_paths, list):
        return []
    projects: list[Path] = []
    seen: set[str] = set()
    for raw_path in raw_paths:
        path = Path(str(raw_path))
        key = str(path.resolve()).lower() if path.exists() else str(path).lower()
        if key in seen or not path.exists():
            continue
        seen.add(key)
        projects.append(path)
        if len(projects) >= limit:
            break
    return projects


def remember_recent_project(state_file: Path | None, project_path: Path, *, limit: int = 8) -> list[Path]:
    state_path = state_file or default_recent_projects_state_path()
    project = project_path.resolve()
    existing = [path for path in load_recent_projects(state_path, limit=limit) if path.resolve() != project]
    projects = [project, *existing][:limit]
    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps({"projects": [str(path) for path in projects]}, indent=2), encoding="utf-8")
    return projects


def create_ui_sample_pack(output_root: Path) -> Path:
    output_root.mkdir(parents=True, exist_ok=True)
    expected_path = create_golden_pack(output_root)
    alias_path = output_root / "expected.json"
    if expected_path != alias_path:
        alias_path.write_text(expected_path.read_text(encoding="utf-8"), encoding="utf-8")
    return output_root


def project_animation_clip_names(project: dict[str, object]) -> list[str]:
    clips = project.get("animation_clips", [])
    if not isinstance(clips, list):
        return []
    names: list[str] = []
    for clip in clips:
        if isinstance(clip, dict) and clip.get("name"):
            names.append(str(clip["name"]))
    return names


def project_animation_clip_frames(project: dict[str, object], clip_name: str) -> list[dict[str, object]]:
    clips = project.get("animation_clips", [])
    if not isinstance(clips, list):
        return []
    for clip in clips:
        if isinstance(clip, dict) and clip.get("name") == clip_name:
            frames = clip.get("frames", [])
            return [frame for frame in frames if isinstance(frame, dict)] if isinstance(frames, list) else []
    return []


def scale_bbox_for_canvas(bbox: dict[str, int], image_size: tuple[int, int], canvas_size: tuple[int, int]) -> dict[str, object]:
    image_width, image_height = image_size
    canvas_width, canvas_height = canvas_size
    scale = min(canvas_width / max(1, image_width), canvas_height / max(1, image_height))
    display_width = int(round(image_width * scale))
    display_height = int(round(image_height * scale))
    offset_x = (canvas_width - display_width) // 2
    offset_y = (canvas_height - display_height) // 2
    x0 = int(round(offset_x + bbox["x"] * scale))
    y0 = int(round(offset_y + bbox["y"] * scale))
    x1 = int(round(offset_x + (bbox["x"] + bbox["width"]) * scale))
    y1 = int(round(offset_y + (bbox["y"] + bbox["height"]) * scale))
    return {"rect": (x0, y0, x1, y1), "scale": scale, "offset": (offset_x, offset_y)}


def translate_bbox_by_canvas_delta(bbox: dict[str, int], dx: int, dy: int, scale: float) -> dict[str, int]:
    safe_scale = scale if scale > 0 else 1.0
    return {
        "x": int(round(bbox["x"] + dx / safe_scale)),
        "y": int(round(bbox["y"] + dy / safe_scale)),
        "width": int(bbox["width"]),
        "height": int(bbox["height"]),
    }


def cancel_button_state(has_active_process: bool) -> str:
    return "normal" if has_active_process else "disabled"


def request_process_stop(process: subprocess.Popen[str], *, timeout: float = 3.0) -> str:
    if process.poll() is not None:
        return "already exited"

    process.terminate()
    try:
        process.wait(timeout=timeout)
        return "terminated"
    except subprocess.TimeoutExpired:
        process.kill()
        try:
            process.wait(timeout=timeout)
            return "killed"
        except subprocess.TimeoutExpired:
            return "kill requested"
