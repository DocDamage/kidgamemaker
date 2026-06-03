# Codex Next Prompt

Use this prompt to guide the next coding session.

```text
You are working in DocDamage/kidgamemaker.

Goal: Integrate the sprite editor into the main game maker and build the visual HUD for the Godot runner.

Background Context:
- The core engine (Phases 1–9) is fully implemented on the `main` branch.
- The sprite editor codebase has been imported to the `sprite-editor` branch under the `sprite-editor/` folder.
- Current game UI displays placeholder blocks/shapes because assets are 1x1 png stubs.

Tasks:
1. Switch to the `sprite-editor` branch.
2. Build a bridge between the Svelte/Tauri editor UI and the python sprite processor/editor (`sprite-editor/`).
3. Allow the child to select a custom sprite or frame from the Toybox, click "Edit Sprite", and open the sprite cutter/palette variant UI.
4. In the Godot runner, implement a CanvasLayer visual HUD showing:
   - Player health (drawn as hearts matching `current_health`).
   - Score counter (drawn matching `score`).
5. Ensure the HUD respects the active day/night CanvasModulate lighting (e.g. by placing it on a separate CanvasLayer so it remains unshaded).
6. Export the Godot runner binary (`Runner.exe`) using Godot 4.x desktop export settings and place it in the engine directory.

Constraints:
- Keep the interface child-friendly and zero-code.
- Do not add complicated script blocks in Svelte for individual items.
- Ensure all tests continue to pass.
```
