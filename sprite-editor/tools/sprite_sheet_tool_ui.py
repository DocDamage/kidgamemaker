from __future__ import annotations

import json
import os
import queue
import re
import subprocess
import sys
import threading
import time
from dataclasses import replace
from pathlib import Path
from typing import Any, Callable
from uuid import uuid4

from PIL import Image, ImageDraw

try:
    import dearpygui.dearpygui as dpg
except ModuleNotFoundError:  # Keep helper tests importable when the GUI dependency is not installed.
    dpg = None  # type: ignore[assignment]

try:
    from tools.autotile_tools import write_autotile_package
    from tools.cut_tileset_sprites import BUILT_IN_PRESETS, DetectionSettings, detect_background, extract_detections, grouped_components, is_inside_spritecut_output
    from tools.golden_sprite_fixtures import create_golden_pack
    from tools.sprite_animation_editor import AnimationEditSession, AnimationFrameRef, playback_next_frame, write_applied_animation
    from tools.sprite_editor import SpriteEditSession, color_wheel_palette, extract_palette, write_edit_package, write_palette_variant_package
    from tools.sprite_editor_workspace import (
        EDITOR_SHORTCUTS,
        EDITOR_TOOLS,
        CanvasView,
        EditorTool,
        EditorWorkspaceState,
        MouseGesture,
        ToolScope,
        apply_mouse_tool,
        apply_shortcut_action,
        canvas_status_text,
        checkerboard_image,
        palette_swatch_rows,
        shortcut_action_for_key,
        state_help_text,
        tool_help_text,
    )
    from tools.sprite_project import approve_sprite, attach_animation_edit_output, attach_sprite_edit_output, load_project, merge_sprites, redo_last_edit, reject_sprite, render_project_outputs, save_project, split_sprite, undo_last_edit, update_sprite
    from tools.sprite_studio import apply_taxonomy_rules, asset_browser_index, batch_health_score, build_engine_import_plans, build_review_dashboard, diff_projects, generate_collision_profiles, review_and_apply_project, search_assets, train_preset_from_project
    from tools.sprite_ui_settings import CutterUiSettings, RunOutputTargets, builtin_preset_names, build_cutter_command, discover_sheet_files, load_preset_file, output_targets_from_cli_line, save_preset_file, settings_from_builtin_preset, settings_from_preset_dict, settings_to_preset_dict, summarize_cli_output_line
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.autotile_tools import write_autotile_package
    from tools.cut_tileset_sprites import BUILT_IN_PRESETS, DetectionSettings, detect_background, extract_detections, grouped_components, is_inside_spritecut_output
    from tools.golden_sprite_fixtures import create_golden_pack
    from tools.sprite_animation_editor import AnimationEditSession, AnimationFrameRef, playback_next_frame, write_applied_animation
    from tools.sprite_editor import SpriteEditSession, color_wheel_palette, extract_palette, write_edit_package, write_palette_variant_package
    from tools.sprite_editor_workspace import (
        EDITOR_SHORTCUTS,
        EDITOR_TOOLS,
        CanvasView,
        EditorTool,
        EditorWorkspaceState,
        MouseGesture,
        ToolScope,
        apply_mouse_tool,
        apply_shortcut_action,
        canvas_status_text,
        checkerboard_image,
        palette_swatch_rows,
        shortcut_action_for_key,
        state_help_text,
        tool_help_text,
    )
    from tools.sprite_project import approve_sprite, attach_animation_edit_output, attach_sprite_edit_output, load_project, merge_sprites, redo_last_edit, reject_sprite, render_project_outputs, save_project, split_sprite, undo_last_edit, update_sprite
    from tools.sprite_studio import apply_taxonomy_rules, asset_browser_index, batch_health_score, build_engine_import_plans, build_review_dashboard, diff_projects, generate_collision_profiles, review_and_apply_project, search_assets, train_preset_from_project
    from tools.sprite_ui_settings import CutterUiSettings, RunOutputTargets, builtin_preset_names, build_cutter_command, discover_sheet_files, load_preset_file, output_targets_from_cli_line, save_preset_file, settings_from_builtin_preset, settings_from_preset_dict, settings_to_preset_dict, summarize_cli_output_line


