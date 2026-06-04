from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Callable

try:
    import dearpygui.dearpygui as dpg
except ModuleNotFoundError:
    dpg = None  # type: ignore[assignment]

try:
    from tools.sprite_ui_settings import CutterUiSettings, RunOutputTargets, builtin_preset_names, load_preset_file, save_preset_file, settings_from_builtin_preset, discover_sheet_files
    from tools.sprite_ui_helpers import (
        detect_preview_boxes,
        render_detection_preview,
        apply_preview_accessibility_mode,
        PREVIEW_MAX_SIZE,
        UI_ACTION_ERRORS,
        load_recent_projects,
        remember_recent_project,
        create_ui_sample_pack,
        default_recent_projects_state_path,
    )
    from tools.sprite_project import load_project, save_project, render_project_outputs
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_ui_settings import CutterUiSettings, RunOutputTargets, builtin_preset_names, load_preset_file, save_preset_file, settings_from_builtin_preset, discover_sheet_files
    from tools.sprite_ui_helpers import (
        detect_preview_boxes,
        render_detection_preview,
        apply_preview_accessibility_mode,
        PREVIEW_MAX_SIZE,
        UI_ACTION_ERRORS,
        load_recent_projects,
        remember_recent_project,
        create_ui_sample_pack,
        default_recent_projects_state_path,
    )
    from tools.sprite_project import load_project, save_project, render_project_outputs


