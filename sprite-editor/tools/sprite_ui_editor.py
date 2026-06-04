from __future__ import annotations

import sys
import time
from dataclasses import replace
from pathlib import Path

from PIL import Image

try:
    import dearpygui.dearpygui as dpg
except ModuleNotFoundError:  # Keep helper tests importable when the GUI dependency is not installed.
    dpg = None  # type: ignore[assignment]

try:
    from tools.autotile_tools import write_autotile_package
    from tools.sprite_animation_editor import AnimationEditSession, AnimationFrameRef, playback_next_frame, write_applied_animation
    from tools.sprite_editor import SpriteEditSession, write_edit_package
    from tools.sprite_editor_workspace import (
        EDITOR_SHORTCUTS,
        EDITOR_TOOLS,
        CanvasView,
        EditorTool,
        MouseGesture,
        ToolScope,
        apply_mouse_tool,
        apply_shortcut_action,
        canvas_status_text,
        palette_swatch_rows,
        shortcut_action_for_key,
        state_help_text,
    )
    from tools.sprite_project import attach_animation_edit_output, attach_sprite_edit_output, save_project
    from tools.sprite_ui_helpers import (
        UI_ACTION_ERRORS,
        editor_callable_actions,
        editor_color_wheel_preview,
        editor_palette_summary,
        editor_parse_rect_text,
        editor_parse_size_text,
        editor_variant_package,
        project_sprite_preview_path_text,
    )
    from tools.sprite_ui_panels import attach_tooltip
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from tools.autotile_tools import write_autotile_package
    from tools.sprite_animation_editor import AnimationEditSession, AnimationFrameRef, playback_next_frame, write_applied_animation
    from tools.sprite_editor import SpriteEditSession, write_edit_package
    from tools.sprite_editor_workspace import (
        EDITOR_SHORTCUTS,
        EDITOR_TOOLS,
        CanvasView,
        EditorTool,
        MouseGesture,
        ToolScope,
        apply_mouse_tool,
        apply_shortcut_action,
        canvas_status_text,
        palette_swatch_rows,
        shortcut_action_for_key,
        state_help_text,
    )
    from tools.sprite_project import attach_animation_edit_output, attach_sprite_edit_output, save_project
    from tools.sprite_ui_helpers import (
        UI_ACTION_ERRORS,
        editor_callable_actions,
        editor_color_wheel_preview,
        editor_palette_summary,
        editor_parse_rect_text,
        editor_parse_size_text,
        editor_variant_package,
        project_sprite_preview_path_text,
    )
    from tools.sprite_ui_panels import attach_tooltip