from tools.sprite_ui_helpers import (
    VIEWPORT_SIZE,
    LEFT_PANEL_WIDTH,
    CENTER_PANEL_WIDTH,
    RIGHT_PANEL_WIDTH,
    PREVIEW_MAX_SIZE,
    REVIEW_CANVAS_SIZE,
    REVIEW_IMAGE_PREVIEW_SIZE,
    UI_ACTION_ERRORS,
    PROCESS_RUN_ERRORS,
    TOOLTIP_TEXT,
    tooltip_text,
    render_detection_preview,
    apply_preview_accessibility_mode,
    detection_settings_from_ui,
    detect_preview_boxes,
    parse_flags_text,
    parse_bbox_fields,
    parse_pivot_fields,
    format_project_sprite_label,
    project_sprite_preview_path_text,
    project_sprite_rows,
    studio_default_taxonomy_rules,
    studio_project_diff_text,
    studio_dashboard_text,
    studio_queue_labels,
    studio_asset_rows,
    studio_asset_label,
    editor_palette_summary,
    editor_color_wheel_preview,
    editor_parse_rect_text,
    editor_parse_size_text,
    editor_variant_package,
    editor_callable_actions,
    default_recent_projects_state_path,
    load_recent_projects,
    remember_recent_project,
    create_ui_sample_pack,
    project_animation_clip_names,
    project_animation_clip_frames,
    scale_bbox_for_canvas,
    translate_bbox_by_canvas_delta,
    cancel_button_state,
    request_process_stop,
)
from tools.sprite_ui_panels import (
    CenterPreviewPanel,
    DetectionSettingsPanel,
    DpgSelectableList,
    DpgValue,
    EditorSettingsPanel,
    LeftInputPanel,
    OutputSettingsPanel,
    ReviewSettingsPanel,
    RunSettingsPanel,
    SettingsTabsPanel,
    SpriteToolPanel,
    StudioSettingsPanel,
    ToolTip,
    _image_texture_data,
    _require_dearpygui,
    attach_tooltip,
)
from tools.sprite_ui_controllers import (
    ProcessingController,
    ReviewProjectController,
    SpriteEditorController,
    StudioController,
    UiController,
)
from tools.sprite_ui_editor import SpriteEditorUiMixin
try:
    from tools.sprite_ui_review_mixin import SpriteReviewUiMixin
    from tools.sprite_ui_settings_mixin import SpriteCutterSettingsMixin
    from tools.sprite_ui_studio_mixin import SpriteStudioUiMixin
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_ui_review_mixin import SpriteReviewUiMixin
    from tools.sprite_ui_settings_mixin import SpriteCutterSettingsMixin
    from tools.sprite_ui_studio_mixin import SpriteStudioUiMixin