class SpriteCutterSettingsMixin:
    def _resolve(self, name: str, fallback: object) -> object:
        module = sys.modules.get(self.__class__.__module__)
        return getattr(module, name, fallback) if module is not None else fallback

    def choose_folder(self, *_args: object) -> None:
        if dpg is not None:
            dpg.show_item("folder_dialog")

    def _choose_folder_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        path = self._dialog_path(app_data)
        if path is not None:
            self.input_path.set(str(path))
            self.refresh_files()

    def choose_file(self, *_args: object) -> None:
        if dpg is not None:
            dpg.show_item("image_file_dialog")

    def _choose_file_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        path = self._dialog_path(app_data)
        if path is not None:
            self.input_path.set(str(path))
            self.refresh_files()

    def create_sample_pack_dialog(self, *_args: object) -> None:
        self._dialog_actions["directory_action_dialog"] = self._create_sample_pack_to
        if dpg is not None:
            dpg.show_item("directory_action_dialog")

    def _create_sample_pack_to(self, path: Path) -> None:
        try:
            output = create_ui_sample_pack(path / "spritecut_sample_pack")
            self.input_path.set(str(output))
            self.refresh_files()
            self.append_log(f"Created sample pack: {output}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Sample Pack", str(exc))

    def refresh_files(self, *_args: object) -> None:
        path_text = str(self.input_path.get()).strip()
        self.sheet_files = []
        if self.file_list is not None:
            self.file_list.clear()
        if not path_text:
            self._show_text_panel("preview_panel", "Choose a folder or file to preview sheets.")
            return

        root = Path(path_text)
        if not root.exists():
            self._show_text_panel("preview_panel", f"Missing input: {root}")
            self.append_log(f"Missing input: {root}")
            return

        self.sheet_files = discover_sheet_files(root)
        if self.file_list is not None:
            self.file_list.set_items([path.name for path in self.sheet_files], select_first=bool(self.sheet_files))
        if self.sheet_files:
            self.update_preview()
        else:
            self._show_text_panel("preview_panel", "No supported sheet images found.")
        self.append_log(f"Loaded {len(self.sheet_files)} sheet(s).")

    def update_preview(self, *_args: object) -> None:
        if self.file_list is None:
            return
        selection = self.file_list.selected_indices()
        if not selection:
            return
        path = self.sheet_files[selection[0]]
        try:
            boxes = detect_preview_boxes(path, self.current_settings(show_error=False))
            preview = render_detection_preview(path, boxes, max_size=PREVIEW_MAX_SIZE)
            preview = apply_preview_accessibility_mode(preview, str(self.preview_accessibility_mode.get()))
            self._show_image_in_panel("preview_panel", "preview", preview, fallback_text="")
            self.append_log(f"Preview detected {len(boxes)} region(s) in {path.name}.")
        except UI_ACTION_ERRORS as exc:
            self._show_text_panel("preview_panel", f"Preview failed: {exc}")
            self.append_log(f"Preview failed for {path.name}: {exc}")

    def current_settings(self, *, show_error: bool = True) -> CutterUiSettings | None:
        path_text = str(self.input_path.get()).strip()
        if not path_text:
            if show_error:
                self._show_error("Missing Input", "Choose a sprite sheet file or folder first.")
            return None

        exports = []
        if bool(self.export_unity.get()):
            exports.append("unity")
        if bool(self.export_godot.get()):
            exports.append("godot")
        if bool(self.export_unreal.get()):
            exports.append("unreal")

        return CutterUiSettings(
            input_path=Path(path_text),
            auto_detect_all=bool(self.auto_detect_all.get()),
            include_archives=bool(self.include_archives.get()),
            out_name=str(self.out_name.get()).strip() or "_organized_sprites",
            mode=str(self.mode.get()),
            animation_names=str(self.animation_names.get()),
            animation_frame_mode=str(self.animation_frame_mode.get()),
            animation_anchor=str(self.animation_anchor.get()),
            animation_min_frames=int(self.animation_min_frames.get()),
            animation_fps=int(self.animation_fps.get()),
            pivot_debug=bool(self.pivot_debug.get()),
            pack_atlases=bool(self.pack_atlases.get()),
            atlas_size=int(self.atlas_size.get()),
            atlas_padding=int(self.atlas_padding.get()),
            atlas_allow_rotation=bool(self.atlas_allow_rotation.get()),
            engine_exports=exports,
            alpha_threshold=int(self.alpha_threshold.get()),
            white_threshold=int(self.white_threshold.get()),
            white_tolerance=int(self.white_tolerance.get()),
            dark_artifact_threshold=int(self.dark_artifact_threshold.get()),
            min_sprite_pixels=int(self.min_sprite_pixels.get()),
            min_sprite_width=int(self.min_sprite_width.get()),
            min_sprite_height=int(self.min_sprite_height.get()),
            crop_padding=int(self.crop_padding.get()),
            on_error=str(self.on_error.get()),
        )

    def apply_settings(self, settings: CutterUiSettings) -> None:
        self.auto_detect_all.set(settings.auto_detect_all)
        self.include_archives.set(settings.include_archives)
        self.out_name.set(settings.out_name)
        self.mode.set(settings.mode)
        self.animation_names.set(settings.animation_names)
        self.animation_frame_mode.set(settings.animation_frame_mode)
        self.animation_anchor.set(settings.animation_anchor)
        self.animation_min_frames.set(settings.animation_min_frames)
        self.animation_fps.set(settings.animation_fps)
        self.pivot_debug.set(settings.pivot_debug)
        self.pack_atlases.set(settings.pack_atlases)
        self.atlas_size.set(settings.atlas_size)
        self.atlas_padding.set(settings.atlas_padding)
        self.atlas_allow_rotation.set(settings.atlas_allow_rotation)
        self.export_unity.set("unity" in settings.engine_exports)
        self.export_godot.set("godot" in settings.engine_exports)
        self.export_unreal.set("unreal" in settings.engine_exports)
        self.alpha_threshold.set(settings.alpha_threshold)
        self.white_threshold.set(settings.white_threshold)
        self.white_tolerance.set(settings.white_tolerance)
        self.dark_artifact_threshold.set(settings.dark_artifact_threshold)
        self.min_sprite_pixels.set(settings.min_sprite_pixels)
        self.min_sprite_width.set(settings.min_sprite_width)
        self.min_sprite_height.set(settings.min_sprite_height)
        self.crop_padding.set(settings.crop_padding)
        self.on_error.set(settings.on_error)

    def apply_builtin_preset(self, *_args: object) -> None:
        input_path = Path(str(self.input_path.get()).strip()) if str(self.input_path.get()).strip() else Path(".")
        try:
            fn = self._resolve("settings_from_builtin_preset", settings_from_builtin_preset)
            settings = fn(str(self.builtin_preset.get()), input_path=input_path)  # type: ignore[operator]
            self.apply_settings(settings)
            self.append_log(f"Applied built-in preset: {self.builtin_preset.get()}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Built-In Preset", str(exc))

    def save_preset(self, *_args: object) -> None:
        if self.current_settings() is not None and dpg is not None:
            dpg.show_item("save_preset_dialog")

    def _save_preset_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        settings = self.current_settings()
        path = self._dialog_path(app_data)
        if settings is None or path is None:
            return
        if path.suffix.lower() != ".json":
            path = path.with_suffix(".json")
        try:
            save_preset_file(settings, path)
            self.append_log(f"Saved preset: {path}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Save Preset", str(exc))

    def load_preset(self, *_args: object) -> None:
        if dpg is not None:
            dpg.show_item("load_preset_dialog")

    def _load_preset_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        path = self._dialog_path(app_data)
        if path is None:
            return
        input_path = Path(str(self.input_path.get()).strip()) if str(self.input_path.get()).strip() else Path(".")
        try:
            settings = load_preset_file(path, input_path=input_path)
            self.apply_settings(settings)
            self.append_log(f"Loaded preset: {path}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Load Preset", str(exc))

    def load_project_dialog(self, *_args: object) -> None:
        if dpg is not None:
            dpg.show_item("load_project_dialog")

    def _load_project_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        path = self._dialog_path(app_data)
        if path is not None:
            self.load_project_file(path)

    def load_project_file(self, path: Path) -> None:
        try:
            self.current_project = load_project(path)
            self.current_project_path = path
            self._remember_recent_project(path)
            self.append_log(f"Loaded project: {path}")
            self.refresh_project_rows()
            self.refresh_project_animation_clips()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Load Project", str(exc))

    def _remember_recent_project(self, path: Path) -> None:
        self.recent_projects = remember_recent_project(self.recent_projects_state_path, path)
        self.recent_project.set(str(self.recent_projects[0]) if self.recent_projects else "")
        if dpg is not None and self._built and dpg.does_item_exist("recent_project_combo"):
            dpg.configure_item("recent_project_combo", items=[str(project) for project in self.recent_projects])

    def open_recent_project(self, *_args: object) -> None:
        selected = str(self.recent_project.get()).strip()
        if not selected:
            self._show_info("Open Recent", "No recent project is selected.")
            return
        path = Path(selected)
        if not path.exists():
            self.recent_projects = load_recent_projects(self.recent_projects_state_path)
            self._show_error("Open Recent", f"Recent project no longer exists:\n{path}")
            return
        self.load_project_file(path)

    def save_project_dialog(self, *_args: object) -> None:
        if self.current_project is None:
            self._show_info("Save Project", "Load a project before saving.")
            return
        if self.current_project_path is not None:
            self._save_project_to_path(self.current_project_path)
        elif dpg is not None:
            dpg.show_item("save_project_dialog")

    def _save_project_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        path = self._dialog_path(app_data)
        if path is None:
            return
        if path.suffix.lower() != ".json":
            path = path.with_suffix(".spritecut.json")
        self._save_project_to_path(path)

    def _save_project_to_path(self, path: Path) -> None:
        if self.current_project is None:
            return
        try:
            save_project(self.current_project, path)
            self.current_project_path = path
            self.append_log(f"Saved project: {path}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Save Project", str(exc))

    def apply_project_outputs(self, *_args: object) -> None:
        if self.current_project is None or self.current_project_path is None:
            self._show_info("Apply Outputs", "Load a project before applying outputs.")
            return
        try:
            result = render_project_outputs(self.current_project, self.current_project_path)
            self.append_log(
                "Applied project outputs: "
                f"rendered={result['rendered']} "
                f"skipped_rejected={result['skipped_rejected']} "
                f"errors={len(result['errors'])} "
                f"output={result['output_dir']}"
            )
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Apply Outputs", str(exc))

    def _directory_action_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        path = self._dialog_path(app_data)
        action = self._dialog_actions.pop("directory_action_dialog", None)
        if path is not None and action is not None:
            action(path)
