from __future__ import annotations

import hashlib
import json
import re
import shutil
import struct
from argparse import ArgumentParser, Namespace
from pathlib import Path
from typing import Any


SOURCE_ROOT = Path(r"G:\All 2D Assets Stay Here\ansimuz")
MANIFEST_PATH = SOURCE_ROOT / "ansimuz_sprite_final_renames.kimi.json"
SOURCE_INDEX_PATH = SOURCE_ROOT / "ansimuz_sprite_learning_index.vision.json"
ASSET_ROOT = Path("engine/data/assets")
SUPPORTED_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".svg"}
REPORT_NAME = "ansimuz_ingest_report.json"
SHEET_TERMS = ("spritesheet", "sprite_sheet", "sheet", "atlas", "tileset", "tilemap", "preview")
ENEMY_TERMS = (
    "enemy",
    "monster",
    "boss",
    "slime",
    "demon",
    "dragon",
    "skull",
    "skeleton",
    "wolf",
    "snake",
    "raptor",
    "lizard",
    "golem",
    "ghost",
    "wraith",
    "imp",
    "bat",
    "spider",
    "drone",
)
HERO_TERMS = (
    "hero",
    "player",
    "knight",
)
COLLECTIBLE_TERMS = (
    "coin",
    "gem",
    "heart",
    "item",
    "pickup",
    "key",
    "fruit",
    "potion",
    "dagger",
    "sword",
    "axe",
    "shield",
    "weapon",
)


def parse_args() -> Namespace:
    parser = ArgumentParser(description="Import the Ansimuz sprite manifest into KidGameMaker asset sidecars.")
    parser.add_argument("--source-root", type=Path, default=SOURCE_ROOT, help="Root folder containing the Ansimuz manifests.")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd(), help="KidGameMaker repository root.")
    parser.add_argument("--manifest", type=Path, default=None, help="Final rename manifest path.")
    parser.add_argument("--source-index", type=Path, default=None, help="Vision/source index manifest path.")
    parser.add_argument("--dry-run", action="store_true", help="Report what would be imported without writing files.")
    parser.add_argument("--keep-existing", action="store_true", help="Do not remove previous ansimuz_* imported asset folders first.")
    return parser.parse_args()