class SpriteSheetToolUi(SpriteCutterSettingsMixin, SpriteReviewUiMixin, SpriteStudioUiMixin, SpriteEditorUiMixin):
    def __init__(self, *, build: bool = True) -> None:
        self.input_path = DpgValue("")
        self.auto_detect_all = DpgValue(True)
        self.include_archives = DpgValue(False)
        self.out_name = DpgValue("_organized_sprites")
        self.mode = DpgValue("auto")
        self.animation_names = DpgValue("")
        self.animation_frame_mode = DpgValue("fixed")
        self.animation_anchor = DpgValue("bottom-center")
        self.animation_min_frames = DpgValue(3)
        self.animation_fps = DpgValue(12)
        self.pivot_debug = DpgValue(False)
        self.pack_atlases = DpgValue(True)
        self.atlas_size = DpgValue(2048)
        self.atlas_padding = DpgValue(2)
        self.atlas_allow_rotation = DpgValue(False)
        self.export_unity = DpgValue(True)
        self.export_godot = DpgValue(True)
        self.export_unreal = DpgValue(True)
        self.alpha_threshold = DpgValue(10)
        self.white_threshold = DpgValue(250)
        self.white_tolerance = DpgValue(8)
        self.dark_artifact_threshold = DpgValue(45)
        self.min_sprite_pixels = DpgValue(24)
        self.min_sprite_width = DpgValue(3)
        self.min_sprite_height = DpgValue(3)
        self.crop_padding = DpgValue(1)
        self.on_error = DpgValue("skip")
        preset_names = builtin_preset_names()
        self.builtin_preset = DpgValue(preset_names[0] if preset_names else "")
        self.preview_accessibility_mode = DpgValue("normal")

        self.sheet_files: list[Path] = []
        self.file_list: DpgSelectableList | None = None
        self.log_queue: queue.Queue[str] = queue.Queue()
        self.log_lines: list[str] = []
        self.last_message: tuple[str, str, str] | None = None
        self.worker: threading.Thread | None = None
        self.active_process: subprocess.Popen[str] | None = None
        self.latest_output_dir: Path | None = None
        self.latest_report_path: Path | None = None
        self.latest_project_path: Path | None = None
        self.current_project: dict[str, object] | None = None
        self.current_project_path: Path | None = None
        self.recent_projects_state_path = default_recent_projects_state_path()
        self.recent_projects = load_recent_projects(self.recent_projects_state_path)
        self.recent_project = DpgValue(str(self.recent_projects[0]) if self.recent_projects else "")
        self.project_sprite_rows_cache: list[dict[str, object]] = []
        self.review_canvas_scale: float = 1.0
        self.review_canvas_drag_start: tuple[int, int] | None = None
        self.review_canvas_bbox_start: dict[str, int] | None = None
        self.review_canvas_rect: tuple[int, int, int, int] | None = None
        self.review_canvas_drag_dirty = False

        self.review_status_filter = DpgValue("all")
        self.review_query = DpgValue("")
        self.review_name = DpgValue("")
        self.review_category = DpgValue("")
        self.review_bbox_x = DpgValue("")
        self.review_bbox_y = DpgValue("")
        self.review_bbox_width = DpgValue("")
        self.review_bbox_height = DpgValue("")
        self.review_pivot_x = DpgValue("")
        self.review_pivot_y = DpgValue("")
        self.review_status = DpgValue("needs_review")
        self.review_flags = DpgValue("")
        self.review_split_boxes = DpgValue("")
        self.review_animation_clip = DpgValue("")
        self.review_animation_frame_index = 0
        self.review_animation_active = False
        self.review_animation_next_time: float | None = None
        self.studio_query = DpgValue("")
        self.studio_status_filter = DpgValue("all")
        self.studio_taxonomy_pattern = DpgValue("{category}_{source_sheet}_{index:03d}")
        self.studio_asset_rows_cache: list[dict[str, object]] = []
        self.editor_session: SpriteEditSession | None = None
        self.editor_workspace = EditorWorkspaceState()
        self.editor_fullscreen = DpgValue(False)
        self.editor_active_tool = DpgValue(self.editor_workspace.active_tool.value)
        self.editor_tool_scope = DpgValue(self.editor_workspace.tool_scope.value)
        self.editor_canvas_view = CanvasView(sprite_size=(1, 1), panel_size=(640, 420))
        self.editor_cursor = DpgValue("")
        self.editor_status = DpgValue("x=- y=- color=#-------- zoom=8.0x layer=1 frame=1")
        self.editor_show_grid = DpgValue(True)
        self.editor_layer_name = DpgValue("")
        self.editor_layer_opacity = DpgValue(1.0)
        self.editor_animation_session: AnimationEditSession | None = None
        self.editor_animation_clip = DpgValue("")
        self.editor_animation_fps = DpgValue(12)
        self.editor_animation_playing = False
        self.editor_animation_last_tick: float | None = None
        self.editor_source_sprite_id = ""
        self.editor_crop_rect = DpgValue("0,0,16,16")
        self.editor_resize_size = DpgValue("16x16")
        self.editor_flip_axis = DpgValue("horizontal")
        self.editor_source_color = DpgValue("#ff0000")
        self.editor_target_color = DpgValue("#00ffff")
        self.editor_hue_degrees = DpgValue("0")
        self.editor_harmony = DpgValue("complementary")
        self.editor_autotile_name = DpgValue("autotile")
        self.editor_engine = DpgValue("godot")

        self._built = False
        self._texture_tags: dict[str, str] = {}
        self._dialog_actions: dict[str, Callable[[Path], None]] = {}
        self._main_window = "spritecut_main_window"
        self._texture_registry = "spritecut_texture_registry"
        self._review_list: DpgSelectableList | None = None
        self._studio_queue_list: DpgSelectableList | None = None
        self._studio_asset_list: DpgSelectableList | None = None
        self.processing_controller = ProcessingController(self)
        self.review_controller = ReviewProjectController(self)
        self.studio_controller = StudioController(self)
        self.editor_controller = SpriteEditorController(self)

        if build and dpg is not None:
            self._build()

    def _build(self) -> None:
        _require_dearpygui()
        if self._built:
            return
        dpg.create_context()
        self._build_theme()
        with dpg.texture_registry(tag=self._texture_registry):
            ...  # Textures are registered lazily by _make_texture().
        self._build_file_dialogs()
        self._build_layout()
        self._built = True

    def _build_theme(self) -> None:
        if dpg is None:
            return
        with dpg.theme(tag="spritecut_dark_theme"):
            with dpg.theme_component(dpg.mvAll):
                dpg.add_theme_color(dpg.mvThemeCol_WindowBg, (23, 25, 29, 255))
                dpg.add_theme_color(dpg.mvThemeCol_ChildBg, (32, 36, 43, 255))
                dpg.add_theme_color(dpg.mvThemeCol_FrameBg, (17, 19, 24, 255))
                dpg.add_theme_color(dpg.mvThemeCol_Button, (47, 111, 235, 255))
                dpg.add_theme_color(dpg.mvThemeCol_ButtonHovered, (59, 130, 246, 255))
                dpg.add_theme_color(dpg.mvThemeCol_Header, (47, 111, 235, 180))
                dpg.add_theme_color(dpg.mvThemeCol_HeaderHovered, (59, 130, 246, 210))
                dpg.add_theme_color(dpg.mvThemeCol_Text, (230, 232, 239, 255))
                dpg.add_theme_style(dpg.mvStyleVar_FrameRounding, 4)
                dpg.add_theme_style(dpg.mvStyleVar_WindowPadding, 10, 10)
                dpg.add_theme_style(dpg.mvStyleVar_ItemSpacing, 6, 6)
        dpg.bind_theme("spritecut_dark_theme")

    def _build_file_dialogs(self) -> None:
        if dpg is None:
            return
        with dpg.file_dialog(directory_selector=True, show=False, callback=self._choose_folder_callback, tag="folder_dialog", width=720, height=440):
            dpg.add_file_extension("", color=(150, 255, 150, 255))
        with dpg.file_dialog(directory_selector=False, show=False, callback=self._choose_file_callback, tag="image_file_dialog", width=720, height=440):
            dpg.add_file_extension("Images (*.png *.jpg *.jpeg *.tif *.tiff *.bmp *.webp){.png,.jpg,.jpeg,.tif,.tiff,.bmp,.webp}")
            dpg.add_file_extension(".*")
        with dpg.file_dialog(directory_selector=False, show=False, callback=self._load_preset_callback, tag="load_preset_dialog", width=720, height=440):
            dpg.add_file_extension("JSON preset (*.json){.json}")
            dpg.add_file_extension(".*")
        with dpg.file_dialog(directory_selector=False, show=False, callback=self._save_preset_callback, tag="save_preset_dialog", width=720, height=440):
            dpg.add_file_extension("JSON preset (*.json){.json}")
            dpg.add_file_extension(".*")
        with dpg.file_dialog(directory_selector=False, show=False, callback=self._load_project_callback, tag="load_project_dialog", width=720, height=440):
            dpg.add_file_extension("SpriteCut project (*.spritecut.json){.json}")
            dpg.add_file_extension(".*")
        with dpg.file_dialog(directory_selector=False, show=False, callback=self._save_project_callback, tag="save_project_dialog", width=720, height=440):
            dpg.add_file_extension("SpriteCut project (*.spritecut.json){.json}")
            dpg.add_file_extension(".*")
        with dpg.file_dialog(directory_selector=False, show=False, callback=self._load_editor_sprite_callback, tag="editor_sprite_dialog", width=720, height=440):
            dpg.add_file_extension("Images (*.png *.jpg *.jpeg *.bmp *.webp){.png,.jpg,.jpeg,.bmp,.webp}")
            dpg.add_file_extension(".*")
        with dpg.file_dialog(directory_selector=True, show=False, callback=self._directory_action_callback, tag="directory_action_dialog", width=720, height=440):
            dpg.add_file_extension("", color=(150, 255, 150, 255))
        with dpg.file_dialog(directory_selector=False, show=False, callback=self._diff_project_callback, tag="diff_project_dialog", width=720, height=440):
            dpg.add_file_extension("SpriteCut project (*.spritecut.json){.json}")
            dpg.add_file_extension(".*")

    def _build_layout(self) -> None:
        if dpg is None:
            return
        left_panel, center_panel, settings_panel = self._panel_builders()
        with dpg.window(tag=self._main_window, label="Sprite Sheet Processor", no_title_bar=True):
            with dpg.group(horizontal=True):
                with dpg.child_window(width=LEFT_PANEL_WIDTH, height=-1, border=True):
                    left_panel.build()
                with dpg.child_window(width=CENTER_PANEL_WIDTH, height=-1, border=True):
                    center_panel.build()
                with dpg.child_window(width=RIGHT_PANEL_WIDTH, height=-1, border=True):
                    settings_panel.build()
        dpg.create_viewport(title="Sprite Sheet Processor", width=VIEWPORT_SIZE[0], height=VIEWPORT_SIZE[1])
        dpg.set_primary_window(self._main_window, True)
        with dpg.handler_registry(tag="spritecut_global_handlers"):
            dpg.add_mouse_drag_handler(button=dpg.mvMouseButton_Left, callback=self._on_review_canvas_drag)
            dpg.add_mouse_release_handler(button=dpg.mvMouseButton_Left, callback=self._on_review_canvas_release)

    def _panel_builders(self) -> list[SpriteToolPanel]:
        return [LeftInputPanel(self), CenterPreviewPanel(self), SettingsTabsPanel(self)]

    def _controllers(self) -> list[UiController]:
        return [self.processing_controller, self.review_controller, self.studio_controller, self.editor_controller]

    def process(self, *_args: object) -> None:
        self.processing_controller.process(*_args)

    def refresh_project_rows(self, *_args: object) -> None:
        self.review_controller.refresh_project_rows(*_args)

    def refresh_studio_panel(self, *_args: object) -> None:
        self.studio_controller.refresh_studio_panel(*_args)

    def load_editor_sprite(self, path: Path) -> None:
        self.editor_controller.load_editor_sprite(path)

    def apply_editor_palette_swap(self, *_args: object) -> None:
        self.editor_controller.apply_palette_swap(*_args)

    def apply_editor_hue_shift(self, *_args: object) -> None:
        self.editor_controller.apply_hue_shift(*_args)

    def apply_editor_crop(self, *_args: object) -> None:
        self.editor_controller.apply_crop(*_args)

    def apply_editor_resize(self, *_args: object) -> None:
        self.editor_controller.apply_resize(*_args)

    def apply_editor_flip(self, *_args: object) -> None:
        self.editor_controller.apply_flip(*_args)

    def apply_editor_rotate(self, *, clockwise: bool = True) -> None:
        self.editor_controller.apply_rotate(clockwise=clockwise)

    def _build_left_panel(self) -> None:
        LeftInputPanel(self).build()

    def _build_center_panel(self) -> None:
        CenterPreviewPanel(self).build()

    def _build_right_panel(self) -> None:
        SettingsTabsPanel(self).build()

    def _build_core_settings(self) -> None:
        RunSettingsPanel(self).build()

    def _build_detection_settings(self) -> None:
        DetectionSettingsPanel(self).build()

    def _build_output_settings(self) -> None:
        OutputSettingsPanel(self).build()

    def _build_review_settings(self) -> None:
        ReviewSettingsPanel(self).build()

    def _build_studio_settings(self) -> None:
        StudioSettingsPanel(self).build()

    def _build_editor_settings(self) -> None:
        EditorSettingsPanel(self).build()

    def _value_callback(self, _sender: object, app_data: object, user_data: object) -> None:
        if isinstance(user_data, DpgValue):
            user_data.set(app_data)

    def _add_button(self, label: str, callback: Callable[..., object], tooltip_key: str, *, tag: str | None = None, width: int = 0, enabled: bool = True) -> str:
        item = tag or f"button_{tooltip_key}_{uuid4().hex}"
        dpg.add_button(label=label, tag=item, callback=callback, width=width, enabled=enabled)
        attach_tooltip(item, tooltip_key)
        return item

    def _add_input_text(self, label: str, variable: DpgValue, tag: str, tooltip_key: str, *, width: int = 0, callback: Callable[..., object] | None = None) -> str:
        variable.bind(tag)
        def _callback(sender: object, app_data: object, user_data: object) -> None:
            self._value_callback(sender, app_data, user_data)
            if callback is not None:
                callback(sender, app_data, user_data)
        dpg.add_input_text(label=label, tag=tag, default_value=str(variable.get()), callback=_callback, user_data=variable, width=width)
        variable.bind(tag)
        attach_tooltip(tag, tooltip_key)
        return tag

    def _add_input_int(self, label: str, variable: DpgValue, tag: str, tooltip_key: str, *, min_value: int, max_value: int) -> str:
        variable.bind(tag)
        dpg.add_input_int(label=label, tag=tag, default_value=int(variable.get()), callback=self._value_callback, user_data=variable, width=110, min_value=min_value, max_value=max_value, min_clamped=True, max_clamped=True)
        variable.bind(tag)
        attach_tooltip(tag, tooltip_key)
        return tag

    def _add_checkbox(self, label: str, variable: DpgValue, tooltip_key: str, *, tag: str | None = None) -> str:
        item = tag or tooltip_key
        variable.bind(item)
        dpg.add_checkbox(label=label, tag=item, default_value=bool(variable.get()), callback=self._value_callback, user_data=variable)
        variable.bind(item)
        attach_tooltip(item, tooltip_key)
        return item

    def _add_combo(self, label: str, variable: DpgValue, values: list[str], tooltip_key: str, *, tag: str | None = None, width: int = 0, callback: Callable[..., object] | None = None) -> str:
        item = tag or tooltip_key
        variable.bind(item)
        def _callback(sender: object, app_data: object, user_data: object) -> None:
            self._value_callback(sender, app_data, user_data)
            if callback is not None:
                callback(sender, app_data, user_data)
        dpg.add_combo(values, label=label, tag=item, default_value=str(variable.get()), callback=_callback, user_data=variable, width=width)
        variable.bind(item)
        attach_tooltip(item, tooltip_key)
        return item

    def run(self) -> None:
        _require_dearpygui()
        if not self._built:
            self._build()
        dpg.setup_dearpygui()
        dpg.show_viewport()
        try:
            while dpg.is_dearpygui_running():
                self._drain_log_queue()
                self._tick_review_animation()
                dpg.render_dearpygui_frame()
        finally:
            self._shutdown_active_process()
            dpg.destroy_context()
            self._built = False

    def mainloop(self) -> None:
        self.run()

    def _show_message(self, title: str, text: str, *, level: str = "info") -> None:
        self.last_message = (title, text, level)
        prefix = "Error" if level == "error" else "Info"
        self.append_log(f"{prefix} - {title}: {text}")
        if dpg is None or not self._built:
            print(f"{title}: {text}", file=sys.stderr)
            return
        tag = f"message_{uuid4().hex}"
        with dpg.window(label=title, tag=tag, modal=True, no_resize=True, width=520, height=190):
            dpg.add_text(text, wrap=480)
            dpg.add_spacer(height=8)
            dpg.add_button(label="OK", callback=lambda: dpg.delete_item(tag), width=90)

    def _show_info(self, title: str, text: str) -> None:
        self._show_message(title, text)

    def _show_error(self, title: str, text: str) -> None:
        self._show_message(title, text, level="error")

    def _dialog_path(self, app_data: object) -> Path | None:
        if not isinstance(app_data, dict):
            return None
        for key in ("file_path_name", "current_path"):
            value = app_data.get(key)
            if value:
                return Path(str(value))
        selections = app_data.get("selections")
        if isinstance(selections, dict) and selections:
            return Path(str(next(iter(selections.values()))))
        return None

    def _set_processing(self, active: bool) -> None:
        self._set_text("progress_text", "Processing..." if active else "Idle")
        self._set_button_enabled("process_button", not active)
        self._set_button_enabled("cancel_button", active)

    def _set_latest_run_targets(self, targets: RunOutputTargets | None) -> None:
        self.latest_output_dir = targets.output_dir if targets is not None else None
        self.latest_report_path = targets.report_path if targets is not None else None
        self.latest_project_path = targets.project_path if targets is not None else None
        enabled = targets is not None
        self._set_button_enabled("open_output_button", enabled)
        self._set_button_enabled("open_report_button", enabled)
        self._set_button_enabled("open_project_button", enabled)

    def _process_impl(self, *_args: object) -> None:
        from tools.sprite_ui_process import process_impl
        process_impl(self, *_args)

    def _run_process(self, command: list[str]) -> None:
        from tools.sprite_ui_process import run_process
        run_process(self, command)

    def cancel_process(self, *_args: object) -> None:
        from tools.sprite_ui_process import cancel_process
        cancel_process(self, *_args)

    def _shutdown_active_process(self) -> None:
        from tools.sprite_ui_process import shutdown_active_process
        shutdown_active_process(self)

    def _drain_log_queue(self) -> None:
        from tools.sprite_ui_process import drain_log_queue
        drain_log_queue(self)

    def open_latest_output(self, *_args: object) -> None:
        from tools.sprite_ui_process import open_latest_output
        open_latest_output(self, *_args)

    def open_latest_report(self, *_args: object) -> None:
        from tools.sprite_ui_process import open_latest_report
        open_latest_report(self, *_args)

    def open_latest_project(self, *_args: object) -> None:
        from tools.sprite_ui_process import open_latest_project
        open_latest_project(self, *_args)

    def append_log(self, text: str) -> None:
        self.log_lines.append(text)
        if len(self.log_lines) > 1000:
            self.log_lines = self.log_lines[-1000:]
        self._set_text("log_text", "\n".join(self.log_lines))

    def clear_log(self, *_args: object) -> None:
        self.log_lines = []
        self._set_text("log_text", "")

    def _set_button_enabled(self, tag: str, enabled: bool) -> None:
        if dpg is not None and self._built and dpg.does_item_exist(tag):
            dpg.configure_item(tag, enabled=enabled)

    def _set_text(self, tag: str, text: str) -> None:
        if dpg is not None and self._built and dpg.does_item_exist(tag):
            dpg.set_value(tag, text)

    def _delete_dpg_item(self, tag: str, *, children_only: bool = False, context: str = "item cleanup") -> bool:
        if dpg is None or not self._built or not dpg.does_item_exist(tag):
            return False
        try:
            dpg.delete_item(tag, children_only=children_only)
            return True
        except UI_ACTION_ERRORS as exc:
            self.append_log(f"{context} failed for {tag}: {exc}")
            return False

    def _clear_item_children(self, tag: str) -> None:
        self._delete_dpg_item(tag, children_only=True, context="Panel cleanup")

    def _show_text_panel(self, panel_tag: str, text: str) -> None:
        if dpg is None or not self._built or not dpg.does_item_exist(panel_tag):
            return
        self._delete_dpg_item(panel_tag, children_only=True, context="Text panel cleanup")
        dpg.add_text(text, parent=panel_tag, wrap=520)

    def _make_texture(self, key: str, image: Image.Image) -> str:
        if dpg is None:
            raise RuntimeError("Dear PyGUI is not available.")
        existing = self._texture_tags.get(key)
        if existing and dpg.does_item_exist(existing):
            self._delete_dpg_item(existing, context="Texture cleanup")
        width, height, data = _image_texture_data(image)
        tag = f"texture_{key}_{uuid4().hex}"
        dpg.add_static_texture(width=width, height=height, default_value=data, tag=tag, parent=self._texture_registry)
        self._texture_tags[key] = tag
        return tag

    def _show_image_in_panel(self, panel_tag: str, key: str, image: Image.Image, *, fallback_text: str = "") -> None:
        if dpg is None or not self._built or not dpg.does_item_exist(panel_tag):
            return
        self._delete_dpg_item(panel_tag, children_only=True, context="Image panel cleanup")
        texture = self._make_texture(key, image)
        dpg.add_image(texture, parent=panel_tag)
        if fallback_text:
            dpg.add_text(fallback_text, parent=panel_tag, wrap=520)


def main() -> None:
    if any(arg in {"-h", "--help"} for arg in sys.argv[1:]):
        print("Sprite Sheet Processor UI")
        print("")
        print("Launches a Dear PyGUI desktop wrapper for tools/cut_tileset_sprites.py.")
        print("Run without arguments:")
        print("  python tools\\sprite_sheet_tool_ui.py")
        print("")
        print("The UI supports preview, cutter settings, review editing, Studio health/diff/search, sprite editing, auto-tiles, import plans, and live logs.")
        return

    try:
        app = SpriteSheetToolUi()
        app.run()
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1) from exc


if __name__ == "__main__":
    main()