class SpriteEditorUiMixin:
    def _editor_rect_parser(self):
        app_module = sys.modules.get(self.__class__.__module__)
        return getattr(app_module, "editor_parse_rect_text", editor_parse_rect_text)

    def _editor_size_parser(self):
        app_module = sys.modules.get(self.__class__.__module__)
        return getattr(app_module, "editor_parse_size_text", editor_parse_size_text)

    def set_editor_fullscreen(self, enabled: bool) -> None:
        self.editor_workspace = self.editor_workspace.with_fullscreen(enabled)
        self.editor_fullscreen.set(enabled)

    def set_editor_tool(self, tool_value: str) -> None:
        tool = EditorTool(tool_value)
        self.editor_workspace = self.editor_workspace.with_tool(tool)
        self.editor_active_tool.set(tool.value)
        self._update_editor_help_panel()

    def set_editor_tool_scope(self, scope_value: str) -> None:
        scope = ToolScope(scope_value)
        self.editor_workspace = self.editor_workspace.with_scope(scope)
        self.editor_tool_scope.set(scope.value)

    def _refresh_editor_status(self, cursor: tuple[int, int] | None = None, color_hex: str | None = None) -> None:
        self.editor_status.set(
            canvas_status_text(
                cursor,
                color_hex,
                self.editor_canvas_view.zoom,
                self.editor_workspace.active_layer_index,
                self.editor_workspace.active_frame_index,
            )
        )

    def editor_visibility_plan(self) -> dict[str, bool]:
        fullscreen = bool(self.editor_workspace.fullscreen)
        return {
            "main_panels": not fullscreen,
            "editor_panel": True,
            "timeline_panel": fullscreen or self.editor_animation_frames_loaded(),
            "log_panel": not fullscreen,
        }

    def editor_animation_frames_loaded(self) -> bool:
        return self.editor_animation_session is not None and bool(self.editor_animation_session.frames)

    def _build_editor_tool_rail(self) -> None:
        for tool, metadata in EDITOR_TOOLS.items():
            self._add_button(metadata.label, lambda _s=None, _a=None, value=tool.value: self.set_editor_tool(value), f"editor_tool_{tool.value}", width=-1)
        self._add_combo("##editor_tool_scope", self.editor_tool_scope, [scope.value for scope in ToolScope], "editor_tool_scope", width=-1, callback=lambda *_args: self.set_editor_tool_scope(str(self.editor_tool_scope.get())))

    def _build_editor_canvas_panel(self) -> None:
        if self.editor_session is None:
            dpg.add_text("Load a sprite or open one from Review to begin editing.", wrap=480)
            return
        self.refresh_editor_preview()

    def _build_editor_side_panel(self) -> None:
        dpg.add_text("Layers")
        with dpg.child_window(tag="editor_layers_panel", width=-1, height=130, border=True):
            attach_tooltip("editor_layers_panel", "editor_layers_panel")
            self._build_editor_layers_panel()
        dpg.add_text("Palette")
        with dpg.child_window(tag="editor_palette_panel", width=-1, height=150, border=True):
            attach_tooltip("editor_palette_panel", "editor_palette_panel")
            self._build_editor_palette_panel()
        dpg.add_text("Tool Help")
        with dpg.child_window(tag="editor_help_panel", width=-1, height=190, border=True):
            attach_tooltip("editor_help_panel", "editor_help_panel")
            self._build_editor_help_panel()

    def _build_editor_layers_panel(self) -> None:
        rows = self.editor_layer_rows()
        if not rows:
            dpg.add_text("Load a sprite to manage layers.", wrap=260)
            return
        for index, row in enumerate(rows):
            self._add_button(row, lambda _s=None, _a=None, value=index: self.select_editor_layer(value), "editor_layers_panel", width=-1)
        with dpg.group(horizontal=True):
            self._add_button("Duplicate", self.duplicate_editor_layer, "editor_layers_panel")
            self._add_button("Delete", self.delete_editor_layer, "editor_layers_panel")

    def _build_editor_palette_panel(self) -> None:
        rows = self.editor_palette_rows()
        if not rows:
            dpg.add_text("Load a sprite to inspect its palette.", wrap=260)
            return
        for row in rows:
            dpg.add_text(row)
        dpg.add_text("Swap")
        with dpg.group(horizontal=True):
            self._add_input_text("##editor_source_color_panel", self.editor_source_color, "editor_source_color", "editor_source_color", width=110)
            self._add_input_text("##editor_target_color_panel", self.editor_target_color, "editor_target_color", "editor_target_color", width=110)
        self._add_button("Apply Swap", self.apply_editor_palette_swap, "editor_swap_colors", width=-1)

    def _build_editor_help_panel(self) -> None:
        dpg.add_text(state_help_text(self.editor_workspace), tag="editor_help_text", wrap=260)
        with dpg.group(horizontal=True):
            self._add_button("Undo", self.undo_editor_edit, "editor_undo")
            self._add_button("Redo", self.redo_editor_edit, "editor_redo")
        dpg.add_text("Transform")
        self._add_input_text("##editor_crop_rect", self.editor_crop_rect, "editor_crop_rect", "editor_crop_rect", width=-1)
        with dpg.group(horizontal=True):
            self._add_button("Crop", self.apply_editor_crop, "editor_crop")
            self._add_input_text("##editor_resize_size", self.editor_resize_size, "editor_resize_size", "editor_resize_size", width=110)
            self._add_button("Resize", self.apply_editor_resize, "editor_resize")
        with dpg.group(horizontal=True):
            self._add_combo("##editor_flip_axis", self.editor_flip_axis, ["horizontal", "vertical"], "editor_flip_axis", width=120)
            self._add_button("Flip", self.apply_editor_flip, "editor_flip")
            self._add_button("Rotate CW", lambda *_args: self.apply_editor_rotate(clockwise=True), "editor_rotate")
            self._add_button("Rotate CCW", lambda *_args: self.apply_editor_rotate(clockwise=False), "editor_rotate")
        with dpg.group(horizontal=True):
            self._add_combo("##editor_harmony", self.editor_harmony, ["complementary", "analogous", "triadic", "tetradic"], "editor_color_wheel", width=135)
            self._add_input_text("##editor_hue_degrees", self.editor_hue_degrees, "editor_hue_degrees", "editor_hue_degrees", width=100)
        with dpg.group(horizontal=True):
            self._add_button("Hue Shift", self.apply_editor_hue_shift, "editor_hue_shift")
            self._add_button("Wheel", self.preview_editor_color_wheel, "editor_color_wheel")
        self._add_button("Palette Variants", self.generate_editor_palette_variants, "editor_palette_variants", width=-1)
        with dpg.group(horizontal=True):
            self._add_input_text("##editor_autotile_name", self.editor_autotile_name, "editor_autotile_name", "editor_autotile_name", width=135)
            self._add_combo("##editor_engine", self.editor_engine, ["generic", "unity", "godot", "unreal"], "engine_exports", width=100)
        self._add_button("Generate Auto-Tile", self.generate_editor_autotile, "editor_generate_autotile", width=-1)
        self._add_button("IDE Actions", self.show_editor_ide_actions, "editor_ide_api", width=-1)

    def _build_editor_timeline_panel(self) -> None:
        if self.editor_animation_session is None:
            dpg.add_text("No animation loaded.", wrap=760)
            return
        with dpg.group(horizontal=True):
            self._add_button("Play/Pause", self.toggle_editor_animation_playback, "play_animation")
            dpg.add_text(f"{self.editor_animation_session.name} | fps={self.editor_animation_session.fps}")
        for index, frame in enumerate(self.editor_animation_session.frames):
            marker = "*" if index == self.editor_animation_session.active_frame else " "
            self._add_button(f"{marker} {index + 1}. {frame.name}", lambda _s=None, _a=None, value=index: self.select_editor_animation_frame(value), "editor_timeline_panel")

    def _update_editor_help_panel(self) -> None:
        text = state_help_text(self.editor_workspace)
        if dpg is not None and self._built and dpg.does_item_exist("editor_help_text"):
            dpg.set_value("editor_help_text", text)

    def handle_editor_shortcut(self, shortcut: str) -> bool:
        action = shortcut_action_for_key(shortcut)
        if action is None:
            return False
        self.editor_workspace, command = apply_shortcut_action(self.editor_workspace, action)
        self.editor_active_tool.set(self.editor_workspace.active_tool.value)
        self._update_editor_help_panel()
        if command == "undo":
            self.undo_editor_edit()
        elif command == "redo":
            self.redo_editor_edit()
        elif command == "save":
            self.save_editor_package()
        elif command == "fit":
            self.editor_canvas_view = CanvasView.fit(self.editor_canvas_view.sprite_size, self.editor_canvas_view.panel_size)
        elif command == "actual_size":
            self.editor_canvas_view = self.editor_canvas_view.zoom_around_cursor((0, 0), 1.0 / max(1.0, self.editor_canvas_view.zoom))
        elif command == "play_pause":
            self.toggle_editor_animation_playback()
        self._refresh_editor_status()
        return True

    def _editor_canvas_sprite_point_from_mouse(self) -> tuple[int, int] | None:
        if dpg is None or not self._built or not dpg.does_item_exist("editor_canvas"):
            return None
        mouse = dpg.get_mouse_pos(local=False)
        rect_min = dpg.get_item_rect_min("editor_canvas")
        local = (int(mouse[0] - rect_min[0]), int(mouse[1] - rect_min[1]))
        return self.editor_canvas_view.screen_to_sprite(local)

    def _apply_editor_mouse_gesture(self, gesture: MouseGesture) -> None:
        if self.editor_session is None:
            self._show_info("Editor", "Load a sprite or open one from Review to begin editing.")
            return
        result = apply_mouse_tool(self.editor_session, self.editor_workspace, gesture)
        if result.sampled_color is not None:
            self.editor_source_color.set(result.sampled_color)
            self.editor_workspace = self.editor_workspace.with_tool(EditorTool.PENCIL)
            self.editor_active_tool.set(EditorTool.PENCIL.value)
        if result.crop_rect is not None:
            self.editor_crop_rect.set(",".join(str(part) for part in result.crop_rect))
        if result.selected_region is not None:
            self.editor_workspace = replace(self.editor_workspace, selected_region=result.selected_region)
        if result.pan_delta is not None:
            self.editor_canvas_view = self.editor_canvas_view.panned(result.pan_delta)
        if result.zoom_factor is not None:
            self.editor_canvas_view = self.editor_canvas_view.zoom_around_cursor(gesture.start, result.zoom_factor)
        self.refresh_editor_preview()
        self._refresh_editor_status(gesture.end or gesture.start)

    def editor_layer_rows(self) -> list[str]:
        if self.editor_session is None:
            return []
        rows = []
        for index, layer in enumerate(self.editor_session.layers):
            active = "*" if index == self.editor_session.active_layer else " "
            visible = "visible" if layer.visible else "hidden"
            rows.append(f"{active} {index + 1}. {layer.name} {visible} opacity={layer.opacity:.2f}")
        return rows

    def select_editor_layer(self, index: int) -> None:
        if self.editor_session is None:
            self._show_info("Layers", "Load a sprite before selecting a layer.")
            return
        self.editor_session.select_layer(index)
        self.editor_workspace = replace(self.editor_workspace, active_layer_index=index)
        self.refresh_editor_preview()

    def duplicate_editor_layer(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Layers", "Load a sprite before duplicating a layer.")
            return
        self.editor_session.duplicate_layer(self.editor_session.active_layer)
        self.editor_workspace = replace(self.editor_workspace, active_layer_index=self.editor_session.active_layer)
        self.refresh_editor_preview()

    def delete_editor_layer(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Layers", "Load a sprite before deleting a layer.")
            return
        self.editor_session.delete_layer(self.editor_session.active_layer)
        self.editor_workspace = replace(self.editor_workspace, active_layer_index=self.editor_session.active_layer)
        self.refresh_editor_preview()

    def editor_palette_rows(self) -> list[str]:
        if self.editor_session is None:
            return []
        return palette_swatch_rows(self.editor_session.composite(), active_color=str(self.editor_source_color.get()))

    def editor_help_reference_text(self) -> str:
        shortcuts = "\n".join(f"{key}: {value}" for key, value in sorted(EDITOR_SHORTCUTS.items()))
        tools = "\n".join(f"{metadata.label}: {metadata.help_text}" for metadata in EDITOR_TOOLS.values())
        return (
            "Quick Start\n"
            "Load a sprite, choose a tool, edit on the canvas, then save a package or save back to the project.\n\n"
            "Mouse\n"
            "Left click edits with the active tool. Drag previews lines, rectangles, crops, and pans. Mouse wheel zooms on the canvas.\n\n"
            "Shortcuts\n"
            f"{shortcuts}\n\n"
            "Tools\n"
            f"{tools}\n\n"
            "Animation\n"
            "Load a project clip, select a frame, play the preview, edit one frame or all frames, then save applied animation output."
        )

    def load_editor_animation_clip_from_project(self, clip_name: str) -> None:
        if self.current_project is None:
            self._show_info("Animation", "Load a SpriteCut project before opening animation clips.")
            return
        clips = self.current_project.get("animation_clips", [])
        clip = next((item for item in clips if isinstance(item, dict) and item.get("name") == clip_name), None) if isinstance(clips, list) else None
        if not isinstance(clip, dict):
            self._show_info("Animation", f"Animation clip not found: {clip_name}")
            return
        frame_refs: list[AnimationFrameRef] = []
        for frame in clip.get("frames", []):
            if not isinstance(frame, dict):
                continue
            path_text = str(frame.get("source_file", ""))
            path = self._resolve_project_path(path_text) if path_text else None
            if path is not None and path.exists():
                frame_refs.append(AnimationFrameRef(str(frame.get("sprite", "")), path, float(frame.get("duration", 0.0833))))
        if not frame_refs:
            self._show_info("Animation", "No readable frames were found for this clip.")
            return
        self.editor_animation_session = AnimationEditSession.from_frame_refs(str(clip_name), frame_refs, fps=int(clip.get("frame_rate", 12)))
        self.editor_animation_clip.set(str(clip_name))
        self.editor_animation_fps.set(self.editor_animation_session.fps)
        self.editor_session = self.editor_animation_session.frames[0]
        self.editor_workspace = replace(self.editor_workspace, active_frame_index=0)
        self.refresh_editor_preview()

    def toggle_editor_animation_playback(self, *_args: object) -> None:
        self.editor_animation_playing = not self.editor_animation_playing
        self.editor_animation_last_tick = None

    def select_editor_animation_frame(self, index: int) -> None:
        if self.editor_animation_session is None:
            return
        index = max(0, min(len(self.editor_animation_session.frames) - 1, int(index)))
        self.editor_animation_session.active_frame = index
        self.editor_session = self.editor_animation_session.frames[index]
        self.editor_workspace = replace(self.editor_workspace, active_frame_index=index)
        self.refresh_editor_preview()

    def tick_editor_animation(self, now: float | None = None) -> None:
        if not self.editor_animation_playing or self.editor_animation_session is None:
            return
        current_time = time.monotonic() if now is None else float(now)
        if self.editor_animation_last_tick is not None and current_time - self.editor_animation_last_tick < 1.0 / max(1, int(self.editor_animation_fps.get())):
            return
        self.editor_animation_last_tick = current_time
        self.select_editor_animation_frame(playback_next_frame(self.editor_animation_session.active_frame, len(self.editor_animation_session.frames)))

    def open_selected_review_sprite_in_editor(self, *_args: object) -> None:
        sprite = self._selected_project_sprite()
        if sprite is None:
            self._show_info("Editor", "Select a Review sprite before opening it in the editor.")
            return
        preview = project_sprite_preview_path_text(sprite)
        if not preview:
            self._show_info("Editor", "The selected sprite has no output image to edit.")
            return
        path = self._resolve_project_path(preview)
        if not path.exists():
            self._show_info("Editor", f"Missing sprite image: {path}")
            return
        self.editor_source_sprite_id = str(sprite["id"])
        self.load_editor_sprite(path)
        self.set_editor_fullscreen(True)

    def save_editor_to_project(self, *_args: object) -> None:
        if self.current_project is None or self.current_project_path is None:
            self._show_info("Editor", "Load a SpriteCut project before saving editor output back to a project.")
            return
        if self.editor_animation_session is not None:
            output = write_applied_animation(self.editor_animation_session, self.current_project_path.parent / "applied_project" / "animations")
            self.current_project = attach_animation_edit_output(self.current_project, self.editor_animation_session.name, str(output["manifest"]))
            save_project(self.current_project, self.current_project_path)
            self._show_info("Editor", f"Saved edited animation: {output['manifest']}")
            return
        if self.editor_session is None or not self.editor_source_sprite_id:
            self._show_info("Editor", "Open a project sprite in the editor before saving back to the project.")
            return
        output_dir = self.current_project_path.parent / "applied_project" / "sprites" / "edited"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / f"{self.editor_source_sprite_id}.png"
        self.editor_session.composite().save(output_path)
        self.current_project = attach_sprite_edit_output(self.current_project, self.editor_source_sprite_id, str(output_path))
        save_project(self.current_project, self.current_project_path)
        self._show_info("Editor", f"Saved edited sprite: {output_path}")

    def load_editor_sprite_dialog(self, *_args: object) -> None:
        if dpg is not None:
            dpg.show_item("editor_sprite_dialog")

    def _load_editor_sprite_callback(self, _sender: object, app_data: object, _user_data: object = None) -> None:
        path = self._dialog_path(app_data)
        if path is not None:
            self.load_editor_sprite(path)

    def _load_editor_sprite_impl(self, path: Path) -> None:
        try:
            self.editor_session = SpriteEditSession.open(path)
            self.editor_animation_session = None
            self.editor_source_sprite_id = self.editor_source_sprite_id or ""
            self.editor_autotile_name.set(path.stem)
            self.append_log(f"Loaded editor sprite: {path}")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Load Sprite", str(exc))

    def _refresh_editor_preview(self) -> None:
        self.refresh_editor_preview()

    def refresh_editor_preview(self) -> None:
        if self.editor_session is None:
            self._show_text_panel("editor_preview_panel", "Load a sprite to edit.")
            self._set_text("editor_palette_label", "Palette: none")
            return
        image = self.editor_session.composite()
        self.editor_canvas_view = replace(self.editor_canvas_view, sprite_size=image.size)
        self._refresh_editor_status()
        preview = image.copy()
        preview.thumbnail((180, 135), Image.Resampling.NEAREST)
        self._show_image_in_panel("editor_preview_panel", "editor", preview)
        self._set_text("editor_palette_label", "Palette: " + editor_palette_summary(image, max_colors=8))

    def save_editor_package(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Save Package", "Load a sprite before saving an edit package.")
            return
        self._dialog_actions["directory_action_dialog"] = self._write_editor_package_to
        if dpg is not None:
            dpg.show_item("directory_action_dialog")

    def _write_editor_package_to(self, path: Path) -> None:
        if self.editor_session is None:
            return
        try:
            result = write_edit_package(self.editor_session, path)
            self.append_log(f"Saved editor package: {result['image']}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Save Package", str(exc))

    def _apply_editor_palette_swap_impl(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Palette Swap", "Load a sprite before swapping colors.")
            return
        try:
            source = str(self.editor_source_color.get()).strip()
            target = str(self.editor_target_color.get()).strip()
            self.editor_session.replace_color(source, target)
            self.append_log(f"Palette swap: {source} -> {target}")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Palette Swap", str(exc))

    def _apply_editor_hue_shift_impl(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Hue Shift", "Load a sprite before applying hue shifts.")
            return
        try:
            degrees = float(self.editor_hue_degrees.get())
            self.editor_session.hue_shift(degrees)
            self.append_log(f"Hue shift: {degrees:g} degrees")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Hue Shift", str(exc))

    def undo_editor_edit(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Undo", "Load a sprite before undoing editor operations.")
            return
        try:
            self.editor_session.undo()
            self.append_log("Undo editor operation")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Undo", str(exc))

    def redo_editor_edit(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Redo", "Load a sprite before redoing editor operations.")
            return
        try:
            self.editor_session.redo()
            self.append_log("Redo editor operation")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Redo", str(exc))

    def _apply_editor_crop_impl(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Crop", "Load a sprite before cropping.")
            return
        try:
            rect = self._editor_rect_parser()(str(self.editor_crop_rect.get()))
            self.editor_session.crop(rect)
            self.append_log(f"Crop: {rect[0]},{rect[1]},{rect[2]},{rect[3]}")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Crop", str(exc))

    def _apply_editor_resize_impl(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Resize", "Load a sprite before resizing.")
            return
        try:
            size = self._editor_size_parser()(str(self.editor_resize_size.get()))
            self.editor_session.resize(size)
            self.append_log(f"Resize: {size[0]}x{size[1]}")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Resize", str(exc))

    def _apply_editor_flip_impl(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Flip", "Load a sprite before flipping.")
            return
        try:
            axis = str(self.editor_flip_axis.get()).strip().lower()
            if axis == "horizontal":
                self.editor_session.flip_horizontal()
            elif axis == "vertical":
                self.editor_session.flip_vertical()
            else:
                raise ValueError(f"Unsupported flip axis: {axis}")
            self.append_log(f"Flip: {axis}")
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Flip", str(exc))

    def _apply_editor_rotate_impl(self, *, clockwise: bool = True) -> None:
        if self.editor_session is None:
            self._show_info("Rotate", "Load a sprite before rotating.")
            return
        try:
            self.editor_session.rotate_90(clockwise=clockwise)
            self.append_log("Rotate: 90 degrees " + ("clockwise" if clockwise else "counter-clockwise"))
            self.refresh_editor_preview()
        except UI_ACTION_ERRORS as exc:
            self._show_error("Rotate", str(exc))

    def preview_editor_color_wheel(self, *_args: object) -> None:
        try:
            base = str(self.editor_target_color.get()).strip() or "#ff0000"
            preview = editor_color_wheel_preview(base, str(self.editor_harmony.get()))
            self.append_log(f"Color wheel: {preview}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Color Wheel", str(exc))

    def generate_editor_palette_variants(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Palette Variants", "Load a sprite before generating palette variants.")
            return
        self._dialog_actions["directory_action_dialog"] = self._write_palette_variants_to
        if dpg is not None:
            dpg.show_item("directory_action_dialog")

    def _write_palette_variants_to(self, path: Path) -> None:
        if self.editor_session is None:
            return
        try:
            result = editor_variant_package(
                self.editor_session,
                path,
                name=self.editor_session.name,
                base_color=str(self.editor_source_color.get()).strip() or "#ff0000",
                harmony=str(self.editor_harmony.get()),
            )
            self.append_log(f"Generated palette variants: {result['contact_sheet']}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Palette Variants", str(exc))

    def generate_editor_autotile(self, *_args: object) -> None:
        if self.editor_session is None:
            self._show_info("Auto-Tile", "Load a sprite before generating an auto-tile.")
            return
        self._dialog_actions["directory_action_dialog"] = self._write_autotile_to
        if dpg is not None:
            dpg.show_item("directory_action_dialog")

    def _write_autotile_to(self, path: Path) -> None:
        if self.editor_session is None:
            return
        try:
            result = write_autotile_package(
                self.editor_session.composite(),
                path,
                name=str(self.editor_autotile_name.get()).strip() or self.editor_session.name,
                engine=str(self.editor_engine.get()),
            )
            self.append_log(f"Generated auto-tile: {result['sheet']} rules={result['rules']}")
        except UI_ACTION_ERRORS as exc:
            self._show_error("Auto-Tile", str(exc))

    def show_editor_ide_actions(self, *_args: object) -> None:
        actions = ", ".join(editor_callable_actions())
        self._show_info("IDE API", "Use tools\\sprite_ide_api.py with --request request.json.\n\n" f"Actions: {actions}")
