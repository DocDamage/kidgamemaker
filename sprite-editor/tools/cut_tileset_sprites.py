from __future__ import annotations

import argparse
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont

try:
    from tools.sprite_cutter_types import SpriteRecord, DetectedSprite, DetectionSettings, SheetError, RunOptions
    from tools.sprite_pivot import detect_pivot, detect_pivot_centroid, detect_pivot_contour, save_pivot_debug
    from tools.sprite_analysis import dominant_colors, analyze_sprite_pixels, assess_sprite_quality, is_partial_detection, classify_sprite, should_use_full_alpha, safe_name
    from tools.sprite_sheet_classification import coefficient_of_variation, cluster_animation_rows, row_is_animation_like, looks_like_animation_sheet, resolve_sheet_mode, infer_auto_defaults, apply_auto_defaults
    from tools.sprite_engine_export import write_engine_exports, godot_animation_clips, unreal_flipbooks, build_animation_clips, sprite_export_entry
    from tools.sprite_background_detector import detect_background, grouped_components, extract_detections
    from tools.sprite_reports import make_contact_sheet, render_checker

    from tools.sprite_atlas import MaxRectsPacker, PackedRect, Rect, pack_records_into_atlases, rect_contains, rects_intersect
    from tools.sprite_sheet_discovery import SUPPORTED_ARCHIVE_EXTENSIONS, SUPPORTED_IMAGE_EXTENSIONS, discover_sheet_files, extract_archive_sheet_files, is_generated_output_path, is_inside_spritecut_output, natural_key, unique_output_dir
    from tools.sprite_manifest import write_manifest, write_project_file
    from tools.sprite_reports import relative_link, write_html_report, write_visual_qa_report, write_visual_regression_report

    from tools.sprite_cutter_cli import (
        BUILT_IN_PRESETS,
        build_arg_parser,
        build_pre_parser,
        options_from_args,
        load_config_defaults,
    )
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_cutter_types import SpriteRecord, DetectedSprite, DetectionSettings, SheetError, RunOptions
    from tools.sprite_pivot import detect_pivot, detect_pivot_centroid, detect_pivot_contour, save_pivot_debug
    from tools.sprite_analysis import dominant_colors, analyze_sprite_pixels, assess_sprite_quality, is_partial_detection, classify_sprite, should_use_full_alpha, safe_name
    from tools.sprite_sheet_classification import coefficient_of_variation, cluster_animation_rows, row_is_animation_like, looks_like_animation_sheet, resolve_sheet_mode, infer_auto_defaults, apply_auto_defaults
    from tools.sprite_engine_export import write_engine_exports, godot_animation_clips, unreal_flipbooks, build_animation_clips, sprite_export_entry
    from tools.sprite_background_detector import detect_background, grouped_components, extract_detections
    from tools.sprite_reports import make_contact_sheet, render_checker

    from tools.sprite_atlas import MaxRectsPacker, PackedRect, Rect, pack_records_into_atlases, rect_contains, rects_intersect
    from tools.sprite_sheet_discovery import SUPPORTED_ARCHIVE_EXTENSIONS, SUPPORTED_IMAGE_EXTENSIONS, discover_sheet_files, extract_archive_sheet_files, is_generated_output_path, is_inside_spritecut_output, natural_key, unique_output_dir
    from tools.sprite_manifest import write_manifest, write_project_file
    from tools.sprite_reports import relative_link, write_html_report, write_visual_qa_report, write_visual_regression_report

    from tools.sprite_cutter_cli import (
        BUILT_IN_PRESETS,
        build_arg_parser,
        build_pre_parser,
        options_from_args,
        load_config_defaults,
    )

SHEET_PROCESSING_ERRORS = (OSError, ValueError, cv2.error)


def _safe_print(message: object) -> None:
    text = str(message)
    encoding = getattr(sys.stdout, "encoding", None) or "utf-8"
    try:
        print(text)
    except UnicodeEncodeError:
        safe_text = text.encode(encoding, errors="replace").decode(encoding, errors="replace")
        print(safe_text)


