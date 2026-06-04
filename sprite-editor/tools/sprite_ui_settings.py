from __future__ import annotations

import json
import sys
from dataclasses import dataclass, field
from pathlib import Path

try:
    from tools.cut_tileset_sprites import BUILT_IN_PRESETS, is_inside_spritecut_output
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.cut_tileset_sprites import BUILT_IN_PRESETS, is_inside_spritecut_output


SUPPORTED_IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".webp"}
SCRIPT_PATH = Path(__file__).with_name("cut_tileset_sprites.py")


@dataclass
class CutterUiSettings:
    input_path: Path
    auto_detect_all: bool = True
    include_archives: bool = False
    out_name: str = "_organized_sprites"
    mode: str = "auto"
    animation_names: str = ""
    animation_frame_mode: str = "fixed"
    animation_anchor: str = "bottom-center"
    animation_min_frames: int = 3
    animation_fps: int = 12
    pivot_debug: bool = False
    pack_atlases: bool = True
    atlas_size: int = 2048
    atlas_padding: int = 2
    atlas_allow_rotation: bool = False
    engine_exports: list[str] = field(default_factory=lambda: ["unity", "godot", "unreal"])
    alpha_threshold: int = 10
    white_threshold: int = 250
    white_tolerance: int = 8
    dark_artifact_threshold: int = 45
    min_sprite_pixels: int = 24
    min_sprite_width: int = 3
    min_sprite_height: int = 3
    crop_padding: int = 1
    on_error: str = "skip"


@dataclass(frozen=True)
class RunOutputTargets:
    output_dir: Path
    report_path: Path
    project_path: Path


def discover_sheet_files(root: Path) -> list[Path]:
    if root.is_file():
        return [root] if root.suffix.lower() in SUPPORTED_IMAGE_EXTENSIONS else []

    files: list[Path] = []
    for path in root.rglob("*"):
        if "_organized_sprites" in path.parts or is_inside_spritecut_output(path, root):
            continue
        if path.is_file() and path.suffix.lower() in SUPPORTED_IMAGE_EXTENSIONS:
            files.append(path)
    return sorted(files, key=lambda item: item.name.lower())


def build_cutter_command(settings: CutterUiSettings, python_executable: str = sys.executable) -> list[str]:
    command = [
        python_executable,
        str(SCRIPT_PATH),
        "--out-name",
        settings.out_name,
    ]

    if settings.auto_detect_all:
        command.append("--auto-detect-all")
        if settings.include_archives:
            command.append("--include-archives")
        if settings.animation_names.strip():
            command.extend(["--animation-names", settings.animation_names.strip()])
        command.append(str(settings.input_path))
        return command

    command.extend(
        [
            "--manual-defaults",
            "--mode",
            settings.mode,
            "--animation-frame-mode",
            settings.animation_frame_mode,
            "--animation-anchor",
            settings.animation_anchor,
            "--animation-min-frames",
            str(settings.animation_min_frames),
            "--animation-fps",
            str(settings.animation_fps),
            "--alpha-threshold",
            str(settings.alpha_threshold),
            "--white-threshold",
            str(settings.white_threshold),
            "--white-tolerance",
            str(settings.white_tolerance),
            "--dark-artifact-threshold",
            str(settings.dark_artifact_threshold),
            "--min-sprite-pixels",
            str(settings.min_sprite_pixels),
            "--min-sprite-width",
            str(settings.min_sprite_width),
            "--min-sprite-height",
            str(settings.min_sprite_height),
            "--crop-padding",
            str(settings.crop_padding),
            "--on-error",
            settings.on_error,
        ]
    )

    if settings.animation_names.strip():
        command.extend(["--animation-names", settings.animation_names.strip()])
    if settings.include_archives:
        command.append("--include-archives")
    if settings.pivot_debug:
        command.append("--pivot-debug")
    if settings.pack_atlases:
        command.extend(["--pack-atlases", "--atlas-size", str(settings.atlas_size), "--atlas-padding", str(settings.atlas_padding)])
        if settings.atlas_allow_rotation:
            command.append("--atlas-allow-rotation")
    if settings.engine_exports:
        command.extend(["--engine-exports", ",".join(settings.engine_exports)])

    command.append(str(settings.input_path))
    return command


