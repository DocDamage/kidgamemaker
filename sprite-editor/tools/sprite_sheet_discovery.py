from __future__ import annotations

import re
import zipfile
from pathlib import Path


SUPPORTED_IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".webp"}
SUPPORTED_ARCHIVE_EXTENSIONS = {".zip"}


def natural_key(value: str) -> list[object]:
    return [int(part) if part.isdigit() else part.lower() for part in re.split(r"(\d+)", value)]


def unique_output_dir(root: Path, preferred_name: str) -> Path:
    candidate = root / preferred_name
    if not candidate.exists():
        return candidate

    index = 2
    while True:
        candidate = root / f"{preferred_name}_{index}"
        if not candidate.exists():
            return candidate
        index += 1


def is_generated_output_path(path: Path) -> bool:
    return any(part.lower().startswith("_organized_sprites") for part in path.parts)


def is_inside_spritecut_output(path: Path, root: Path) -> bool:
    current = path if path.is_dir() else path.parent
    while True:
        if (current / "project.spritecut.json").exists() or (current / "manifest" / "sprites.json").exists():
            return True
        if current == root or current == current.parent:
            return False
        current = current.parent


def _safe_extract_relative_path(raw_name: str) -> Path | None:
    normalized = raw_name.replace("\\", "/")
    if normalized.startswith("/") or normalized.startswith("../") or "/../" in normalized:
        return None
    raw_parts = normalized.split("/")
    cleaned_parts: list[str] = []
    for part in raw_parts:
        cleaned = re.sub(r'[<>:"|?*\x00-\x1f]+', "_", part.strip())
        cleaned = cleaned.rstrip(".")
        if cleaned in {"", ".", ".."}:
            return None
        cleaned_parts.append(cleaned)
    relative = Path(*cleaned_parts)
    if relative.is_absolute() or any(part in {"", ".", ".."} for part in relative.parts):
        return None
    return relative


def _safe_archive_folder_name(path: Path) -> str:
    name = re.sub(r"[^A-Za-z0-9_.-]+", "_", path.stem).strip("._")
    return name or "archive"


def _is_appledouble_metadata_path(path: Path) -> bool:
    return any(part == "__MACOSX" or part.startswith("._") for part in path.parts)


def extract_archive_sheet_files(archive_path: Path, destination_root: Path) -> list[Path]:
    if archive_path.suffix.lower() not in SUPPORTED_ARCHIVE_EXTENSIONS:
        return []

    output_root = destination_root / _safe_archive_folder_name(archive_path)
    extracted: list[Path] = []
    try:
        with zipfile.ZipFile(archive_path) as archive:
            for member in archive.infolist():
                relative = _safe_extract_relative_path(member.filename)
                if (
                    relative is None
                    or member.is_dir()
                    or _is_appledouble_metadata_path(relative)
                    or relative.suffix.lower() not in SUPPORTED_IMAGE_EXTENSIONS
                ):
                    continue
                target = output_root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                with archive.open(member) as source, target.open("wb") as handle:
                    handle.write(source.read())
                extracted.append(target)
    except zipfile.BadZipFile:
        return []

    return sorted(extracted, key=lambda path: natural_key(str(path.relative_to(output_root))))


def _sheet_sort_key(path: Path, root: Path) -> list[object]:
    try:
        return natural_key(str(path.relative_to(root)))
    except ValueError:
        return natural_key(str(path))


def _is_relative_to(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root)
    except ValueError:
        return False
    return True


def discover_sheet_files(input_path: Path, *, include_archives: bool = False, archive_extract_dir: Path | None = None) -> list[Path]:
    if input_path.is_file():
        if input_path.suffix.lower() in SUPPORTED_IMAGE_EXTENSIONS:
            return [input_path]
        if include_archives and archive_extract_dir is not None:
            return extract_archive_sheet_files(input_path, archive_extract_dir)
        return []

    sheets: list[Path] = []
    for path in input_path.rglob("*"):
        if archive_extract_dir is not None and _is_relative_to(path, archive_extract_dir):
            continue
        if is_generated_output_path(path) or is_inside_spritecut_output(path, input_path):
            continue
        if not path.is_file():
            continue
        if _is_appledouble_metadata_path(path):
            continue
        if path.suffix.lower() in SUPPORTED_IMAGE_EXTENSIONS:
            sheets.append(path)
        elif include_archives and archive_extract_dir is not None and path.suffix.lower() in SUPPORTED_ARCHIVE_EXTENSIONS:
            relative = path.relative_to(input_path).with_suffix("")
            archive_destination = archive_extract_dir / relative.parent
            sheets.extend(extract_archive_sheet_files(path, archive_destination))
    return sorted(sheets, key=lambda path: _sheet_sort_key(path, input_path))
