from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

try:
    from tools.sprite_cutter_types import DetectionSettings, RunOptions
    from tools.sprite_analysis import safe_name
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_cutter_types import DetectionSettings, RunOptions
    from tools.sprite_analysis import safe_name

WHITE_THRESHOLD = 250
DARK_ARTIFACT_THRESHOLD = 45
MIN_GROUP_PIXELS = 24
MIN_WIDTH = 3
MIN_HEIGHT = 3
PADDING = 1

BUILT_IN_PRESETS: dict[str, dict[str, object]] = {
    "pixel_tileset_white_bg": {
        "mode": "tileset",
        "alpha_threshold": 10,
        "white_threshold": 248,
        "white_tolerance": 10,
        "min_sprite_pixels": 24,
        "crop_padding": 1,
        "pack_atlases": True,
        "atlas_padding": 2,
        "engine_exports": "unity,godot",
    },
    "transparent_animation_rows": {
        "mode": "animation",
        "animation_frame_mode": "fixed",
        "animation_anchor": "bottom-center",
        "animation_min_frames": 3,
        "animation_fps": 12,
        "alpha_threshold": 10,
        "min_sprite_pixels": 16,
        "crop_padding": 1,
        "engine_exports": "unity,godot,unreal",
    },
    "packed_props_dark_bg": {
        "mode": "tileset",
        "alpha_threshold": 10,
        "dark_artifact_threshold": 60,
        "min_sprite_pixels": 32,
        "crop_padding": 2,
        "atlas_padding": 3,
        "engine_exports": "unity,godot",
    },
    "rpgmaker_tiles": {
        "mode": "tileset",
        "alpha_threshold": 10,
        "white_threshold": 250,
        "white_tolerance": 8,
        "min_sprite_width": 4,
        "min_sprite_height": 4,
        "min_sprite_pixels": 16,
        "crop_padding": 0,
        "pack_atlases": True,
        "atlas_padding": 1,
        "engine_exports": "godot",
    },
}


def parse_animation_names(value: str) -> list[str]:
    if not value:
        return []
    return [safe_name(part) for part in value.split(",") if safe_name(part)]


def parse_engine_exports(value: str) -> list[str]:
    if not value:
        return []
    names = [safe_name(part) for part in value.split(",") if safe_name(part)]
    if "all" in names:
        return ["unity", "godot", "unreal"]
    allowed = {"unity", "godot", "unreal"}
    return [name for name in names if name in allowed]


def load_config_defaults(config_path: Path | None, preset_name: str | None = None) -> dict[str, object]:
    defaults: dict[str, object] = {}
    if preset_name:
        if preset_name not in BUILT_IN_PRESETS:
            available = ", ".join(sorted(BUILT_IN_PRESETS))
            raise SystemExit(f"Unknown preset '{preset_name}'. Available presets: {available}")
        defaults.update(BUILT_IN_PRESETS[preset_name])

    if config_path is not None:
        with config_path.open("r", encoding="utf-8") as handle:
            raw = json.load(handle)
        if not isinstance(raw, dict):
            raise SystemExit(f"Config file must contain a JSON object: {config_path}")
        defaults.update(raw)

    if isinstance(defaults.get("engine_exports"), list):
        defaults["engine_exports"] = ",".join(str(item) for item in defaults["engine_exports"])
    if isinstance(defaults.get("animation_names"), list):
        defaults["animation_names"] = ",".join(str(item) for item in defaults["animation_names"])
    return defaults


def build_pre_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--config", type=Path, help="JSON config file containing default CLI options.")
    parser.add_argument("--preset", choices=sorted(BUILT_IN_PRESETS), help="Built-in preset to use before optional --config overrides.")
    parser.add_argument("--list-presets", action="store_true", help="Print built-in preset names and exit.")
    return parser