def settings_to_preset_dict(settings: CutterUiSettings) -> dict[str, object]:
    return {
        "out_name": settings.out_name,
        "auto_detect_all": settings.auto_detect_all,
        "include_archives": settings.include_archives,
        "mode": settings.mode,
        "animation_names": settings.animation_names,
        "animation_frame_mode": settings.animation_frame_mode,
        "animation_anchor": settings.animation_anchor,
        "animation_min_frames": settings.animation_min_frames,
        "animation_fps": settings.animation_fps,
        "pivot_debug": settings.pivot_debug,
        "pack_atlases": settings.pack_atlases,
        "atlas_size": settings.atlas_size,
        "atlas_padding": settings.atlas_padding,
        "atlas_allow_rotation": settings.atlas_allow_rotation,
        "engine_exports": settings.engine_exports,
        "alpha_threshold": settings.alpha_threshold,
        "white_threshold": settings.white_threshold,
        "white_tolerance": settings.white_tolerance,
        "dark_artifact_threshold": settings.dark_artifact_threshold,
        "min_sprite_pixels": settings.min_sprite_pixels,
        "min_sprite_width": settings.min_sprite_width,
        "min_sprite_height": settings.min_sprite_height,
        "crop_padding": settings.crop_padding,
        "on_error": settings.on_error,
    }


def settings_from_preset_dict(data: dict[str, object], input_path: Path) -> CutterUiSettings:
    exports = data.get("engine_exports", [])
    if isinstance(exports, str):
        engine_exports = [part.strip() for part in exports.split(",") if part.strip()]
    elif isinstance(exports, list):
        engine_exports = [str(part) for part in exports]
    else:
        engine_exports = []

    return CutterUiSettings(
        input_path=input_path,
        auto_detect_all=bool(data.get("auto_detect_all", False)),
        include_archives=bool(data.get("include_archives", False)),
        out_name=str(data.get("out_name", "_organized_sprites")),
        mode=str(data.get("mode", "auto")),
        animation_names=str(data.get("animation_names", "")),
        animation_frame_mode=str(data.get("animation_frame_mode", "fixed")),
        animation_anchor=str(data.get("animation_anchor", "bottom-center")),
        animation_min_frames=int(data.get("animation_min_frames", 3)),
        animation_fps=int(data.get("animation_fps", 8)),
        pivot_debug=bool(data.get("pivot_debug", False)),
        pack_atlases=bool(data.get("pack_atlases", False)),
        atlas_size=int(data.get("atlas_size", 2048)),
        atlas_padding=int(data.get("atlas_padding", 2)),
        atlas_allow_rotation=bool(data.get("atlas_allow_rotation", False)),
        engine_exports=engine_exports,
        alpha_threshold=int(data.get("alpha_threshold", 10)),
        white_threshold=int(data.get("white_threshold", 250)),
        white_tolerance=int(data.get("white_tolerance", 8)),
        dark_artifact_threshold=int(data.get("dark_artifact_threshold", 45)),
        min_sprite_pixels=int(data.get("min_sprite_pixels", 24)),
        min_sprite_width=int(data.get("min_sprite_width", 3)),
        min_sprite_height=int(data.get("min_sprite_height", 3)),
        crop_padding=int(data.get("crop_padding", 1)),
        on_error=str(data.get("on_error", "skip")),
    )


def save_preset_file(settings: CutterUiSettings, path: Path) -> None:
    path.write_text(json.dumps(settings_to_preset_dict(settings), indent=2), encoding="utf-8")


def load_preset_file(path: Path, input_path: Path) -> CutterUiSettings:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("Preset file must contain a JSON object.")
    return settings_from_preset_dict(data, input_path)


def builtin_preset_names() -> list[str]:
    return sorted(BUILT_IN_PRESETS)


def settings_from_builtin_preset(name: str, input_path: Path) -> CutterUiSettings:
    if name not in BUILT_IN_PRESETS:
        raise ValueError(f"Unknown built-in preset: {name}")
    return settings_from_preset_dict(dict(BUILT_IN_PRESETS[name]), input_path)


def output_targets_from_cli_line(line: str) -> RunOutputTargets | None:
    if not line.startswith("OUTPUT="):
        return None
    output_text = line.split("=", 1)[1].strip()
    if not output_text:
        return None
    output_dir = Path(output_text.replace("\\", "/"))
    return RunOutputTargets(
        output_dir=output_dir,
        report_path=output_dir / "manifest" / "report.html",
        project_path=output_dir / "project.spritecut.json",
    )


def summarize_cli_output_line(line: str) -> list[str]:
    targets = output_targets_from_cli_line(line)
    if targets is None:
        return [line]
    return [
        line,
        f"Report: {targets.report_path}",
        f"Open output folder: {targets.output_dir}",
    ]
