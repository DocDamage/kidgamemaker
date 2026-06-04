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
    from tools.sprite_ui_helpers import PREVIEW_ACCESSIBILITY_MODES, REVIEW_CANVAS_SIZE, tooltip_text
    from tools.sprite_ui_settings import builtin_preset_names
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_ui_helpers import PREVIEW_ACCESSIBILITY_MODES, REVIEW_CANVAS_SIZE, tooltip_text
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


class SettingsTabsPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        dpg.add_text("Settings")
        with dpg.tab_bar(tag="settings_tabs"):
            with dpg.tab(label="Core"):
                RunSettingsPanel(app).build()
            with dpg.tab(label="Detect"):
                DetectionSettingsPanel(app).build()
            with dpg.tab(label="Output"):
                OutputSettingsPanel(app).build()
            with dpg.tab(label="Review"):
                ReviewSettingsPanel(app).build()
            with dpg.tab(label="Studio"):
                StudioSettingsPanel(app).build()
            with dpg.tab(label="Editor"):
                EditorSettingsPanel(app).build()


class ReviewSettingsPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        with dpg.group(horizontal=True):
            app._add_button("Load Project", app.load_project_dialog, "load_project")
            app._add_button("Save Project", app.save_project_dialog, "save_project")
        with dpg.group(horizontal=True):
            app._add_combo("##recent_project", app.recent_project, [str(path) for path in app.recent_projects], "recent_projects", tag="recent_project_combo", width=190)
            app._add_button("Open Recent", app.open_recent_project, "recent_projects")
        with dpg.group(horizontal=True):
            app._add_button("Undo", app.undo_project_edit, "undo")
            app._add_button("Redo", app.redo_project_edit, "redo")
        app._add_button("Apply Outputs", app.apply_project_outputs, "apply_outputs", width=-1)
        dpg.add_text("Filter")
        with dpg.group(horizontal=True):
            app._add_combo("##review_filter", app.review_status_filter, ["all", "needs_review", "approved", "rejected"], "review_filter", width=120, callback=lambda *_args: app.refresh_project_rows())
            app._add_input_text("##review_query", app.review_query, "review_query", "review_query", width=145, callback=lambda *_args: app.refresh_project_rows())
        with dpg.child_window(tag="review_list_panel", width=-1, height=130, border=True):
            dpg.add_spacer(height=1)
        attach_tooltip("review_list_panel", "review_list")
        app._review_list = DpgSelectableList("review_list_panel", multi=True, on_select=app.populate_review_editor)
        with dpg.child_window(tag="review_image_panel", width=-1, height=140, border=True):
            dpg.add_text("Load a project to review sprites.", wrap=260)
        with dpg.group(tag="review_source_canvas_frame"):
            dpg.add_drawlist(tag="review_source_canvas", width=REVIEW_CANVAS_SIZE[0], height=REVIEW_CANVAS_SIZE[1])
        attach_tooltip("review_source_canvas_frame", "review_source_canvas")
        with dpg.item_handler_registry(tag="review_canvas_handlers"):
            dpg.add_item_clicked_handler(callback=app._on_review_canvas_press)
        dpg.bind_item_handler_registry("review_source_canvas", "review_canvas_handlers")
        dpg.add_text("Animation Clip")
        app._add_combo("##animation_clip", app.review_animation_clip, [], "animation_clip", tag="review_animation_combo", width=-1)
        with dpg.group(horizontal=True):
            app._add_button("Play", app.play_review_animation, "play_animation")
            app._add_button("Stop", app.stop_review_animation, "stop_animation")
        dpg.add_text("Name")
        app._add_input_text("##review_name", app.review_name, "review_name", "review_name", width=-1)
        dpg.add_text("Category")
        app._add_input_text("##review_category", app.review_category, "review_category", "review_category", width=-1)
        dpg.add_text("BBox x/y/w/h")
        with dpg.group(horizontal=True):
            app._add_input_text("##review_bbox_x", app.review_bbox_x, "review_bbox_x", "review_bbox", width=58)
            app._add_input_text("##review_bbox_y", app.review_bbox_y, "review_bbox_y", "review_bbox", width=58)
            app._add_input_text("##review_bbox_width", app.review_bbox_width, "review_bbox_width", "review_bbox", width=58)
            app._add_input_text("##review_bbox_height", app.review_bbox_height, "review_bbox_height", "review_bbox", width=58)
        dpg.add_text("Pivot x/y")
        with dpg.group(horizontal=True):
            app._add_input_text("##review_pivot_x", app.review_pivot_x, "review_pivot_x", "review_pivot", width=100)
            app._add_input_text("##review_pivot_y", app.review_pivot_y, "review_pivot_y", "review_pivot", width=100)
        dpg.add_text("Status / Flags")
        with dpg.group(horizontal=True):
            app._add_combo("##review_status", app.review_status, ["needs_review", "approved", "rejected"], "review_status", width=120)
            app._add_input_text("##review_flags", app.review_flags, "review_flags", "review_flags", width=130)
        app._add_button("Apply Edit", app.apply_review_edit, "apply_edit", width=-1)
        with dpg.group(horizontal=True):
            app._add_button("Approve", app.approve_review_sprite, "approve")
            app._add_button("Reject", app.reject_review_sprite, "reject")
        dpg.add_text("Split boxes")
        app._add_input_text("##split_boxes", app.review_split_boxes, "split_boxes", "split_boxes", width=-1)
        with dpg.group(horizontal=True):
            app._add_button("Split Selected", app.split_review_sprite, "split_selected")
            app._add_button("Merge Selected", app.merge_review_sprites, "merge_selected")


class StudioSettingsPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        with dpg.group(horizontal=True):
            app._add_button("Refresh", app.refresh_studio_panel, "studio_refresh")
            app._add_button("Review + Apply", app.review_apply_studio_project, "studio_review_apply")
        with dpg.group(horizontal=True):
            app._add_button("Auto Name", app.auto_name_studio_project, "studio_auto_name")
            app._add_button("Profiles", app.generate_studio_profiles, "studio_generate_profiles")
        with dpg.group(horizontal=True):
            app._add_button("Diff Project", app.diff_studio_project, "studio_diff_project")
            app._add_button("Train Preset", app.train_studio_preset, "studio_train_preset")
        dpg.add_text("Taxonomy Pattern")
        app._add_input_text("##studio_taxonomy_pattern", app.studio_taxonomy_pattern, "studio_taxonomy_pattern", "studio_taxonomy_pattern", width=-1)
        dpg.add_text("Dashboard")
        dpg.add_text("Load a project to build a studio dashboard.", tag="studio_dashboard_label", wrap=260)
        attach_tooltip("studio_dashboard_label", "studio_dashboard")
        dpg.add_text("Review Queue")
        with dpg.child_window(tag="studio_queue_panel", width=-1, height=100, border=True):
            dpg.add_spacer(height=1)
        attach_tooltip("studio_queue_panel", "studio_queue")
        app._studio_queue_list = DpgSelectableList("studio_queue_panel")
        dpg.add_text("Asset Browser")
        with dpg.group(horizontal=True):
            app._add_combo("##studio_status_filter", app.studio_status_filter, ["all", "needs_review", "approved", "rejected"], "studio_asset_query", width=120, callback=lambda *_args: app.refresh_studio_panel())
            app._add_input_text("##studio_query", app.studio_query, "studio_query", "studio_asset_query", width=130, callback=lambda *_args: app.refresh_studio_panel())
        with dpg.child_window(tag="studio_asset_panel", width=-1, height=140, border=True):
            dpg.add_spacer(height=1)
        attach_tooltip("studio_asset_panel", "studio_asset_list")
        app._studio_asset_list = DpgSelectableList("studio_asset_panel")


class EditorSettingsPanel(SpriteToolPanel):
    def build(self) -> None:
        app = self.app
        with dpg.group(horizontal=True):
            app._add_button("Fullscreen Editor", lambda *_args: app.set_editor_fullscreen(not bool(app.editor_workspace.fullscreen)), "editor_fullscreen")
            app._add_button("Load Sprite", app.load_editor_sprite_dialog, "editor_load_sprite")
            app._add_button("Save Package", app.save_editor_package, "editor_save_package")
            app._add_button("Save To Project", app.save_editor_to_project, "editor_save_project")
        with dpg.group(horizontal=True):
            with dpg.child_window(tag="editor_tool_rail", width=130, height=520, border=True):
                app._build_editor_tool_rail()
            with dpg.child_window(tag="editor_canvas", width=520, height=520, border=True):
                attach_tooltip("editor_canvas", "editor_canvas")
                app._build_editor_canvas_panel()
            with dpg.child_window(tag="editor_side_panel", width=300, height=520, border=True):
                app._build_editor_side_panel()
        with dpg.child_window(tag="editor_timeline_panel", width=-1, height=130, border=True):
            attach_tooltip("editor_timeline_panel", "editor_timeline_panel")
            app._build_editor_timeline_panel()
        dpg.add_text(str(app.editor_status.get()), tag="editor_status_text", wrap=920)
