from __future__ import annotations

import json
from pathlib import Path

try:
    from tools.sprite_cutter_types import SpriteRecord
except ModuleNotFoundError:
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_cutter_types import SpriteRecord


def sprite_export_entry(record: SpriteRecord) -> dict[str, object]:
    return {
        "name": record.id,
        "display_name": record.display_name,
        "kind": record.kind,
        "category": record.category,
        "sequence": record.sequence,
        "frame": record.frame,
        "source_file": record.output_file,
        "source_rect": record.bbox,
        "size": {"width": record.width, "height": record.height},
        "pivot": record.pivot,
        "atlas": record.atlas,
        "is_partial": record.is_partial,
        "confidence": record.confidence,
        "review_flags": record.review_flags,
        "review_status": record.review_status,
    }


def build_animation_clips(records: list[SpriteRecord], frame_rate: int) -> list[dict[str, object]]:
    grouped: dict[tuple[str, str], list[SpriteRecord]] = {}
    for record in records:
        if record.kind != "animation_frame" or not record.sequence:
            continue
        grouped.setdefault((record.source_sheet, record.sequence), []).append(record)

    clips: list[dict[str, object]] = []
    duration = round(1.0 / max(1, frame_rate), 4)
    for (source_sheet, sequence), frames in sorted(grouped.items(), key=lambda item: (item[0][0], item[0][1])):
        ordered = sorted(frames, key=lambda record: record.frame if record.frame is not None else 0)
        clips.append(
            {
                "name": f"{source_sheet}_{sequence}",
                "source_sheet": source_sheet,
                "sequence": sequence,
                "frame_rate": max(1, frame_rate),
                "loop": True,
                "frame_count": len(ordered),
                "frames": [
                    {
                        "sprite": record.id,
                        "display_name": record.display_name,
                        "frame": record.frame,
                        "source_file": record.output_file,
                        "duration": duration,
                        "bbox": record.bbox,
                        "pivot": record.pivot,
                        "atlas": record.atlas,
                        "review_status": record.review_status,
                    }
                    for record in ordered
                ],
            }
        )
    return clips


def godot_animation_clips(animation_clips: list[dict[str, object]]) -> list[dict[str, object]]:
    animations: list[dict[str, object]] = []
    for clip in animation_clips:
        animations.append(
            {
                "name": clip["name"],
                "speed_fps": clip["frame_rate"],
                "loop": clip["loop"],
                "frames": [
                    {
                        "sprite": frame["sprite"],
                        "source_file": frame["source_file"],
                        "duration": frame["duration"],
                        "atlas": frame["atlas"],
                    }
                    for frame in clip["frames"]  # type: ignore[index]
                ],
            }
        )
    return animations


def unreal_flipbooks(animation_clips: list[dict[str, object]]) -> list[dict[str, object]]:
    flipbooks: list[dict[str, object]] = []
    for clip in animation_clips:
        frames = []
        for index, frame in enumerate(clip["frames"]):  # type: ignore[index]
            frames.append(
                {
                    "sprite": frame["sprite"],
                    "key_frame": index,
                    "duration": frame["duration"],
                    "source_file": frame["source_file"],
                    "atlas": frame["atlas"],
                }
            )
        flipbooks.append({"name": clip["name"], "frame_rate": clip["frame_rate"], "loop": clip["loop"], "frames": frames})
    return flipbooks


def write_engine_exports(records: list[SpriteRecord], out_dir: Path, engines: list[str], animation_clips: list[dict[str, object]]) -> None:
    if not engines:
        return

    exports_dir = out_dir / "exports"
    exports_dir.mkdir(parents=True, exist_ok=True)
    base_entries = [sprite_export_entry(record) for record in records]
    import_settings = {
        "texture_type": "sprite",
        "sprite_mode": "multiple",
        "filter_mode": "point",
        "compression": "none",
        "alpha_is_transparency": True,
    }

    if "unity" in engines:
        with (exports_dir / "unity_sprites.json").open("w", encoding="utf-8") as handle:
            json.dump({"engine": "unity", "import_settings": import_settings, "sprites": base_entries, "animation_clips": animation_clips}, handle, indent=2)

    if "godot" in engines:
        godot_entries = []
        for entry in base_entries:
            godot_entry = dict(entry)
            godot_entry["pivot_offset"] = {
                "x": round((float(entry["pivot"]["x"]) - 0.5) * float(entry["size"]["width"]), 4),
                "y": round((float(entry["pivot"]["y"]) - 0.5) * float(entry["size"]["height"]), 4),
            }
            godot_entries.append(godot_entry)
        with (exports_dir / "godot_sprites.json").open("w", encoding="utf-8") as handle:
            json.dump(
                {
                    "engine": "godot",
                    "import_settings": {"filter": False, "repeat": False, "mipmaps": False},
                    "sprites": godot_entries,
                    "animations": godot_animation_clips(animation_clips),
                },
                handle,
                indent=2,
            )

    if "unreal" in engines:
        unreal_entries = []
        for entry in base_entries:
            unreal_entry = dict(entry)
            unreal_entry["pivot"] = {"x": entry["pivot"]["x"], "y": round(1.0 - float(entry["pivot"]["y"]), 4), "method": entry["pivot"]["method"]}
            unreal_entries.append(unreal_entry)
        with (exports_dir / "unreal_sprites.json").open("w", encoding="utf-8") as handle:
            json.dump(
                {
                    "engine": "unreal",
                    "import_settings": {"texture_group": "2D Pixels", "compression": "UserInterface2D", "filter": "Nearest"},
                    "sprites": unreal_entries,
                    "flipbooks": unreal_flipbooks(animation_clips),
                },
                handle,
                indent=2,
            )
