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

The runner currently uses generated placeholder shapes instead of real art. Texture loading comes next.
