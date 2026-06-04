from __future__ import annotations

import os
import queue
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import Any

from tools.sprite_ui_settings import RunOutputTargets, build_cutter_command, output_targets_from_cli_line, summarize_cli_output_line
from tools.sprite_ui_helpers import PROCESS_RUN_ERRORS, UI_ACTION_ERRORS, request_process_stop


def process_impl(app: Any, *_args: object) -> None:
    if app.worker and app.worker.is_alive():
        app._show_info("Processing", "A processing run is already active.")
        return

    settings = app.current_settings()
    if settings is None:
        return

    command = build_cutter_command(settings)
    app._set_latest_run_targets(None)
    app.append_log("> " + " ".join(command))
    app._set_processing(True)
    app.worker = threading.Thread(target=run_process, args=(app, command,), daemon=True)
    app.worker.start()


def run_process(app: Any, command: list[str]) -> None:
    try:
        subproc = getattr(sys.modules.get(app.__class__.__module__), "subprocess", subprocess)
        process = subproc.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        app.active_process = process
        assert process.stdout is not None
        for line in process.stdout:
            for summary_line in summarize_cli_output_line(line.rstrip()):
                app.log_queue.put(summary_line)
        return_code = process.wait()
        app.log_queue.put(f"Process exited with code {return_code}")
    except PROCESS_RUN_ERRORS as exc:
        app.log_queue.put(f"Process failed: {exc}")
    finally:
        app.active_process = None
        app.log_queue.put("__STOP_PROGRESS__")


def cancel_process(app: Any, *_args: object) -> None:
    process = app.active_process
    if process is None or process.poll() is not None:
        app.append_log("No active process to cancel.")
        app._set_processing(False)
        return
    app.append_log("Cancel requested.")
    outcome = request_process_stop(process)
    if outcome == "killed":
        app.append_log("Process did not exit after terminate; killed it.")
    elif outcome == "kill requested":
        app.append_log("Process did not exit after kill request; waiting for worker cleanup.")


def shutdown_active_process(app: Any) -> None:
    process = app.active_process
    if process is None or process.poll() is not None:
        return
    outcome = request_process_stop(process)
    app.append_log(f"Stopped active process during UI shutdown: {outcome}.")


def drain_log_queue(app: Any) -> None:
    while True:
        try:
            line = app.log_queue.get_nowait()
        except queue.Empty:
            break
        if line == "__STOP_PROGRESS__":
            app._set_processing(False)
        else:
            targets = output_targets_from_cli_line(line)
            if targets is not None:
                app._set_latest_run_targets(targets)
            app.append_log(line)


def open_latest_output(app: Any, *_args: object) -> None:
    open_existing_path(app, app.latest_output_dir, "output folder")


def open_latest_report(app: Any, *_args: object) -> None:
    open_existing_path(app, app.latest_report_path, "HTML report")


def open_latest_project(app: Any, *_args: object) -> None:
    if app.latest_project_path is not None and app.latest_project_path.exists():
        app.load_project_file(app.latest_project_path)
        return
    open_existing_path(app, app.latest_project_path, "project file")


def open_existing_path(app: Any, path: Path | None, label: str) -> None:
    if path is None:
        app._show_info("No Run Output", "Process a sheet before opening run output.")
        return
    if not path.exists():
        app._show_error("Missing Output", f"The latest {label} does not exist:\n{path}")
        return
    try:
        if sys.platform.startswith("win"):
            os.startfile(str(path))  # type: ignore[attr-defined]
        elif sys.platform == "darwin":
            subproc = getattr(sys.modules.get(app.__class__.__module__), "subprocess", subprocess)
            subproc.Popen(["open", str(path)])
        else:
            subproc = getattr(sys.modules.get(app.__class__.__module__), "subprocess", subprocess)
            subproc.Popen(["xdg-open", str(path)])
    except UI_ACTION_ERRORS as exc:
        app._show_error("Open Output", str(exc))