def read_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SystemExit(f"Missing required manifest: {path}") from exc
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Invalid JSON in {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise SystemExit(f"Expected JSON object in {path}")
    return value


def safe_id(value: str) -> str:
    cleaned = re.sub(r"[^a-zA-Z0-9_]+", "_", value.strip().lower())
    cleaned = re.sub(r"_+", "_", cleaned).strip("_")
    return cleaned or "asset"


def humanize(value: str) -> str:
    return " ".join(part.capitalize() for part in re.split(r"[_\-\s]+", value) if part)


def tags_for(*values: str) -> list[str]:
    tags: list[str] = []
    seen: set[str] = set()
    for value in values:
        for part in re.split(r"[^a-zA-Z0-9]+", value.lower()):
            if part and part not in seen:
                seen.add(part)
                tags.append(part)
    return tags


def map_category(source_category: str, asset_id: str, source_text: str = "") -> tuple[str, str, str, str]:
    category = source_category.lower()
    lower_id = asset_id.lower()
    haystack = f"{lower_id} {category} {source_text.lower()}"
    semantic_tokens = semantic_words(lower_id)
    parallax = "deep_background" if "background" in category or "parallax" in category else "play_layer"

    if any(term in semantic_tokens for term in COLLECTIBLE_TERMS):
        return "collectibles", "collectible", "free_float", parallax
    if "tiles" in category or "terrain" in category:
        return "terrain", "terrain", "edge_to_edge", parallax
    if any(term in semantic_tokens for term in ENEMY_TERMS):
        return "enemies", "enemy", "gravity_snap", parallax
    if any(term in semantic_tokens for term in HERO_TERMS):
        return "heroes", "player", "gravity_snap", parallax
    return "decorations", "decoration", "free_float", parallax


def semantic_words(text: str) -> set[str]:
    return set(re.findall(r"[a-z0-9]+", text.lower()))


def png_dimensions(path: Path) -> tuple[int, int] | None:
    with path.open("rb") as handle:
        header = handle.read(24)
    if len(header) >= 24 and header.startswith(b"\x89PNG\r\n\x1a\n"):
        return struct.unpack(">II", header[16:24])
    return None


def jpeg_dimensions(path: Path) -> tuple[int, int] | None:
    data = path.read_bytes()
    index = 2
    while index + 9 < len(data):
        if data[index] != 0xFF:
            index += 1
            continue
        marker = data[index + 1]
        index += 2
        if marker in (0xD8, 0xD9):
            continue
        if index + 2 > len(data):
            return None
        length = int.from_bytes(data[index:index + 2], "big")
        if marker in {0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF}:
            if index + 7 <= len(data):
                height = int.from_bytes(data[index + 3:index + 5], "big")
                width = int.from_bytes(data[index + 5:index + 7], "big")
                return width, height
            return None
        index += length
    return None


def image_dimensions(path: Path) -> tuple[int, int]:
    lower = path.suffix.lower()
    try:
        if lower == ".png":
            found = png_dimensions(path)
        elif lower in {".jpg", ".jpeg"}:
            found = jpeg_dimensions(path)
        else:
            found = None
    except OSError:
        found = None
    return found or (48, 48)


def unique_asset_id(group: dict[str, Any]) -> str:
    base = safe_id(str(group.get("final_semantic_base") or group.get("path_semantic_base") or "ansimuz_asset"))
    group_key = str(group.get("group") or group.get("representative_file") or base)
    digest = hashlib.sha1(group_key.encode("utf-8")).hexdigest()[:8]
    return f"ansimuz_{base}_{digest}"


def target_filename(asset_id: str, source_path: Path, index: int | None = None) -> str:
    suffix = source_path.suffix.lower()
    if index is None:
        return f"{asset_id}{suffix}"
    return f"{asset_id}_frame_{index:03d}{suffix}"


def collect_group_files(
    group: dict[str, Any],
    source_groups: dict[str, dict[str, Any]],
) -> list[str]:
    source_group = source_groups.get(str(group.get("group") or ""), {})
    files = [
        str(file)
        for file in group.get("files", []) or source_group.get("files", [])
        if isinstance(file, str) and Path(file).suffix.lower() in SUPPORTED_EXTENSIONS
    ]
    if not files:
        representative = str(group.get("representative_file") or "")
        if representative and Path(representative).suffix.lower() in SUPPORTED_EXTENSIONS:
            files = [representative]
    return files


def is_stamp_ready_group(group: dict[str, Any], files: list[str]) -> bool:
    if str(group.get("kind") or "").lower() == "animation_sequence":
        return False
    source_category = str(group.get("category") or "").lower()
    if "background" in source_category or "parallax" in source_category:
        return False
    if len(files) != 1:
        return False
    file_name = Path(files[0]).stem.lower()
    group_text = (
        f"{group.get('group', '')} {group.get('representative_file', '')} "
        f"{group.get('final_semantic_base', '')} {group.get('path_semantic_base', '')}"
    ).lower()
    return not any(term in file_name or term in group_text for term in SHEET_TERMS)


def ingest_group(
    group: dict[str, Any],
    repo_root: Path,
    source_root: Path,
    source_groups: dict[str, dict[str, Any]],
    dry_run: bool,
) -> dict[str, Any] | None:
    files = collect_group_files(group, source_groups)
    if not files:
        return None
    if not is_stamp_ready_group(group, files):
        return None

    asset_id = unique_asset_id(group)
    source_category = str(group.get("category") or "")
    source_text = f"{group.get('relative_dir', '')} {group.get('final_semantic_base', '')} {group.get('path_semantic_base', '')}"
    category, template, snapping, parallax = map_category(source_category, asset_id, source_text)
    dest_dir = repo_root / ASSET_ROOT / category / asset_id

    copied_files: list[str] = []
    for index, relative in enumerate(files, start=1):
        source_path = source_root / relative
        if not source_path.exists():
            continue
        output_name = target_filename(asset_id, source_path, index if len(files) > 1 else None)
        if not dry_run:
            dest_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_path, dest_dir / output_name)
        copied_files.append(output_name)

    if not copied_files:
        return None

    first_image = source_root / files[0] if dry_run else dest_dir / copied_files[0]
    width, height = image_dimensions(first_image)
    sidecar = {
        "schema_version": 1,
        "asset_id": asset_id,
        "asset_name": humanize(str(group.get("final_semantic_base") or asset_id)),
        "category": category,
        "runtime_template": template,
        "visual": copied_files[0],
        "visual_tags": tags_for(asset_id, source_category, str(group.get("relative_dir") or "")),
        "source_pack": "ansimuz",
        "source_author": "ansimuz",
        "source_collection": "ansimuz",
        "source_group": group.get("group"),
        "source_category": source_category,
        "source_kind": group.get("kind"),
        "source_file_count": len(copied_files),
        "is_spritesheet": len(copied_files) > 1 or "spritesheet" in copied_files[0].lower(),
        "is_uniform_grid": False,
        "grid_cell_size": None,
        "slicing_confidence": group.get("rename_confidence", 1.0),
        "frames": [{"x": 0, "y": 0, "w": width, "h": height}],
        "placement_logic": {
            "snapping_type": snapping,
            "parallax_bucket": parallax,
        },
        "collision": {
            "shape": "rectangle",
            "size": [width, height],
        },
    }
    if len(copied_files) > 1:
        sidecar["animation_data"] = {
            "frame_files": copied_files,
            "frame_count": len(copied_files),
            "fps": 12,
            "loop": True,
        }

    if not dry_run:
        (dest_dir / f"{asset_id}.json").write_text(json.dumps(sidecar, indent=2), encoding="utf-8")
    return {"asset_id": asset_id, "category": category, "files": len(copied_files)}


