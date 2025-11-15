# Custom Tileset Directory

This directory is reserved for your **custom-made tileset art**.

## Current Status

🚧 **Empty** - Using placeholder assets from `tilesets/placeholder/`

## When You Create Custom Assets

Place your custom tileset files here:

```
tilesets/custom/
├── terrain_atlas.png     # Your custom terrain tileset (32x32)
├── terrain_atlas.tres    # Godot TileSet resource
└── README.md             # This file
```

## How to Swap to Custom Assets

Once you've created your custom tileset:

1. Place `terrain_atlas.png` in this directory
2. Open `/Users/vigil-313/vitaverse/packages/godot-game/client/assets/asset_config.gd`
3. Change: `const USE_CUSTOM_ASSETS: bool = false`
4. To: `const USE_CUSTOM_ASSETS: bool = true`
5. Done! The game will now use your custom art

## Tileset Requirements

Your custom tileset must:
- Be 32x32 pixels per tile
- Follow the same tile ID mapping as placeholder
- PNG format with transparency support
- Organized in the same layout (or update TileSet resource)

## Creating Custom Assets

See `/Users/vigil-313/vitaverse/docs/ASSET_PIPELINE.md` for:
- Detailed creation guide
- Recommended tools
- Tile organization structure
- Export settings

## Tile Mapping Reference

Your custom tiles should map to these game tile types:
- Grass (TileType.GRASS)
- Water (TileType.WATER)
- Road Asphalt (TileType.ROAD_ASPHALT)
- Road Dirt (TileType.ROAD_DIRT)
- Wall Brick (TileType.WALL_BRICK)
- Wall Wood (TileType.WALL_WOOD)
- Floor Wood (TileType.FLOOR_WOOD)
- Tree Oak (TileType.TREE_OAK)
- Tree Pine (TileType.TREE_PINE)

See `shared/tile_definitions.gd` for the complete list.
