from __future__ import annotations

import sys
import time
from pathlib import Path
from typing import Callable

from PIL import Image

try:
    import dearpygui.dearpygui as dpg
except ModuleNotFoundError:
    dpg = None  # type: ignore[assignment]

try:
    from tools.sprite_project import approve_sprite, load_project, merge_sprites, redo_last_edit, reject_sprite, save_project, split_sprite, undo_last_edit, update_sprite
    from tools.sprite_ui_helpers import (
        UI_ACTION_ERRORS,
        REVIEW_CANVAS_SIZE,
        REVIEW_IMAGE_PREVIEW_SIZE,
        scale_bbox_for_canvas,
        translate_bbox_by_canvas_delta,
        project_sprite_rows,
        project_sprite_preview_path_text,
        format_project_sprite_label,
        project_animation_clip_names,
        project_animation_clip_frames,
        parse_bbox_fields,
        parse_flags_text,
        parse_pivot_fields,
    )
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.sprite_project import approve_sprite, load_project, merge_sprites, redo_last_edit, reject_sprite, save_project, split_sprite, undo_last_edit, update_sprite
    from tools.sprite_ui_helpers import (
        UI_ACTION_ERRORS,
        REVIEW_CANVAS_SIZE,
        REVIEW_IMAGE_PREVIEW_SIZE,
        scale_bbox_for_canvas,
        translate_bbox_by_canvas_delta,
        project_sprite_rows,
        project_sprite_preview_path_text,
        format_project_sprite_label,
        project_animation_clip_names,
        project_animation_clip_frames,
        parse_bbox_fields,
        parse_flags_text,
        parse_pivot_fields,
    )


class SpriteReviewUiMixin:
    def _resolve(self, name: str, fallback: object) -> object:
        module = sys.modules.get(self.__class__.__module__)
        return getattr(module, name, fallback) if module is not None else fallback

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
