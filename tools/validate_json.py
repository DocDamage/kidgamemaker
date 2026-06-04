import os
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []

exclude_dirs = {'node_modules', 'target', 'target_custom', '.svelte-kit', 'dist'}

for dirpath, dirnames, filenames in os.walk(ROOT):
    # Modify dirnames in-place to prevent os.walk from recursing into excluded directories
    dirnames[:] = [d for d in dirnames if d not in exclude_dirs]
    
    for filename in filenames:
        if filename.endswith('.json'):
            path = Path(dirpath) / filename
            try:
                json.loads(path.read_text(encoding='utf-8'))
            except (OSError, UnicodeError, json.JSONDecodeError) as exc:
                errors.append(f'{path.relative_to(ROOT)}: {exc}')

if errors:
    print('JSON validation failed:')
    for error in errors:
        print(f' - {error}')
    sys.exit(1)

print('All JSON files parsed successfully.')
