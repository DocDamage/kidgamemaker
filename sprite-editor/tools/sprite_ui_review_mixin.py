from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path
from typing import Callable
from uuid import uuid4

from PIL import Image

try:
    import dearpygui.dearpygui as dpg
except ModuleNotFoundError:
    dpg = None  # type: ignore[assignment]

try:
    from tools.autotile_tools import write_autotile_package
    from tools.cut_tileset_sprites import BUILT_IN_PRESETS, DetectionSettings, detect_background, extract_detections, grouped_components, is_inside_spritecut_output
    from tools.golden_sprite_fixtures import create_golden_pack
    from tools.sprite_animation_editor import AnimationEditSession, AnimationFrameRef, playback_next_frame, write_applied_animation
    from tools.sprite_editor import SpriteEditSession, color_wheel_palette, extract_palette, write_edit_package, write_palette_variant_package
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
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.autotile_tools import write_autotile_package
    from tools.cut_tileset_sprites import BUILT_IN_PRESETS, DetectionSettings, detect_background, extract_detections, grouped_components, is_inside_spritecut_output
    from tools.golden_sprite_fixtures import create_golden_pack
    from tools.sprite_animation_editor import AnimationEditSession, AnimationFrameRef, playback_next_frame, write_applied_animation
    from tools.sprite_editor import SpriteEditSession, color_wheel_palette, extract_palette, write_edit_package, write_palette_variant_package
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


