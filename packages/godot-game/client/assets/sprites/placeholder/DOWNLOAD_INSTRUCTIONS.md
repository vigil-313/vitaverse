# Download LPC Character Sprites (Placeholder)

## What to Download

**LPC Character Sprites** - 32x32 character sprites compatible with LPC tileset

## Where to Download

**Option 1: Simple Character (Recommended for now)**
- URL: https://opengameart.org/content/lpc-character-bases
- License: CC-BY-SA 3.0 / GPL 3.0

**Option 2: Pre-made Characters**
- Search OpenGameArt for "LPC character"
- Many pre-made characters available
- All are 32x32 and compatible

**Option 3: Quick Placeholder**
- Use any 32x32 top-down character sprite
- We just need something visible for testing
- Can replace later

## What You Need

A character sprite that has:
- 32x32 pixel size
- Top-down perspective (bird's eye view)
- Ideally: walking animations in 4 directions (optional for now)
- PNG format with transparency

## Files to Place Here

After downloading, place these files in this directory:

1. **player.png** - Main character sprite
   - Can be a single 32x32 image (static)
   - Or a sprite sheet with animations (we'll configure later)

## Expected Result

```
sprites/placeholder/
├── DOWNLOAD_INSTRUCTIONS.md   (this file)
├── player.png                 (the player sprite - YOU DOWNLOAD THIS)
└── player_animations.tres     (created later if needed)
```

## Minimal Placeholder Option

If you want to get running FAST, you can:
1. Create a simple 32x32 colored square in any image editor
2. Save it as `player.png`
3. We'll use proper sprites later

## Quick Download Steps

1. Go to: https://opengameart.org/content/lpc-character-bases
2. Download any character that looks good
3. Extract and find the character PNG
4. Rename to `player.png`
5. Copy to THIS directory
6. Done! Return to the terminal

## For Later: Animation Sheets

If you download an animated character sprite sheet:
- It will usually be organized in rows (up, left, down, right)
- Each row is a direction
- Each column is a frame of animation
- We can configure this in Godot later
