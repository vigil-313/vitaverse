# Custom Sprites Directory

This directory is reserved for your **custom-made character sprites**.

## Current Status

🚧 **Empty** - Using placeholder assets from `sprites/placeholder/`

## When You Create Custom Assets

Place your custom sprite files here:

```
sprites/custom/
├── player.png              # Your custom player sprite (32x32)
├── player_animations.tres  # Optional: animation resource
└── README.md               # This file
```

## How to Swap to Custom Assets

Once you've created your custom sprites:

1. Place `player.png` in this directory
2. Open `/Users/vigil-313/vitaverse/packages/godot-game/client/assets/asset_config.gd`
3. Change: `const USE_CUSTOM_ASSETS: bool = false`
4. To: `const USE_CUSTOM_ASSETS: bool = true`
5. Done! The game will now use your custom sprites

## Sprite Requirements

Your custom player sprite must:
- Be 32x32 pixels (or a sprite sheet with 32x32 frames)
- Top-down perspective (bird's eye view)
- PNG format with transparency
- Centered on the 32x32 grid

## Animation Sheet Format (Optional)

If you want animated movement:
- Create a sprite sheet
- Each row = direction (up, left, down, right)
- Each column = animation frame
- Common sizes: 96x128 (3 frames × 4 directions)

## Creating Custom Assets

See `/Users/vigil-313/vitaverse/docs/ASSET_PIPELINE.md` for:
- Character design guide
- Animation setup
- Recommended tools (Aseprite, Photoshop)
- Export settings

## Future Sprites

As you develop, you may want to add:
- NPCs
- AI agents
- Enemies
- Vehicles
- Props

All should follow the same 32x32 standard and be placed in this directory.
