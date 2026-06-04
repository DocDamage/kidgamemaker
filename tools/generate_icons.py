import os
from PIL import Image, ImageDraw

icons_dir = "editor/src-tauri/icons"
os.makedirs(icons_dir, exist_ok=True)

base_size = 1024
img = Image.new("RGBA", (base_size, base_size), color=(16, 24, 39, 255))
draw = ImageDraw.Draw(img)
draw.ellipse([256, 256, 768, 768], fill=(255, 216, 77, 255))
draw.ellipse([350, 350, 444, 444], fill=(16, 24, 39, 255))
draw.ellipse([580, 350, 674, 444], fill=(16, 24, 39, 255))
draw.arc([350, 430, 674, 710], 15, 165, fill=(16, 24, 39, 255), width=42)

img.resize((32, 32)).save(os.path.join(icons_dir, "32x32.png"))
img.resize((128, 128)).save(os.path.join(icons_dir, "128x128.png"))
img.resize((256, 256)).save(os.path.join(icons_dir, "128x128@2x.png"))

img.resize((32, 32)).save(os.path.join(icons_dir, "icon.ico"), format="ICO")
img.save(os.path.join(icons_dir, "icon.icns"), format="ICNS")

print("Generated application icons successfully.")
