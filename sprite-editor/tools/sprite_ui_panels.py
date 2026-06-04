from __future__ import annotations

import sys
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any, Callable
from uuid import uuid4

from PIL import Image

try:
    import dearpygui.dearpygui as dpg
except ModuleNotFoundError:  # Keep helper tests importable when the GUI dependency is not installed.
    dpg = None  # type: ignore[assignment]

try:
    from tools.sprite_ui_helpers import PREVIEW_ACCESSIBILITY_MODES, tooltip_text
    from tools.sprite_ui_settings import builtin_preset_names
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_ui_helpers import PREVIEW_ACCESSIBILITY_MODES, tooltip_text
    from tools.sprite_ui_settings import builtin_preset_names


class DpgValue:
    def __init__(self, value: Any = None) -> None:
        self._value = value
        self.tag: str | int | None = None
        self._callbacks: list[Callable[..., object]] = []

    def bind(self, tag: str | int) -> "DpgValue":
        self.tag = tag
        if dpg is not None and dpg.does_item_exist(tag):
            dpg.set_value(tag, self._value)
        return self

    def get(self) -> Any:
        if dpg is not None and self.tag is not None and dpg.does_item_exist(self.tag):
            self._value = dpg.get_value(self.tag)
        return self._value

    def set(self, value: Any) -> None:
        self._value = value
        if dpg is not None and self.tag is not None and dpg.does_item_exist(self.tag):
            dpg.set_value(self.tag, value)
        for callback in list(self._callbacks):
            callback(None, None, None)

    def trace_add(self, _mode: str, callback: Callable[..., object]) -> None:
        self._callbacks.append(callback)


class DpgSelectableList:
    def __init__(self, parent: str | int, *, multi: bool = False, on_select: Callable[[], object] | None = None) -> None:
        self.parent = parent
        self.multi = multi
        self.on_select = on_select
        self.labels: list[str] = []
        self.tags: list[str] = []
        self.selected: set[int] = set()

    def clear(self) -> None:
        self.labels = []
        self.tags = []
        self.selected = set()
        if dpg is not None and dpg.does_item_exist(self.parent):
            dpg.delete_item(self.parent, children_only=True)

    def set_items(self, labels: list[str], *, select_first: bool = False) -> None:
        self.clear()
        self.labels = labels
        if dpg is None or not dpg.does_item_exist(self.parent):
            return
        for index, label in enumerate(labels):
            tag = f"{self.parent}_item_{index}_{uuid4().hex}"
            self.tags.append(tag)
            dpg.add_selectable(
                label=label,
                tag=tag,
                parent=self.parent,
                callback=self._on_select,
                user_data=index,
                span_columns=True,
            )
        if select_first and labels:
            self.select(0)

    def _on_select(self, _sender: object, app_data: object, user_data: object) -> None:
        index = int(user_data)
        is_selected = bool(app_data)
        if self.multi:
            if is_selected:
                self.selected.add(index)
            else:
                self.selected.discard(index)
        else:
            self.selected = {index} if is_selected else set()
            if is_selected and dpg is not None:
                for other_index, tag in enumerate(self.tags):
                    if other_index != index and dpg.does_item_exist(tag):
                        dpg.set_value(tag, False)
        if self.on_select is not None:
            self.on_select()

    def select(self, index: int, *, additive: bool = False) -> None:
        if index < 0 or index >= len(self.labels):
            return
        if not self.multi or not additive:
            self.selected = {index}
            if dpg is not None:
                for other_index, tag in enumerate(self.tags):
                    if dpg.does_item_exist(tag):
                        dpg.set_value(tag, other_index == index)
        else:
            self.selected.add(index)
            if dpg is not None and index < len(self.tags) and dpg.does_item_exist(self.tags[index]):
                dpg.set_value(self.tags[index], True)

    def selected_indices(self) -> list[int]:
        return sorted(index for index in self.selected if 0 <= index < len(self.labels))


class ToolTip:
    def __init__(self, item: str | int, text: str) -> None:
        self.item = item
        self.text = text
        if dpg is not None and dpg.does_item_exist(item):
            with dpg.tooltip(item):
                dpg.add_text(text, wrap=320)


def attach_tooltip(item: str | int, key: str) -> str | int:
    ToolTip(item, tooltip_text(key))
    return item


def _require_dearpygui() -> None:
    if dpg is None:
        raise RuntimeError("Dear PyGUI is required for the desktop UI. Install it with: pip install dearpygui")


def _image_texture_data(image: Image.Image) -> tuple[int, int, list[float]]:
    import numpy as np

    rgba = image.convert("RGBA")
    data = (np.asarray(rgba, dtype=np.float32) / 255.0).ravel().tolist()
    return rgba.width, rgba.height, data


class SpriteToolPanel(ABC):
    def __init__(self, app: Any) -> None:
        self.app = app

    @abstractmethod
    def build(self) -> None:
        return None


class LeftInputPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        dpg.add_text("Input")
        app._add_input_text("##input_path", app.input_path, "input_path", "input_path", width=-1)
        app._add_button("Add Folder", app.choose_folder, "add_folder", width=-1)
        app._add_button("Add File", app.choose_file, "add_file", width=-1)
        app._add_button("Refresh", app.refresh_files, "refresh_files", width=-1)
        app._add_button("Sample Pack", app.create_sample_pack_dialog, "create_sample_pack", width=-1)
        dpg.add_spacer(height=8)
        dpg.add_text("Sheets")
        with dpg.child_window(tag="file_list_panel", width=-1, height=470, border=True):
            dpg.add_spacer(height=1)
        attach_tooltip("file_list_panel", "file_list")
        app.file_list = DpgSelectableList("file_list_panel", on_select=app.update_preview)


class CenterPreviewPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        with dpg.group(horizontal=True):
            dpg.add_text("Preview")
            dpg.add_spacer(width=330)
            app._add_combo("##preview_accessibility", app.preview_accessibility_mode, PREVIEW_ACCESSIBILITY_MODES, "preview_accessibility", width=150, callback=lambda *_args: app.update_preview())
        with dpg.child_window(tag="preview_panel", width=-1, height=520, border=True):
            dpg.add_text("Choose a folder or file to preview sheets.", tag="preview_placeholder", wrap=620)
        with dpg.group(horizontal=True):
            dpg.add_text("Idle", tag="progress_text")
            app._add_button("Process", app.process, "process", tag="process_button")
            app._add_button("Reset Log", app.clear_log, "reset_log")
            app._add_button("Cancel", app.cancel_process, "cancel", tag="cancel_button", enabled=False)
        with dpg.group(horizontal=True):
            app._add_button("Open Output", app.open_latest_output, "open_output", tag="open_output_button", enabled=False)
            app._add_button("Open Report", app.open_latest_report, "open_report", tag="open_report_button", enabled=False)
            app._add_button("Open Project", app.open_latest_project, "open_project", tag="open_project_button", enabled=False)
        dpg.add_input_text(tag="log_text", multiline=True, readonly=True, width=-1, height=150, default_value="")


class RunSettingsPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        dpg.add_text("Output")
        app._add_input_text("##out_name", app.out_name, "out_name", "out_name", width=-1)
        app._add_checkbox("Auto detect all", app.auto_detect_all, "auto_detect_all")
        app._add_checkbox("Include ZIP archives", app.include_archives, "include_archives")
        dpg.add_text("Built-In Preset")
        app._add_combo("##builtin_preset", app.builtin_preset, builtin_preset_names(), "builtin_preset", width=-1)
        app._add_button("Apply Preset", app.apply_builtin_preset, "apply_preset", width=-1)
        dpg.add_text("Mode")
        app._add_combo("##mode", app.mode, ["auto", "tileset", "animation"], "mode", width=-1)
        dpg.add_text("Animation Rows")
        app._add_input_text("##animation_names", app.animation_names, "animation_names", "animation_names", width=-1)
        dpg.add_text("Frame Mode")
        app._add_combo("##animation_frame_mode", app.animation_frame_mode, ["fixed", "trimmed"], "animation_frame_mode", width=-1)
        dpg.add_text("Anchor")
        app._add_combo("##animation_anchor", app.animation_anchor, ["bottom-center", "center"], "animation_anchor", width=-1)
        app._add_input_int("Min Frames", app.animation_min_frames, "animation_min_frames", "animation_min_frames", min_value=1, max_value=24)
        app._add_input_int("FPS", app.animation_fps, "animation_fps", "animation_fps", min_value=1, max_value=60)
        app._add_checkbox("Pivot debug previews", app.pivot_debug, "pivot_debug")


class DetectionSettingsPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        controls = [
            ("Alpha Threshold", app.alpha_threshold, 0, 255, "alpha_threshold"),
            ("White Threshold", app.white_threshold, 0, 255, "white_threshold"),
            ("White Tolerance", app.white_tolerance, 0, 64, "white_tolerance"),
            ("Dark Artifact", app.dark_artifact_threshold, 0, 255, "dark_artifact_threshold"),
            ("Min Pixels", app.min_sprite_pixels, 1, 10000, "min_sprite_pixels"),
            ("Min Width", app.min_sprite_width, 1, 512, "min_sprite_width"),
            ("Min Height", app.min_sprite_height, 1, 512, "min_sprite_height"),
            ("Crop Padding", app.crop_padding, 0, 64, "crop_padding"),
        ]
        for label, variable, min_value, max_value, tooltip_key in controls:
            app._add_input_int(label, variable, tooltip_key, tooltip_key, min_value=min_value, max_value=max_value)
        dpg.add_text("On Error")
        app._add_combo("##on_error", app.on_error, ["skip", "fail"], "on_error", width=-1)


class OutputSettingsPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        app._add_checkbox("Pack atlases", app.pack_atlases, "pack_atlases")
        app._add_input_int("Atlas Size", app.atlas_size, "atlas_size", "atlas_size", min_value=64, max_value=16384)
        app._add_input_int("Padding", app.atlas_padding, "atlas_padding", "atlas_padding", min_value=0, max_value=128)
        app._add_checkbox("Allow rotation", app.atlas_allow_rotation, "atlas_allow_rotation")
        dpg.add_text("Exports")
        attach_tooltip(dpg.last_item(), "engine_exports")
        app._add_checkbox("Unity", app.export_unity, "export_unity")
        app._add_checkbox("Godot", app.export_godot, "export_godot")
        app._add_checkbox("Unreal", app.export_unreal, "export_unreal")
        dpg.add_spacer(height=10)
        app._add_button("Save Preset", app.save_preset, "save_preset", width=-1)
        app._add_button("Load Preset", app.load_preset, "load_preset", width=-1)