def build_arg_parser(config_defaults: dict[str, object] | None = None, pre_parser: argparse.ArgumentParser | None = None) -> argparse.ArgumentParser:
    defaults = config_defaults or {}
    parser = argparse.ArgumentParser(
        description="Cut packed tileset sheets or row-based animation sheets into organized sprite crops.",
        parents=[pre_parser or build_pre_parser()],
    )
    parser.add_argument("root", type=Path, help="Image file or folder containing sprite sheets.")
    parser.add_argument(
        "--auto-detect-all",
        dest="auto_detect_all",
        action="store_true",
        default=bool(defaults.get("auto_detect_all", True)),
        help="Infer background, thresholds, atlas/export defaults, workers, and animation FPS from the input sheets.",
    )
    parser.add_argument(
        "--manual-defaults",
        dest="auto_detect_all",
        action="store_false",
        help="Use literal CLI/config defaults instead of auto-inferring a processing profile.",
    )
    parser.add_argument("--out-name", default=defaults.get("out_name", "_organized_sprites"), help="Name for the output folder created beside the input.")
    parser.add_argument(
        "--mode",
        choices=["auto", "tileset", "animation"],
        default=defaults.get("mode", "auto"),
        help="auto detects animation-like sheets; tileset forces category folders; animation forces row/frame folders.",
    )
    parser.add_argument(
        "--animation-names",
        default=defaults.get("animation_names", ""),
        help="Comma-separated sequence names for animation rows, for example idle,run,attack.",
    )
    parser.add_argument(
        "--animation-frame-mode",
        choices=["fixed", "trimmed"],
        default=defaults.get("animation_frame_mode", "fixed"),
        help="fixed keeps each row on same-sized canvases; trimmed exports tight crops.",
    )
    parser.add_argument(
        "--animation-anchor",
        choices=["bottom-center", "center"],
        default=defaults.get("animation_anchor", "bottom-center"),
        help="Anchor used when placing trimmed sprites on fixed animation canvases.",
    )
    parser.add_argument(
        "--animation-min-frames",
        type=int,
        default=defaults.get("animation_min_frames", 3),
        help="Minimum frames per row for auto animation detection.",
    )
    parser.add_argument(
        "--animation-fps",
        type=int,
        default=defaults.get("animation_fps", 8),
        help="Frame rate written into generated animation clip metadata.",
    )
    parser.add_argument(
        "--pivot-debug",
        action="store_true",
        default=bool(defaults.get("pivot_debug", False)),
        help="Save per-sprite debug previews with contours and pivot crosses.",
    )
    parser.add_argument(
        "--pack-atlases",
        dest="pack_atlases",
        action="store_true",
        default=bool(defaults.get("pack_atlases", False)),
        help="Pack extracted sprites into category atlases after cutting.",
    )
    parser.add_argument(
        "--no-pack-atlases",
        dest="pack_atlases",
        action="store_false",
        help="Disable atlas packing even when --auto-detect-all would enable it.",
    )
    parser.add_argument(
        "--atlas-size",
        type=int,
        default=defaults.get("atlas_size", 2048),
        help="Square atlas size used when --pack-atlases is enabled.",
    )
    parser.add_argument(
        "--atlas-padding",
        type=int,
        default=defaults.get("atlas_padding", 2),
        help="Padding in pixels around sprites in generated atlases.",
    )
    parser.add_argument(
        "--atlas-allow-rotation",
        action="store_true",
        default=bool(defaults.get("atlas_allow_rotation", False)),
        help="Allow 90-degree rotation while atlas packing.",
    )
    parser.add_argument(
        "--engine-exports",
        default=defaults.get("engine_exports", ""),
        help="Comma-separated export presets to write: unity,godot,unreal, or all.",
    )
    parser.add_argument(
        "--no-engine-exports",
        dest="engine_exports",
        action="store_const",
        const="",
        help="Disable engine export JSON even when --auto-detect-all would enable it.",
    )
    parser.add_argument(
        "--alpha-threshold",
        type=int,
        default=defaults.get("alpha_threshold", 10),
        help="Alpha values at or below this are treated as transparent background.",
    )
    parser.add_argument(
        "--white-threshold",
        type=int,
        default=defaults.get("white_threshold", WHITE_THRESHOLD),
        help="RGB values at or above this can be treated as white background.",
    )
    parser.add_argument(
        "--white-tolerance",
        type=int,
        default=defaults.get("white_tolerance", 8),
        help="Allowed RGB channel spread for white-background detection.",
    )
    parser.add_argument(
        "--dark-artifact-threshold",
        type=int,
        default=defaults.get("dark_artifact_threshold", DARK_ARTIFACT_THRESHOLD),
        help="Dark matte artifact threshold for removing large black background chunks.",
    )
    parser.add_argument(
        "--min-sprite-pixels",
        type=int,
        default=defaults.get("min_sprite_pixels", MIN_GROUP_PIXELS),
        help="Minimum foreground pixels required to keep a detected component.",
    )
    parser.add_argument(
        "--min-sprite-width",
        type=int,
        default=defaults.get("min_sprite_width", MIN_WIDTH),
        help="Minimum detected component width.",
    )
    parser.add_argument(
        "--min-sprite-height",
        type=int,
        default=defaults.get("min_sprite_height", MIN_HEIGHT),
        help="Minimum detected component height.",
    )
    parser.add_argument(
        "--crop-padding",
        type=int,
        default=defaults.get("crop_padding", PADDING),
        help="Padding around each extracted sprite crop.",
    )
    parser.add_argument(
        "--on-error",
        choices=["skip", "fail"],
        default=defaults.get("on_error", "skip"),
        help="Skip unreadable/problematic sheets by default, or fail fast.",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=defaults.get("workers", 1),
        help="Number of worker threads used for batch sheet processing.",
    )
    parser.add_argument(
        "--max-image-megapixels",
        type=float,
        default=defaults.get("max_image_megapixels", 0),
        help="Skip/fail sheets larger than this many megapixels; 0 disables the guard.",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        default=bool(defaults.get("resume", False)),
        help="Reuse an existing --out-name folder and skip sheets already present in its manifest.",
    )
    parser.add_argument(
        "--include-archives",
        action="store_true",
        default=bool(defaults.get("include_archives", False)),
        help="Extract supported image files from .zip archives found in the input folder, or process a .zip input directly.",
    )
    return parser


