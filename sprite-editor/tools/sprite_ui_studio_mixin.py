from __future__ import annotations

import json
import sys
from pathlib import Path

try:
    import dearpygui.dearpygui as dpg
except ModuleNotFoundError:
    dpg = None  # type: ignore[assignment]

try:
    from tools.sprite_ui_settings import RunOutputTargets
    from tools.sprite_studio import (
        apply_taxonomy_rules,
        generate_collision_profiles,
        build_engine_import_plans,
        train_preset_from_project,
        diff_projects,
        review_and_apply_project,
    )
    from tools.sprite_ui_helpers import (
        UI_ACTION_ERRORS,
        studio_dashboard_text,
        studio_queue_labels,
        studio_asset_rows,
        studio_asset_label,
        studio_default_taxonomy_rules,
        studio_project_diff_text,
    )
    from tools.sprite_project import load_project, save_project
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_ui_settings import RunOutputTargets
    from tools.sprite_studio import (
        apply_taxonomy_rules,
        generate_collision_profiles,
        build_engine_import_plans,
        train_preset_from_project,
        diff_projects,
        review_and_apply_project,
    )
    from tools.sprite_ui_helpers import (
        UI_ACTION_ERRORS,
        studio_dashboard_text,
        studio_queue_labels,
        studio_asset_rows,
        studio_asset_label,
        studio_default_taxonomy_rules,
        studio_project_diff_text,
    )
    from tools.sprite_project import load_project, save_project


class SpriteStudioUiMixin:
    def _resolve(self, name: str, fallback: object) -> object:
        module = sys.modules.get(self.__class__.__module__)
        return getattr(module, name, fallback) if module is not None else fallback

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