from tools.sprite_processing import SheetProcessingHooks, draw_detection_box, make_masked_crop, place_animation_frame
from tools.sprite_processing import process_animation_sheet as _process_animation_sheet
from tools.sprite_processing import process_sheet as _process_sheet
from tools.sprite_processing import process_tileset_sheet as _process_tileset_sheet


def _sheet_processing_hooks() -> SheetProcessingHooks:
    return SheetProcessingHooks(
        sprite_record_cls=SpriteRecord,
        safe_name=safe_name,
        detect_background=detect_background,
        grouped_components=grouped_components,
        extract_detections=extract_detections,
        resolve_sheet_mode=resolve_sheet_mode,
        classify_sprite=classify_sprite,
        should_use_full_alpha=should_use_full_alpha,
        analyze_sprite_pixels=analyze_sprite_pixels,
        detect_pivot=detect_pivot,
        assess_sprite_quality=assess_sprite_quality,
        save_pivot_debug=save_pivot_debug,
        is_partial_detection=is_partial_detection,
        make_contact_sheet=make_contact_sheet,
        cluster_animation_rows=cluster_animation_rows,
    )


def process_tileset_sheet(*args: object, **kwargs: object) -> list[SpriteRecord]:
    kwargs.setdefault("hooks", _sheet_processing_hooks())
    return _process_tileset_sheet(*args, **kwargs)  # type: ignore[return-value]


def process_animation_sheet(*args: object, **kwargs: object) -> list[SpriteRecord]:
    kwargs.setdefault("hooks", _sheet_processing_hooks())
    return _process_animation_sheet(*args, **kwargs)  # type: ignore[return-value]


def process_sheet(source_path: Path, out_dir: Path, preview_dir: Path, options: RunOptions) -> list[SpriteRecord]:
    return _process_sheet(source_path, out_dir, preview_dir, options, _sheet_processing_hooks())  # type: ignore[return-value]


