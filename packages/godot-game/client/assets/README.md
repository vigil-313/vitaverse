# Vitaverse Assets

This directory contains all visual assets for the Vitaverse client.

## Directory Structure

```
assets/
├── tilesets/
│   ├── placeholder/    # LPC Tile Atlas (temporary, easy to swap)
│   └── custom/         # Your future custom tileset art
├── sprites/
│   ├── placeholder/    # LPC character sprites (temporary)
│   └── custom/         # Your future custom character art
└── README.md           # This file
```

## Asset Swapping Strategy

This project is designed for **easy asset replacement**:

1. **Current Phase**: Use LPC (Liberated Pixel Cup) assets as placeholders
2. **Future Phase**: Create custom art following the same structure
3. **Swap Method**: Update `asset_config.gd` to switch between placeholder/custom

## Current Assets (Placeholder)

### Tilesets
- **Source**: LPC Tile Atlas from OpenGameArt.org
- **License**: CC-BY-SA 3.0 (requires attribution)
- **Size**: 32x32 pixels per tile
- **Usage**: Temporary placeholder until custom art is created

### Sprites
- **Source**: LPC Character sprites
- **License**: CC-BY-SA 3.0 (requires attribution)
- **Size**: 32x32 pixels
- **Usage**: Temporary placeholder until custom art is created

## Creating Custom Assets

See `docs/ASSET_PIPELINE.md` for detailed instructions on:
- Creating custom tilesets
- Tile organization structure
- How to swap placeholder → custom
- Recommended tools (Aseprite, Photoshop, etc.)

## Tile Specifications

- **Tile Size**: 32x32 pixels
- **Format**: PNG with transparency
- **Color Depth**: 8-bit RGBA
- **Import Settings**: No filter (pixel art), no mipmaps

## Attribution (Placeholder Assets)

While using LPC placeholder assets, attribution is required:

```
Art assets from Liberated Pixel Cup (LPC)
Created by: [Various contributors - see LPC documentation]
License: CC-BY-SA 3.0
Source: OpenGameArt.org
```

This attribution will be removed once custom assets replace the placeholders.
