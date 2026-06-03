import os
from PIL import Image, ImageDraw

icons_dir = "editor/src-tauri/icons"
os.makedirs(icons_dir, exist_ok=True)

# Create a 128x128 template image
img = Image.new("RGBA", (128, 128), color=(16, 24, 39, 255))
draw = ImageDraw.Draw(img)
# Draw a cute circle logo
draw.ellipse([32, 32, 96, 96], fill=(255, 216, 77, 255))

# Save the various png resolutions
img.resize((32, 32)).save(os.path.join(icons_dir, "32x32.png"))
img.resize((128, 128)).save(os.path.join(icons_dir, "128x128.png"))
img.resize((256, 256)).save(os.path.join(icons_dir, "128x128@2x.png"))

# Save the .ico file
img.resize((32, 32)).save(os.path.join(icons_dir, "icon.ico"), format="ICO")

# Create a dummy .icns file
with open(os.path.join(icons_dir, "icon.icns"), "wb") as f:
    f.write(b"")

print("Generated dummy icons successfully.")