def options_from_args(args: argparse.Namespace, auto_profile: dict[str, object] | None = None) -> RunOptions:
    return RunOptions(
        mode=args.mode,
        animation_names=parse_animation_names(args.animation_names),
        animation_frame_mode=args.animation_frame_mode,
        animation_anchor=args.animation_anchor,
        animation_min_frames=max(1, args.animation_min_frames),
        animation_fps=max(1, args.animation_fps),
        pivot_debug=args.pivot_debug,
        pack_atlases=args.pack_atlases,
        atlas_size=max(16, args.atlas_size),
        atlas_padding=max(0, args.atlas_padding),
        atlas_allow_rotation=args.atlas_allow_rotation,
        engine_exports=parse_engine_exports(args.engine_exports),
        detection_settings=DetectionSettings(
            alpha_threshold=max(0, args.alpha_threshold),
            white_threshold=max(0, min(255, args.white_threshold)),
            white_tolerance=max(0, args.white_tolerance),
            dark_artifact_threshold=max(0, min(255, args.dark_artifact_threshold)),
            min_sprite_pixels=max(1, args.min_sprite_pixels),
            min_sprite_width=max(1, args.min_sprite_width),
            min_sprite_height=max(1, args.min_sprite_height),
            crop_padding=max(0, args.crop_padding),
        ),
        on_error=args.on_error,
        workers=max(1, args.workers),
        max_image_megapixels=max(0.0, float(args.max_image_megapixels)),
        resume=args.resume,
        include_archives=bool(args.include_archives),
        auto_detect_all=args.auto_detect_all,
        auto_profile=auto_profile or {},
    )
