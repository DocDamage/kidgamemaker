# Git and GitHub Notes

Target Repository:
```text
https://github.com/DocDamage/kidgamemaker
```

The repository contains two active branches representing the core engine and its integrated components.

## Branch Strategy

- **`main`**: The stable branch containing the completed KidGameMaker zero-code engine, Svelte/Tauri editor frontend, Rust backend asset watcher/ingestor, and Godot 2D runner.
- **`sprite-editor`**: The branch housing the `realspriteeditor-cutter` codebase imported directly under the `sprite-editor/` folder. This is used for sprite sheet cutting, review UI, color variant exports, and rule generator scripts.

## Basic Operations

### Switching Branches

To switch between the core engine and sprite editor development workspace:

```powershell
# Switch to core engine
git checkout main

# Switch to sprite editor workspace
git checkout sprite-editor
```

### Pushing Changes

Ensure you push commits to their appropriate remote targets:

```powershell
# Pushing main core engine updates
git checkout main
git push origin main

# Pushing sprite-editor updates
git checkout sprite-editor
git push origin sprite-editor
```
