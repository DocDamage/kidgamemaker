from __future__ import annotations

from pathlib import Path
from typing import Any


class UiController:
    def __init__(self, app: Any) -> None:
        self.app = app


class ProcessingController(UiController):
    def process(self, *args: object) -> None:
        self.app._process_impl(*args)


class ReviewProjectController(UiController):
    def refresh_project_rows(self, *args: object) -> None:
        self.app._refresh_project_rows_impl(*args)


class StudioController(UiController):
    def refresh_studio_panel(self, *args: object) -> None:
        self.app._refresh_studio_panel_impl(*args)


class SpriteEditorController(UiController):
    def load_editor_sprite(self, path: Path) -> None:
        self.app._load_editor_sprite_impl(path)

    def _load_editor_sprite_impl(self, path: Path) -> None:
        self.load_editor_sprite(path)

    def apply_palette_swap(self, *args: object) -> None:
        self.app._apply_editor_palette_swap_impl(*args)

    def apply_hue_shift(self, *args: object) -> None:
        self.app._apply_editor_hue_shift_impl(*args)

    def apply_crop(self, *args: object) -> None:
        self.app._apply_editor_crop_impl(*args)

    def apply_resize(self, *args: object) -> None:
        self.app._apply_editor_resize_impl(*args)

    def apply_flip(self, *args: object) -> None:
        self.app._apply_editor_flip_impl(*args)

    def apply_rotate(self, *, clockwise: bool = True) -> None:
        self.app._apply_editor_rotate_impl(clockwise=clockwise)