class SpriteReviewUiMixin:
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

    def _refresh_studio_panel_impl(self, *_args: object) -> None:
        if self._studio_queue_list is not None:
            self._studio_queue_list.clear()
        if self._studio_asset_list is not None:
            self._studio_asset_list.clear()
        self.studio_asset_rows_cache = []
        if self.current_project is None:
            self._set_text("studio_dashboard_label", "Load a project to build a studio dashboard.")
            return

        self._set_text("studio_dashboard_label", studio_dashboard_text(self.current_project))
        if self._studio_queue_list is not None:
            self._studio_queue_list.set_items(studio_queue_labels(self.current_project))
        rows = studio_asset_rows(self.current_project, str(self.studio_query.get()), str(self.studio_status_filter.get()))
        self.studio_asset_rows_cache = rows
        if self._studio_asset_list is not None:
            self._studio_asset_list.set_items([studio_asset_label(item) for item in rows])

    def auto_name_studio_project(self, *_args: object) -> None:
        if self.current_project is None:
            self._show_info("Auto Name", "Load a project before applying taxonomy rules.")
            return
        try:
            fn_rules = self._resolve("apply_taxonomy_rules", apply_taxonomy_rules)
            fn_default_rules = self._resolve("studio_default_taxonomy_rules", studio_default_taxonomy_rules)
            result = fn_rules(self.current_project, fn_default_rules(str(self.studio_taxonomy_pattern.get())))  # type: ignore[arg-type,operator]
            self.append_log(f"Auto-named project sprites: renamed={result['renamed']} pattern={result['pattern']}")
            self.refresh_project_rows()
            if self.current_project_path is not None:
                save_project(self.current_project, self.current_project_path)
        except UI_ACTION_ERRORS as exc:
            self._show_error("Auto Name", str(exc))

    def generate_studio_profiles(self, *_args: object) -> None:
        if self.current_project is None:
            self._show_info("Profiles", "Load a project before generating profiles.")
            return
        try:
            profiles = generate_collision_profiles(self.current_project)  # type: ignore[arg-type]
            plans = build_engine_import_plans(self.current_project)  # type: ignore[arg-type]
            if self.current_project_path is not None:
                save_project(self.current_project, self.current_project_path)
            self.append_log(f"Generated studio profiles: sprites={len(profiles)} engines={','.join(plans) or 'none'}")
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Profiles", str(exc))

    def train_studio_preset(self, *_args: object) -> None:
        if self.current_project is None or self.current_project_path is None:
            self._show_info("Train Preset", "Load a saved project before training a preset.")
            return
        try:
            preset = train_preset_from_project(self.current_project)  # type: ignore[arg-type]
            output_path = self.current_project_path.parent / "trained_spritecut_preset.json"
            output_path.write_text(json.dumps(preset, indent=2), encoding="utf-8")
            self.append_log(f"Trained preset: {output_path}")
            self.refresh_studio_panel()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Train Preset", str(exc))

    def diff_studio_project(self, *_args: object) -> None:
        if self.current_project is None or self.current_project_path is None:
            self._show_info("Diff Project", "Load a project before comparing reruns.")
            return
        if dpg is not None:
            dpg.show_item("diff_project_dialog")

    def _diff_project_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        selected = self._dialog_path(app_data)
        if selected is None or self.current_project is None or self.current_project_path is None:
            return
        try:
            baseline_project = load_project(selected)
            diff = diff_projects(baseline_project, self.current_project)  # type: ignore[arg-type]
            output_path = self.current_project_path.parent / "studio_diff.json"
            output_path.write_text(json.dumps(diff, indent=2), encoding="utf-8")
            self.append_log(f"{studio_project_diff_text(baseline_project, self.current_project)} -> {output_path}")
            self.refresh_studio_panel()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Diff Project", str(exc))

    def review_apply_studio_project(self, *_args: object) -> None:
        if self.current_project is None or self.current_project_path is None:
            self._show_info("Review + Apply", "Load a project before running the studio pass.")
            return
        try:
            result = review_and_apply_project(
                self.current_project,  # type: ignore[arg-type]
                self.current_project_path,
                naming_rules=studio_default_taxonomy_rules(str(self.studio_taxonomy_pattern.get())),
            )
            output_dir = Path(str(result["output_dir"]))
            self._set_latest_run_targets(
                RunOutputTargets(
                    output_dir=output_dir,
                    report_path=output_dir / "manifest" / "report.html",
                    project_path=self.current_project_path,
                )
            )
            self.append_log(
                "Review + Apply complete: "
                f"rendered={result['apply']['rendered']} "
                f"health={result['health']['grade']}:{result['health']['score']} "
                f"imports={','.join(result['import_plans']) or 'none'} "
                f"output={output_dir}"
            )
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Review + Apply", str(exc))

    def _refresh_project_rows_impl(self, *_args: object) -> None:
        if self._review_list is not None:
            self._review_list.clear()
        self.project_sprite_rows_cache = []
        if self.current_project is None:
            self._clear_review_editor("Load a project to review sprites.")
            self.refresh_studio_panel()
            return
        rows = project_sprite_rows(self.current_project, str(self.review_status_filter.get()), str(self.review_query.get()))
        self.project_sprite_rows_cache = rows
        if self._review_list is not None:
            self._review_list.set_items([format_project_sprite_label(sprite) for sprite in rows], select_first=bool(rows))
        if rows:
            self.populate_review_editor()
        else:
            self._clear_review_editor("No sprites match the current review filter.")
        self.refresh_studio_panel()

    def _clear_review_editor(self, message: str) -> None:
        self.review_animation_active = False
        self.review_animation_next_time = None
        self.review_name.set("")
        self.review_category.set("")
        self.review_bbox_x.set("")
        self.review_bbox_y.set("")
        self.review_bbox_width.set("")
        self.review_bbox_height.set("")
        self.review_pivot_x.set("")
        self.review_pivot_y.set("")
        self.review_status.set("needs_review")
        self.review_flags.set("")
        self.review_split_boxes.set("")
        self._show_text_panel("review_image_panel", message)
        self._clear_item_children("review_source_canvas")
        self._draw_canvas_text(message)

    def refresh_project_animation_clips(self) -> None:
        clip_names = project_animation_clip_names(self.current_project) if self.current_project is not None else []
        if dpg is not None and dpg.does_item_exist("review_animation_combo"):
            dpg.configure_item("review_animation_combo", items=clip_names)
        if clip_names:
            self.review_animation_clip.set(clip_names[0])
            self.review_animation_frame_index = 0
        else:
            self.review_animation_clip.set("")

    def _selected_project_sprite(self) -> dict[str, object] | None:
        if self._review_list is None:
            return None
        selection = self._review_list.selected_indices()
        if not selection or selection[0] >= len(self.project_sprite_rows_cache):
            return None
        return self.project_sprite_rows_cache[selection[0]]

    def _selected_project_sprite_ids(self) -> list[str]:
        if self._review_list is None:
            return []
        ids: list[str] = []
        for index in self._review_list.selected_indices():
            if index < len(self.project_sprite_rows_cache):
                ids.append(str(self.project_sprite_rows_cache[index].get("id", "")))
        return [sprite_id for sprite_id in ids if sprite_id]

    def populate_review_editor(self, *_args: object) -> None:
        sprite = self._selected_project_sprite()
        if sprite is None:
            return

        bbox = sprite.get("bbox", {})
        pivot = sprite.get("pivot", {})
        self.review_name.set(str(sprite.get("display_name") or sprite.get("id") or ""))
        self.review_category.set(str(sprite.get("category", "")))
        if isinstance(bbox, dict):
            self.review_bbox_x.set(str(bbox.get("x", "")))
            self.review_bbox_y.set(str(bbox.get("y", "")))
            self.review_bbox_width.set(str(bbox.get("width", "")))
            self.review_bbox_height.set(str(bbox.get("height", "")))
        if isinstance(pivot, dict):
            self.review_pivot_x.set(str(pivot.get("x", "")))
            self.review_pivot_y.set(str(pivot.get("y", "")))
        self.review_status.set(str(sprite.get("review_status", "needs_review")))
        flags = sprite.get("review_flags", [])
        self.review_flags.set(", ".join(str(flag) for flag in flags) if isinstance(flags, list) else "")
        self._update_review_image(sprite)
        self._update_review_source_canvas(sprite)

    def _update_review_image(self, sprite: dict[str, object]) -> None:
        output_file = project_sprite_preview_path_text(sprite)
        if not output_file:
            self._show_text_panel("review_image_panel", "No output image for this sprite.")
            return
        path = self._resolve_project_path(output_file)
        if not path.exists():
            self._show_text_panel("review_image_panel", f"Missing sprite image: {path.name}")
            return
        self._show_review_image_path(path)

    def _resolve_project_path(self, path_text: str) -> Path:
        path = Path(path_text)
        if path.is_absolute() or self.current_project_path is None:
            return path
        return self.current_project_path.parent / path

    def _show_review_image_path(self, path: Path) -> None:
        try:
            with Image.open(path) as source_image:
                image = source_image.convert("RGBA")
            image.thumbnail(REVIEW_IMAGE_PREVIEW_SIZE, Image.Resampling.NEAREST)
            self._show_image_in_panel("review_image_panel", "review", image.copy())
        except UI_ACTION_ERRORS as exc:
            self._show_text_panel("review_image_panel", f"Preview failed: {exc}")

    def _update_review_source_canvas(self, sprite: dict[str, object]) -> None:
        self._clear_item_children("review_source_canvas")
        source_file = sprite.get("source_file")
        bbox = sprite.get("bbox", {})
        if not source_file or not isinstance(bbox, dict):
            self._draw_canvas_text("No source box")
            return
        path = self._resolve_project_path(str(source_file))
        if not path.exists():
            self._draw_canvas_text("Missing source")
            return
        try:
            with Image.open(path) as source_image:
                image = source_image.convert("RGBA")
            canvas_size = REVIEW_CANVAS_SIZE
            int_bbox = {"x": int(bbox["x"]), "y": int(bbox["y"]), "width": int(bbox["width"]), "height": int(bbox["height"])}
            scaled = scale_bbox_for_canvas(int_bbox, image.size, canvas_size)
            display_size = (int(round(image.width * float(scaled["scale"]))), int(round(image.height * float(scaled["scale"]))))
            image = image.resize(display_size, Image.Resampling.NEAREST)
            texture = self._make_texture("review_source", image.copy())
            offset_x, offset_y = scaled["offset"]  # type: ignore[misc]
            self.review_canvas_scale = float(scaled["scale"])
            self.review_canvas_rect = scaled["rect"]  # type: ignore[assignment]
            if dpg is not None and dpg.does_item_exist("review_source_canvas"):
                dpg.draw_image(texture, (int(offset_x), int(offset_y)), (int(offset_x) + display_size[0], int(offset_y) + display_size[1]), parent="review_source_canvas")
                x0, y0, x1, y1 = scaled["rect"]  # type: ignore[misc]
                dpg.draw_rectangle((int(x0), int(y0)), (int(x1), int(y1)), color=(255, 90, 60, 255), thickness=2, parent="review_source_canvas")
        except UI_ACTION_ERRORS as exc:
            self._draw_canvas_text(f"Canvas failed: {exc}")

    def _draw_canvas_text(self, text: str) -> None:
        if dpg is not None and dpg.does_item_exist("review_source_canvas"):
            dpg.draw_text((12, 62), text, color=(230, 232, 239, 255), parent="review_source_canvas", size=14)

    def _current_bbox_fields(self) -> dict[str, int] | None:
        try:
            return parse_bbox_fields(str(self.review_bbox_x.get()), str(self.review_bbox_y.get()), str(self.review_bbox_width.get()), str(self.review_bbox_height.get()))
        except (TypeError, ValueError):
            return None

    def _review_canvas_mouse_pos(self) -> tuple[int, int] | None:
        if dpg is None or not dpg.does_item_exist("review_source_canvas"):
            return None
        try:
            mouse_x, mouse_y = dpg.get_mouse_pos(local=False)
            rect_min = dpg.get_item_rect_min("review_source_canvas")
            return int(mouse_x - rect_min[0]), int(mouse_y - rect_min[1])
        except UI_ACTION_ERRORS as exc:
            self.append_log(f"Review canvas mouse position failed: {exc}")
            return None

    def _on_review_canvas_press(self, *_args: object) -> None:
        bbox = self._current_bbox_fields()
        pos = self._review_canvas_mouse_pos()
        if bbox is None or pos is None or self.review_canvas_rect is None:
            return
        x0, y0, x1, y1 = self.review_canvas_rect
        if x0 <= pos[0] <= x1 and y0 <= pos[1] <= y1:
            self.review_canvas_drag_start = pos
            self.review_canvas_bbox_start = bbox
            self.review_canvas_drag_dirty = False

    def _on_review_canvas_drag(self, *_args: object) -> None:
        if self.review_canvas_drag_start is None or self.review_canvas_bbox_start is None:
            return
        pos = self._review_canvas_mouse_pos()
        if pos is None:
            return
        dx = pos[0] - self.review_canvas_drag_start[0]
        dy = pos[1] - self.review_canvas_drag_start[1]
        bbox = translate_bbox_by_canvas_delta(self.review_canvas_bbox_start, dx, dy, self.review_canvas_scale)
        self.review_bbox_x.set(str(bbox["x"]))
        self.review_bbox_y.set(str(bbox["y"]))
        self.review_bbox_width.set(str(bbox["width"]))
        self.review_bbox_height.set(str(bbox["height"]))
        self.review_canvas_drag_dirty = True
        sprite = self._selected_project_sprite()
        if sprite is not None:
            preview_sprite = dict(sprite)
            preview_sprite["bbox"] = bbox
            self._update_review_source_canvas(preview_sprite)

    def _on_review_canvas_release(self, *_args: object) -> None:
        if self.review_canvas_drag_dirty:
            bbox = self._current_bbox_fields()
            if bbox is not None:
                self.append_log(f"BBox draft updated: {bbox['x']},{bbox['y']},{bbox['width']},{bbox['height']}")
        self.review_canvas_drag_start = None
        self.review_canvas_bbox_start = None
        self.review_canvas_drag_dirty = False

    def play_review_animation(self, *_args: object) -> None:
        if self.current_project is None:
            self._show_info("Play Animation", "Load a project first.")
            return
        clip_name = str(self.review_animation_clip.get()).strip()
        if not clip_name:
            self._show_info("Play Animation", "No animation clip is available.")
            return
        self.stop_review_animation()
        self.review_animation_frame_index = 0
        self.review_animation_active = True
        self.review_animation_next_time = 0.0

    def stop_review_animation(self, *_args: object) -> None:
        self.review_animation_active = False
        self.review_animation_next_time = None

    def _tick_review_animation(self) -> None:
        if not self.review_animation_active:
            return
        if self.review_animation_next_time is not None and time.monotonic() < self.review_animation_next_time:
            return
        duration = self._show_next_animation_frame()
        self.review_animation_next_time = time.monotonic() + duration

    def _show_next_animation_frame(self) -> float:
        if self.current_project is None:
            return 0.125
        clip_name = str(self.review_animation_clip.get()).strip()
        frames = project_animation_clip_frames(self.current_project, clip_name)
        if not frames:
            return 0.125
        frame = frames[self.review_animation_frame_index % len(frames)]
        source_file = frame.get("source_file")
        if source_file:
            self._show_review_image_path(self._resolve_project_path(str(source_file)))
        duration = max(0.02, float(frame.get("duration", 0.125)))
        self.review_animation_frame_index = (self.review_animation_frame_index + 1) % len(frames)
        return duration

    def apply_review_edit(self, *_args: object) -> None:
        if self.current_project is None:
            self._show_info("Apply Edit", "Load a project before editing.")
            return
        sprite = self._selected_project_sprite()
        if sprite is None:
            self._show_info("Apply Edit", "Select a sprite to edit.")
            return
        try:
            update_sprite(
                self.current_project,
                str(sprite["id"]),
                display_name=str(self.review_name.get()).strip() or str(sprite["id"]),
                category=str(self.review_category.get()).strip(),
                bbox=parse_bbox_fields(str(self.review_bbox_x.get()), str(self.review_bbox_y.get()), str(self.review_bbox_width.get()), str(self.review_bbox_height.get())),
                pivot=parse_pivot_fields(str(self.review_pivot_x.get()), str(self.review_pivot_y.get())),
                review_status=str(self.review_status.get()),
                review_flags=parse_flags_text(str(self.review_flags.get())),
            )
            self.append_log(f"Edited sprite: {sprite['id']}")
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Apply Edit", str(exc))

    def approve_review_sprite(self, *_args: object) -> None:
        action = self._resolve("approve_sprite", approve_sprite)
        self._apply_review_action("Approve", action)

    def reject_review_sprite(self, *_args: object) -> None:
        action = self._resolve("reject_sprite", reject_sprite)
        self._apply_review_action("Reject", action)

    def _apply_review_action(self, label: str, action: object) -> None:
        if self.current_project is None:
            self._show_info(label, "Load a project first.")
            return
        sprite = self._selected_project_sprite()
        if sprite is None:
            self._show_info(label, "Select a sprite first.")
            return
        try:
            action(self.current_project, str(sprite["id"]))  # type: ignore[operator]
            self.append_log(f"{label}: {sprite['id']}")
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error(label, str(exc))

    def undo_project_edit(self, *_args: object) -> None:
        self._apply_project_stack_action("Undo", undo_last_edit)

    def redo_project_edit(self, *_args: object) -> None:
        self._apply_project_stack_action("Redo", redo_last_edit)

    def _apply_project_stack_action(self, label: str, action: object) -> None:
        if self.current_project is None:
            self._show_info(label, "Load a project first.")
            return
        try:
            action(self.current_project)  # type: ignore[operator]
            self.append_log(f"{label} project edit")
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error(label, str(exc))

    def _parse_split_boxes(self) -> list[dict[str, int]]:
        boxes: list[dict[str, int]] = []
        for raw_box in str(self.review_split_boxes.get()).split(";"):
            parts = [part.strip() for part in raw_box.split(",") if part.strip()]
            if not parts:
                continue
            if len(parts) != 4:
                raise ValueError("Split boxes use x,y,width,height; x,y,width,height.")
            boxes.append(parse_bbox_fields(parts[0], parts[1], parts[2], parts[3]))
        return boxes

    def split_review_sprite(self, *_args: object) -> None:
        if self.current_project is None:
            self._show_info("Split Sprite", "Load a project first.")
            return
        sprite = self._selected_project_sprite()
        if sprite is None:
            self._show_info("Split Sprite", "Select one sprite to split.")
            return
        try:
            split_sprite(self.current_project, str(sprite["id"]), self._parse_split_boxes())
            self.append_log(f"Split sprite: {sprite['id']}")
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Split Sprite", str(exc))

    def merge_review_sprites(self, *_args: object) -> None:
        if self.current_project is None:
            self._show_info("Merge Sprites", "Load a project first.")
            return
        sprite_ids = self._selected_project_sprite_ids()
        if len(sprite_ids) < 2:
            self._show_info("Merge Sprites", "Select at least two sprites.")
            return
        merged_id = str(self.review_name.get()).strip() or f"{sprite_ids[0]}_merged"
        try:
            merge_sprites(self.current_project, sprite_ids, merged_id=merged_id, display_name=merged_id)
            self.append_log(f"Merged sprites: {', '.join(sprite_ids)}")
            self.refresh_project_rows()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Merge Sprites", str(exc))
