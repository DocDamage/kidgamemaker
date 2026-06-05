import os
import json
from pathlib import Path
from PIL import Image

ASSETS_DIR = Path("engine/data/assets")

def is_cell_occupied(img, x, y, size):
    width, height = img.size
    pix = img.load()
    for cx in range(x, min(x + size, width)):
        for cy in range(y, min(y + size, height)):
            # Pixel might be RGBA or RGB
            rgba = pix[cx, cy]
            if len(rgba) == 4:
                if rgba[3] > 0:
                    return True
            else:
                # RGB - all pixels occupied
                return True
    return False

def detect_uniform_grid(img):
    width, height = img.size
    best_size = None
    best_score = 0.0
    
    for size in [16, 32, 48, 64]:
        if width % size == 0 and height % size == 0:
            if width == size and height == size:
                continue
            cols = width // size
            rows = height // size
            
            occupied_count = 0
            for r in range(rows):
                for c in range(cols):
                    if is_cell_occupied(img, c * size, r * size, size):
                        occupied_count += 1
                        
            if occupied_count > 1:
                score = occupied_count / (cols * rows)
                if score > best_score:
                    best_score = score
                    best_size = size
                    
    return best_size

def find_connected_components(img):
    width, height = img.size
    pix = img.load()
    
    visited = [[False] * height for _ in range(width)]
    components = []
    
    for x in range(width):
        for y in range(height):
            if visited[x][y]:
                continue
            
            # Check opacity
            rgba = pix[x, y]
            is_opaque = rgba[3] > 0 if len(rgba) == 4 else True
            if is_opaque:
                # BFS
                queue = [(x, y)]
                visited[x][y] = True
                
                min_x, max_x = x, x
                min_y, max_y = y, y
                
                while queue:
                    cx, cy = queue.pop(0)
                    min_x = min(min_x, cx)
                    max_x = max(max_x, cx)
                    min_y = min(min_y, cy)
                    max_y = max(max_y, cy)
                    
                    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < width and 0 <= ny < height:
                            if not visited[nx][ny]:
                                nrgba = pix[nx, ny]
                                nis_opaque = nrgba[3] > 0 if len(nrgba) == 4 else True
                                if nis_opaque:
                                    visited[nx][ny] = True
                                    queue.append((nx, ny))
                
                # Filter out extremely small components (noise)
                w = max_x - min_x + 1
                h = max_y - min_y + 1
                if w >= 4 and h >= 4:
                    components.append((min_x, min_y, w, h))
    return components

def humanize(name):
    parts = name.replace("-", "_").split("_")
    return " ".join(p.capitalize() for p in parts if p)

def slice_asset(sidecar_path):
    with open(sidecar_path, 'r', encoding='utf-8') as f:
        sidecar = json.load(f)
        
    category = sidecar.get("category", "")
    if category not in ["terrain", "decorations", "collectibles"]:
        return
        
    visual = sidecar.get("visual")
    if not visual:
        return
        
    img_path = sidecar_path.parent / visual
    if not img_path.exists():
        return
        
    try:
        img = Image.open(img_path)
    except Exception as e:
        print(f"Failed to open image {img_path}: {e}")
        return
        
    width, height = img.size
    
    # 1. Detect grid/frames
    best_grid = detect_uniform_grid(img)
    frames = []
    
    if best_grid:
        size = best_grid
        cols = width // size
        rows = height // size
        for r in range(rows):
            for c in range(cols):
                if is_cell_occupied(img, c * size, r * size, size):
                    frames.append((c * size, r * size, size, size))
    else:
        # Connected components fallback
        frames = find_connected_components(img)
        
    if len(frames) <= 1:
        # Not a spritesheet, or single component
        return
        
    asset_id = sidecar["asset_id"]
    asset_name = sidecar.get("asset_name", humanize(asset_id))
    template = sidecar.get("runtime_template", "decoration")
    snapping = sidecar.get("placement_logic", {}).get("snapping_type", "free_float")
    parallax = sidecar.get("placement_logic", {}).get("parallax_bucket", "play_layer")
    
    print(f"Slicing spritesheet '{asset_id}' into {len(frames)} tiles/stamps...")
    
    # Extract each frame
    for i, (fx, fy, fw, fh) in enumerate(frames):
        tile_asset_id = f"{asset_id}_tile_{i}"
        tile_filename = f"{tile_asset_id}.png"
        
        tile_dir = ASSETS_DIR / category / tile_asset_id
        tile_dir.mkdir(parents=True, exist_ok=True)
        
        # Crop frame and save
        cropped = img.crop((fx, fy, fx + fw, fy + fh))
        cropped.save(tile_dir / tile_filename)
        
        # Save sidecar
        tile_sidecar = {
            "schema_version": 1,
            "asset_id": tile_asset_id,
            "asset_name": f"{asset_name} Tile {i}",
            "category": category,
            "runtime_template": template,
            "visual": tile_filename,
            "visual_tags": sidecar.get("visual_tags", []) + ["tile", "slice"],
            "source_pack": sidecar.get("source_pack"),
            "source_author": sidecar.get("source_author"),
            "source_collection": sidecar.get("source_collection"),
            "is_spritesheet": False,
            "is_uniform_grid": False,
            "grid_cell_size": None,
            "slicing_confidence": 1.0,
            "frames": [
                { "x": 0, "y": 0, "w": fw, "h": fh }
            ],
            "placement_logic": {
                "snapping_type": snapping,
                "parallax_bucket": parallax
            },
            "collision": {
                "shape": "rectangle",
                "size": [fw, fh]
            }
        }
        
        with open(tile_dir / f"{tile_asset_id}.json", 'w', encoding='utf-8') as tf:
            json.dump(tile_sidecar, tf, indent=2)
            
    # Mark original spritesheet as spritesheet: true (hides it from the stamps ribbon)
    sidecar["is_spritesheet"] = True
    sidecar["frames"] = [{"x": fx, "y": fy, "w": fw, "h": fh} for (fx, fy, fw, fh) in frames]
    with open(sidecar_path, 'w', encoding='utf-8') as f:
        json.dump(sidecar, f, indent=2)

def main():
    print("Scanning asset inventory for unsliced spritesheets...")
    for category in ["terrain", "decorations", "collectibles"]:
        cat_dir = ASSETS_DIR / category
        if not cat_dir.exists():
            continue
        for asset_dir in cat_dir.iterdir():
            if not asset_dir.is_dir():
                continue
            # Check for sidecar JSON
            sidecar_path = asset_dir / f"{asset_dir.name}.json"
            if sidecar_path.exists():
                slice_asset(sidecar_path)
    print("Done! Sliced assets successfully.")

if __name__ == "__main__":
    main()
