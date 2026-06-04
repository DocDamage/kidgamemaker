# KidGameMaker Godot Runner

Open this folder as a Godot 4.x project.

`project.godot` runs `scenes/Main.tscn`, which attaches `scripts/Main.gd`.

Default level path:

```text
res://data/dummy_level.json
```

Runtime override:

```powershell
Runner.exe --level-json C:\path\to\game_state.json
```

The runner loads authored asset visuals from `engine/data/assets`; generated fallback shapes are used only when an entity has no loadable visual.