def clean_previous_import(repo_root: Path) -> None:
    asset_root = repo_root / ASSET_ROOT
    if not asset_root.exists():
        return
    asset_root = asset_root.resolve()
    for category_dir in asset_root.iterdir():
        if not category_dir.is_dir() or category_dir.name == "_reports":
            continue
        for asset_dir in category_dir.iterdir():
            resolved_asset_dir = asset_dir.resolve()
            if (
                asset_dir.is_dir()
                and asset_dir.name.startswith("ansimuz_")
                and resolved_asset_dir.parent == category_dir.resolve()
            ):
                shutil.rmtree(asset_dir)


def validate_import(repo_root: Path) -> dict[str, Any]:
    asset_root = repo_root / ASSET_ROOT
    sidecars = [path for path in asset_root.rglob("ansimuz_*.json") if "_reports" not in path.parts]
    errors: list[str] = []
    image_files = 0

    for sidecar_path in sidecars:
        try:
            data = json.loads(sidecar_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{sidecar_path}: {exc}")
            continue

        for key in ("asset_id", "asset_name", "category", "runtime_template", "visual", "frames", "collision", "placement_logic"):
            if key not in data:
                errors.append(f"{sidecar_path}: missing {key}")

        visual = data.get("visual")
        if not isinstance(visual, str) or not (sidecar_path.parent / visual).exists():
            errors.append(f"{sidecar_path}: missing visual file {visual!r}")

        animation_data = data.get("animation_data", {})
        if isinstance(animation_data, dict):
            frame_files = animation_data.get("frame_files", [])
            if isinstance(frame_files, list):
                for frame_file in frame_files:
                    if not isinstance(frame_file, str) or not (sidecar_path.parent / frame_file).exists():
                        errors.append(f"{sidecar_path}: missing animation frame {frame_file!r}")

        image_files += sum(
            1
            for child in sidecar_path.parent.iterdir()
            if child.is_file() and child.suffix.lower() in SUPPORTED_EXTENSIONS
        )

    return {
        "sidecars": len(sidecars),
        "image_files": image_files,
        "errors": errors,
    }


def build_summary(
    source_root: Path,
    manifest_path: Path,
    source_index_path: Path,
    imported: list[dict[str, Any]],
    skipped: int,
    dry_run: bool,
    validation: dict[str, Any] | None,
) -> dict[str, Any]:
    categories: dict[str, int] = {}
    files_by_category: dict[str, int] = {}
    for item in imported:
        category = str(item["category"])
        categories[category] = categories.get(category, 0) + 1
        files_by_category[category] = files_by_category.get(category, 0) + int(item["files"])

    summary: dict[str, Any] = {
        "source_root": str(source_root),
        "manifest": str(manifest_path),
        "source_index": str(source_index_path),
        "dry_run": dry_run,
        "imported_groups": len(imported),
        "imported_files": sum(int(item["files"]) for item in imported),
        "skipped_groups": skipped,
        "categories": dict(sorted(categories.items())),
        "files_by_category": dict(sorted(files_by_category.items())),
        "supported_extensions": sorted(SUPPORTED_EXTENSIONS),
    }
    if validation is not None:
        summary["validation"] = {
            "sidecars": validation["sidecars"],
            "image_files": validation["image_files"],
            "errors": validation["errors"][:25],
            "error_count": len(validation["errors"]),
        }
    return summary


def main() -> None:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    source_root = args.source_root.resolve()
    manifest_path = (args.manifest or source_root / MANIFEST_PATH.name).resolve()
    source_index_path = (args.source_index or source_root / SOURCE_INDEX_PATH.name).resolve()

    manifest = read_json(manifest_path)
    source_index = read_json(source_index_path)
    source_groups = {
        str(group.get("group") or ""): group
        for group in source_index.get("groups", [])
        if isinstance(group, dict)
    }
    imported: list[dict[str, Any]] = []
    skipped = 0

    if not args.keep_existing and not args.dry_run:
        clean_previous_import(repo_root)

    for group in manifest.get("groups", []):
        if not isinstance(group, dict):
            skipped += 1
            continue
        result = ingest_group(group, repo_root, source_root, source_groups, args.dry_run)
        if result is None:
            skipped += 1
        else:
            imported.append(result)

    validation = None if args.dry_run else validate_import(repo_root)
    summary = build_summary(source_root, manifest_path, source_index_path, imported, skipped, args.dry_run, validation)
    if validation is not None and validation["errors"]:
        print(json.dumps(summary, indent=2))
        raise SystemExit(1)

    if not args.dry_run:
        report_dir = repo_root / ASSET_ROOT / "_reports"
        report_dir.mkdir(parents=True, exist_ok=True)
        report_path = report_dir / REPORT_NAME
        report_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
