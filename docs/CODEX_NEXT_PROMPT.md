# Codex Next Prompt

Use this after the Phase 1 files are in the repo.

```text
You are working in DocDamage/kidgamemaker.

Goal: complete Phase 1 contract-first runner validation.

Do not add AI ingestion yet. Do not add complex world map systems yet.

Tasks:
1. Verify the Svelte/Tauri editor builds.
2. Fix any TypeScript, Svelte, Rust, or Tauri config errors.
3. Verify the editor can write engine/data/game_state.json.
4. Open engine/project.godot in Godot 4.x and verify Main.tscn loads dummy_level.json.
5. Verify the player CharacterBody2D falls, lands on StaticBody2D terrain, and moves left/right/jumps.
6. Verify enemies and collectibles spawn from sidecar metadata.
7. Update docs/PHASE1_STATUS.md with exact verification results.

Constraints:
- Keep the project one-person maintainable.
- Do not hide broken features behind TODO-only UI.
- Every runtime behavior must map back to a JSON contract field.
- If something is not implemented, mark it honestly as not implemented.
```
