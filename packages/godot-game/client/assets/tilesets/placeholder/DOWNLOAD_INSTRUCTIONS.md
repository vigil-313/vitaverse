# Download LPC Tile Atlas (Placeholder Tileset)

## What to Download

**LPC Tile Atlas** - A comprehensive 32x32 tileset perfect for city environments

## Where to Download

**Primary Source:**
- URL: https://opengameart.org/content/lpc-tile-atlas
- OR: https://opengameart.org/content/lpc-terrain-repack
- License: CC-BY-SA 3.0

## What You Need

Look for files containing:
- `terrain` or `atlas` in the name
- 32x32 pixel tiles
- PNG format
- Includes: grass, water, roads, dirt, sand, etc.

## Files to Place Here

After downloading and extracting, place these files in this directory:

1. **Main terrain tileset PNG** (name it `terrain_atlas.png`)
   - This is the source image with all the tiles
   - Usually called something like `lpc-terrains.png` or `terrain-atlas.png`

2. Any other terrain variants you want to use

## Expected Result

```
tilesets/placeholder/
├── DOWNLOAD_INSTRUCTIONS.md  (this file)
├── terrain_atlas.png          (the main tileset - YOU DOWNLOAD THIS)
└── terrain_atlas.tres         (created later by Godot)
```

## Next Steps

After placing the PNG file here:
1. Open Godot
2. The PNG will auto-import
3. We'll create a TileSet resource from it
4. Map tiles to game tile types

## Quick Download Steps

1. Go to: https://opengameart.org/content/lpc-tile-atlas
2. Click "Download" button
3. Extract the ZIP file
4. Find the terrain/ground PNG file (usually the largest one)
5. Rename it to `terrain_atlas.png`
6. Copy it to THIS directory
7. Done! Return to the terminal and let me know