def load_existing_records(manifest_dir: Path) -> list[SpriteRecord]:
    sprites_path = manifest_dir / "sprites.json"
    if not sprites_path.exists():
        return []
    data = json.loads(sprites_path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        return []
    records: list[SpriteRecord] = []
    record_fields = set(SpriteRecord.__dataclass_fields__)
    for item in data:
        if isinstance(item, dict):
            records.append(SpriteRecord(**{key: value for key, value in item.items() if key in record_fields}))
    return records


def load_existing_errors(manifest_dir: Path) -> list[SheetError]:
    errors_path = manifest_dir / "errors.json"
    if not errors_path.exists():
        return []
    data = json.loads(errors_path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        return []
    return [SheetError(**item) for item in data if isinstance(item, dict)]


def process_sheet_batch(
    sheets: list[Path],
    out_dir: Path,
    preview_dir: Path,
    manifest_dir: Path,
    options: RunOptions,
) -> tuple[list[SpriteRecord], list[SheetError], int]:
    all_records: list[SpriteRecord] = load_existing_records(manifest_dir) if options.resume else []
    sheet_errors: list[SheetError] = load_existing_errors(manifest_dir) if options.resume else []
    processed_sources = {str(Path(record.source_file).resolve()) for record in all_records}
    sheets_to_process = [sheet for sheet in sheets if str(sheet.resolve()) not in processed_sources]
    sheets_processed = len({record.source_file for record in all_records})
    if options.workers == 1 or len(sheets) <= 1:
        for sheet in sheets_to_process:
            _safe_print(f"PROCESSING {sheet}")
            try:
                records = process_sheet(sheet, out_dir, preview_dir, options)
            except SHEET_PROCESSING_ERRORS as exc:
                message = f"{type(exc).__name__}: {exc}"
                if options.on_error == "fail":
                    raise SystemExit(f"Failed processing {sheet}: {message}") from exc
                sheet_errors.append(SheetError(source_file=str(sheet), error=message))
                _safe_print(f"SKIPPED {sheet}: {message}")
                continue
            all_records.extend(records)
            sheets_processed += 1
            _safe_print(f"DONE {sheet} sprites={len(records)}")
    else:
        records_by_sheet: dict[Path, list[SpriteRecord]] = {}
        with ThreadPoolExecutor(max_workers=options.workers) as executor:
            futures = {}
            for sheet in sheets_to_process:
                _safe_print(f"PROCESSING {sheet}")
                futures[executor.submit(process_sheet, sheet, out_dir, preview_dir, options)] = sheet
            for future in as_completed(futures):
                sheet = futures[future]
                try:
                    records = future.result()
                    records_by_sheet[sheet] = records
                    _safe_print(f"DONE {sheet} sprites={len(records)}")
                except SHEET_PROCESSING_ERRORS as exc:
                    message = f"{type(exc).__name__}: {exc}"
                    if options.on_error == "fail":
                        raise SystemExit(f"Failed processing {sheet}: {message}") from exc
                    sheet_errors.append(SheetError(source_file=str(sheet), error=message))
                    _safe_print(f"SKIPPED {sheet}: {message}")
        for sheet in sheets_to_process:
            records = records_by_sheet.get(sheet)
            if records is not None:
                all_records.extend(records)
                sheets_processed += 1
    return all_records, sheet_errors, sheets_processed


def write_run_outputs(
    records: list[SpriteRecord],
    out_dir: Path,
    manifest_dir: Path,
    sheets_processed: int,
    sheet_errors: list[SheetError],
    options: RunOptions,
) -> None:
    if options.pack_atlases:
        pack_records_into_atlases(records, out_dir, options)
    animation_clips = build_animation_clips(records, options.animation_fps)
    write_engine_exports(records, out_dir, options.engine_exports, animation_clips)
    write_project_file(records, out_dir, options, sheets_processed, sheet_errors, animation_clips)
    write_manifest(records, manifest_dir, sheets_processed, sheet_errors, options, animation_clips)


def print_run_summary(out_dir: Path, records: list[SpriteRecord]) -> None:
    _safe_print(f"OUTPUT={out_dir}")
    _safe_print(f"SPRITES={len(records)}")
    for kind, count in sorted(Counter(record.kind for record in records).items()):
        _safe_print(f"KIND {kind}={count}")
    for category, count in sorted(Counter(record.category for record in records).items()):
        _safe_print(f"CATEGORY {category}={count}")


def run_from_args(args: argparse.Namespace, config_defaults: dict[str, object], raw_argv: list[str]) -> int:
    input_path = args.root.resolve()
    if not input_path.exists():
        raise SystemExit(f"Missing input: {input_path}")

    output_base = input_path.parent if input_path.is_file() else input_path
    preferred_out_dir = output_base / args.out_name
    out_dir = preferred_out_dir if args.resume and preferred_out_dir.exists() else unique_output_dir(output_base, args.out_name)
    archive_extract_dir = out_dir / "_extracted_archives"

    sheets = discover_sheet_files(input_path, include_archives=args.include_archives, archive_extract_dir=archive_extract_dir)
    if not sheets:
        raise SystemExit(f"No supported image sheets found in {input_path}")

    auto_profile: dict[str, object] = {}
    if args.auto_detect_all:
        auto_profile = infer_auto_defaults(sheets)
        apply_auto_defaults(args, auto_profile, config_defaults, raw_argv)

    preview_dir = out_dir / "previews"
    manifest_dir = out_dir / "manifest"
    preview_dir.mkdir(parents=True, exist_ok=True)
    options = options_from_args(args, auto_profile)
    records, sheet_errors, sheets_processed = process_sheet_batch(sheets, out_dir, preview_dir, manifest_dir, options)
    write_run_outputs(records, out_dir, manifest_dir, sheets_processed, sheet_errors, options)
    print_run_summary(out_dir, records)
    return 0


def run_cli(argv: list[str] | None = None) -> int:
    raw_argv = list(sys.argv[1:] if argv is None else argv)
    pre_parser = build_pre_parser()
    pre_args, _remaining = pre_parser.parse_known_args(raw_argv)
    if pre_args.list_presets:
        for name in sorted(BUILT_IN_PRESETS):
            _safe_print(name)
        return 0
    config_defaults = load_config_defaults(pre_args.config, pre_args.preset)
    parser = build_arg_parser(config_defaults, pre_parser)
    args = parser.parse_args(raw_argv)
    return run_from_args(args, config_defaults, raw_argv)


def main(argv: list[str] | None = None) -> int:
    return run_cli(argv)


if __name__ == "__main__":
    raise SystemExit(main())
