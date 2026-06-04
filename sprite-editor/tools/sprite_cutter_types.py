from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass
class SpriteRecord:
    id: str
    display_name: str
    source_sheet: str
    source_file: str
    kind: str
    sheet_mode: str
    category: str
    sequence: str | None
    frame: int | None
    output_file: str
    bbox: dict[str, int]
    width: int
    height: int
    slot_width: int | None
    slot_height: int | None
    foreground_pixels: int
    alpha_mode: str
    is_partial: bool
    transparency_ratio: float
    aspect_ratio: float
    dominant_colors: list[str]
    pivot: dict[str, float | str]
    confidence: float
    review_flags: list[str]
    review_status: str
    atlas: dict[str, object] | None


@dataclass
class DetectedSprite:
    label: int
    x: int
    y: int
    width: int
    height: int
    foreground_pixels: int

    @property
    def right(self) -> int:
        return self.x + self.width

    @property
    def bottom(self) -> int:
        return self.y + self.height

    @property
    def center_x(self) -> float:
        return self.x + self.width / 2

    @property
    def center_y(self) -> float:
        return self.y + self.height / 2


@dataclass
class DetectionSettings:
    alpha_threshold: int = 10
    white_threshold: int = 250
    white_tolerance: int = 8
    dark_artifact_threshold: int = 45
    min_sprite_pixels: int = 24
    min_sprite_width: int = 3
    min_sprite_height: int = 3
    crop_padding: int = 1


@dataclass
class SheetError:
    source_file: str
    error: str


@dataclass
class RunOptions:
    mode: str
    animation_names: list[str]
    animation_frame_mode: str
    animation_anchor: str
    animation_min_frames: int
    animation_fps: int
    pivot_debug: bool
    pack_atlases: bool
    atlas_size: int
    atlas_padding: int
    atlas_allow_rotation: bool
    engine_exports: list[str]
    detection_settings: DetectionSettings
    on_error: str
    workers: int
    max_image_megapixels: float
    resume: bool
    include_archives: bool
    auto_detect_all: bool
    auto_profile: dict[str, object]
