# Vitaverse Asset Pipeline

This document describes how to create, manage, and swap visual assets in Vitaverse.

## Table of Contents

- [Overview](#overview)
- [Asset Strategy](#asset-strategy)
- [Directory Structure](#directory-structure)
- [Creating Custom Assets](#creating-custom-assets)
- [Swapping Assets](#swapping-assets)
- [Tile Specifications](#tile-specifications)
- [Tools & Resources](#tools--resources)

---

## Overview

Vitaverse uses a **dual-asset system**:

1. **Placeholder Assets** (LPC) - Free, high-quality assets for development
2. **Custom Assets** (Future) - Your original art to make Vitaverse unique

The system is designed so you can **swap placeholder → custom with a single line change**.

---

## Asset Strategy

### Current Phase: Placeholder Assets

**What we're using:**
- **LPC Tile Atlas** - CC-BY-SA licensed terrain tileset (32x32)
- **LPC Character Sprites** - CC-BY-SA licensed characters (32x32)

**Why LPC:**
- ✅ Professional quality
- ✅ Complete (terrain, buildings, characters, objects)
- ✅ Well-organized and documented
- ✅ Free to use (with attribution)
- ✅ Industry-standard format

### Future Phase: Custom Assets

**When ready:**
1. Create your own 32x32 pixel art
2. Follow the same organizational structure as LPC
3. Place in `custom/` directories
4. Change one flag in `asset_config.gd`
5. Done!

**Why create custom:**
- 🎨 Unique visual identity
- 🏙️ Seattle-specific architecture
- 📜 No attribution requirements
- 🚀 Complete creative control

---

## Directory Structure

```
packages/godot-game/client/assets/
├── asset_config.gd           # SINGLE SOURCE OF TRUTH for asset paths
├── README.md                 # Asset overview
│
├── tilesets/
│   ├── placeholder/          # LPC tilesets (current)
│   │   ├── terrain_atlas.png      # 32x32 terrain tiles
│   │   ├── terrain_atlas.png.import
│   │   ├── terrain_atlas.tres     # Godot TileSet resource
│   │   └── DOWNLOAD_INSTRUCTIONS.md
│   └── custom/               # Your custom tilesets (future)
│       ├── terrain_atlas.png      # (create this)
│       ├── terrain_atlas.tres     # (create this)
│       └── README.md
│
└── sprites/
    ├── placeholder/          # LPC sprites (current)
    │   ├── player.png             # 32x32 character sprite
    │   ├── player.png.import
    │   └── DOWNLOAD_INSTRUCTIONS.md
    └── custom/               # Your custom sprites (future)
        ├── player.png             # (create this)
        └── README.md
```

---

## Creating Custom Assets

### Prerequisites

**Tools You'll Need:**
- **Aseprite** (recommended, $20) - Professional pixel art editor
- **Photoshop/GIMP** - General image editors
- **Procreate** (iPad) - Touch-based pixel art
- **Piskel** (free, web) - Simple online pixel art tool

**Skills:**
- Basic pixel art techniques
- Understanding of top-down perspective
- Color theory (optional but helpful)

### Tile Specifications

#### Terrain Tileset

**Format:**
- **File:** `terrain_atlas.png`
- **Tile Size:** 32x32 pixels
- **Format:** PNG with alpha transparency
- **Color:** 8-bit RGBA
- **Grid:** Multiple tiles in a grid layout

**Required Tiles** (minimum set):

Based on `shared/world/tile_definitions.gd`:

| Tile ID | Tile Type | Description | Usage |
|---------|-----------|-------------|-------|
| 0 | VOID | Empty/black | Unloaded chunks |
| 1 | GRASS | Green grass | Default terrain |
| 2 | DIRT | Brown dirt | Paths, cleared land |
| 3 | STONE | Gray stone | Rocky areas |
| 4 | SAND | Tan/yellow sand | Beaches |
| 5 | WATER | Blue water | Rivers, lakes |
| 6 | WATER_DEEP | Dark blue | Deep water |
| 51 | TREE_OAK | Large tree | Forests |
| 52 | TREE_PINE | Pine tree | Forests |
| 53 | BUSH | Small bush | Decoration |
| 101 | ROAD_ASPHALT | Black road | City streets |
| 102 | ROAD_CONCRETE | Gray road | Sidewalks |
| 103 | SIDEWALK | Light gray | Pedestrian paths |
| 104 | PATH_DIRT | Brown path | Trails |
| 151 | WALL_WOOD | Wood planks | Building walls |
| 152 | WALL_BRICK | Red brick | Building walls |
| 153 | WALL_CONCRETE | Gray concrete | Modern buildings |
| 154 | WALL_GLASS | Blue/clear | Windows |
| 201 | FLOOR_WOOD | Wood floor | Interior floors |
| 202 | FLOOR_TILE | Checkered | Interior floors |

See `tile_definitions.gd` for the complete list.

**Tile Organization:**

Option 1: **Linear Atlas** (simple)
```
Row 1: Terrain (grass, dirt, stone, sand, water...)
Row 2: Vegetation (trees, bushes, flowers...)
Row 3: Roads (asphalt, concrete, sidewalk...)
Row 4: Buildings (walls, floors, roofs...)
```

Option 2: **Categorized Atlas** (LPC style)
```
Multiple rows per category with variations:
- Grass: normal, tall, dry, wet
- Roads: straight, corners, intersections
- Buildings: walls at different angles
```

**Export Settings:**
- No anti-aliasing
- No compression
- Nearest-neighbor scaling only
- Save for Web (PNG-8 or PNG-24)

#### Character Sprite

**Format:**
- **File:** `player.png`
- **Sprite Size:** 32x32 pixels per frame
- **Perspective:** Top-down (bird's eye view)
- **Format:** PNG with alpha transparency

**Animation Sheet** (optional but recommended):

```
     Frame 1  Frame 2  Frame 3  ... Frame 9
Row 1: [UP walk animation across 9 frames]
Row 2: [LEFT walk animation across 9 frames]
Row 3: [DOWN walk animation across 9 frames]
Row 4: [RIGHT walk animation across 9 frames]
```

**Total:** 9 columns × 4 rows = 36 frames

**Static Sprite** (minimal):
- Just one 32x32 image
- Player won't animate but will be visible
- Good for quick testing

**Godot Configuration:**
```gdscript
# In Godot Inspector for Sprite2D:
Hframes: 9   # 9 frames per row
Vframes: 4   # 4 rows (directions)
Frame: 0     # Current frame to display
```

### Step-by-Step: Creating a Custom Tileset

#### 1. Set Up Your Canvas

1. Open Aseprite (or your pixel art tool)
2. Create new sprite:
   - **Width:** 288 pixels (9 tiles × 32px) or more
   - **Height:** 288 pixels (9 rows × 32px) or more
   - **Color Mode:** RGBA
3. Enable grid:
   - **Grid Size:** 32×32
   - **Grid Color:** Visible color (red/yellow)

#### 2. Reference the LPC Atlas

1. Open `placeholder/terrain_atlas.png` as reference
2. Study the organization and style
3. Note which tiles correspond to which types

#### 3. Create Your Tiles

For each tile type (GRASS, WATER, ROAD, etc.):

1. **Sketch** the tile in pencil/light color
2. **Refine** the outlines
3. **Color** using a limited palette (8-16 colors recommended)
4. **Shade** with 2-3 shades per color
5. **Polish** edges and details

**Tips:**
- Keep it simple - 32x32 is small!
- Use dithering sparingly
- Ensure tiles are seamless (if they should be)
- Test in-game frequently

#### 4. Organize the Atlas

Arrange tiles in a grid matching the tile IDs:

```
Tile 0 (VOID)      at position (0, 0)
Tile 1 (GRASS)     at position (32, 0) or (0, 32)
Tile 2 (DIRT)      at position (64, 0) or (32, 32)
... etc
```

Create a mapping document:
```
Tile ID → Atlas Position
1 (GRASS) → Row 0, Col 1
5 (WATER) → Row 0, Col 5
101 (ROAD) → Row 3, Col 5
```

#### 5. Export

1. **Hide the grid layer**
2. **Export as PNG**:
   - No scaling
   - No filters
   - Full quality
3. Save as: `custom/terrain_atlas.png`

#### 6. Import to Godot

1. Open Godot
2. The PNG auto-imports
3. Create TileSet resource (see GODOT_SETUP_GUIDE.md)
4. Map tiles to IDs

---

## Swapping Assets

### The One-Line Swap

All asset paths are controlled by `/packages/godot-game/client/assets/asset_config.gd`:

```gdscript
## Asset Mode Configuration
## Set to true to use custom assets, false to use placeholders
const USE_CUSTOM_ASSETS: bool = false  # ← Change this line
```

**To swap to custom assets:**

1. Ensure your custom assets exist:
   ```
   custom/terrain_atlas.png ✅
   custom/terrain_atlas.tres ✅
   custom/player.png ✅
   ```

2. Open `asset_config.gd`

3. Change:
   ```gdscript
   const USE_CUSTOM_ASSETS: bool = false
   ```
   To:
   ```gdscript
   const USE_CUSTOM_ASSETS: bool = true
   ```

4. Save and reload Godot

5. **Done!** All references now point to custom assets

### Progressive Swapping

You don't have to swap everything at once:

**Week 1:** Create custom grass & water
- Replace just those tiles in the atlas
- Keep roads/buildings as LPC

**Week 2:** Create custom roads
- Replace road tiles
- Keep buildings as LPC

**Week 3:** Create custom buildings
- Replace building tiles
- Now 100% custom!

Just keep the same tile ID mapping and update the PNG incrementally.

---

## Tile Mapping Reference

When creating custom assets, maintain this ID mapping:

### Terrain

| ID Range | Category | Examples |
|----------|----------|----------|
| 1-50 | Natural Terrain | Grass, Dirt, Stone, Sand, Water |

### Vegetation

| ID Range | Category | Examples |
|----------|----------|----------|
| 51-100 | Plants & Trees | Oak, Pine, Bush, Flowers |

### Urban

| ID Range | Category | Examples |
|----------|----------|----------|
| 101-150 | Roads & Paths | Asphalt, Concrete, Sidewalk |
| 151-200 | Building Walls | Wood, Brick, Concrete, Glass |
| 201-250 | Building Floors | Wood, Tile, Carpet |
| 251-300 | Building Roofs | Shingle, Metal, Flat |

### Objects

| ID Range | Category | Examples |
|----------|----------|----------|
| 301-400 | Furniture | Desk, Chair, Bed, Table |

### Special

| ID Range | Category | Examples |
|----------|----------|----------|
| 901-999 | Markers | Spawn points, Landmarks |

**Full list:** See `/packages/godot-game/shared/world/tile_definitions.gd`

---

## Tools & Resources

### Recommended Tools

#### Pixel Art Editors

1. **Aseprite** ($19.99) - https://www.aseprite.org/
   - Industry standard for pixel art
   - Animation support
   - Onion skinning, layers, palettes
   - **Best choice for Vitaverse**

2. **Piskel** (Free) - https://www.piskelapp.com/
   - Web-based
   - Simple and clean
   - Good for beginners

3. **GraphicsGale** (Free) - https://graphicsgale.com/
   - Windows only
   - Powerful animation tools

4. **Photoshop** (Subscription)
   - Turn off anti-aliasing
   - Use pencil tool
   - Can work but not optimized for pixel art

#### Color Palette Tools

1. **Lospec** - https://lospec.com/palette-list
   - Huge collection of pixel art palettes
   - Filter by number of colors
   - Export to any format

2. **Coolors** - https://coolors.co/
   - Generate color schemes
   - Adjust palettes

### Learning Resources

#### Pixel Art Tutorials

1. **Pedro Medeiros** - https://blog.studiominiboss.com/pixelart
   - Excellent pixel art fundamentals
   - Free tutorials

2. **Pixel Logic** - https://pixellogic.tumblr.com/
   - Advanced techniques
   - Animation guides

3. **MortMort** - https://www.youtube.com/c/MortMort
   - Video tutorials
   - Beginner-friendly

#### Top-Down Perspective

1. Search: "top down pixel art tutorial"
2. Study existing games:
   - Stardew Valley
   - Enter the Gungeon
   - Hyper Light Drifter

### Reference Assets

#### For Inspiration (Don't Copy!)

1. **LPC Assets** - https://opengameart.org/
   - Study the organization
   - Learn the style
   - Use as reference only

2. **Kenney Assets** - https://kenney.nl/
   - Clean, professional style
   - Study color choices

3. **Real Photos**
   - Google Maps (for Seattle architecture)
   - Street photography
   - Extract colors and shapes

---

## Workflow Example

### Creating Custom Seattle Tileset

**Goal:** Replace placeholder tiles with Seattle-specific art

**Week 1: Planning**
1. Screenshot Seattle buildings from Google Maps
2. Identify common architectural styles:
   - Pioneer Square brick buildings
   - Modern glass towers
   - Pike Place Market style
3. Create color palette from photos
4. Sketch concepts

**Week 2: Terrain**
1. Create grass variants (Pacific Northwest green)
2. Create water (Puget Sound blue-green)
3. Create roads (dark asphalt, Seattle-style concrete)
4. Import and test

**Week 3: Buildings**
1. Create brick walls (red/brown Pioneer Square style)
2. Create glass walls (modern downtown style)
3. Create wood walls (Pike Place style)
4. Import and test

**Week 4: Polish**
1. Add shadows
2. Add variations
3. Test in-game with Seattle OSM data
4. Adjust colors for cohesion

**Week 5: Swap**
1. Set `USE_CUSTOM_ASSETS = true`
2. Celebrate your unique Seattle!

---

## Attribution

### While Using Placeholder Assets

Include in your credits/README:

```
Visual Assets:
- Terrain and character sprites from Liberated Pixel Cup (LPC)
- License: CC-BY-SA 3.0
- Source: OpenGameArt.org
- Contributors: (see LPC documentation)
```

### After Creating Custom Assets

Replace with:

```
Visual Assets:
- Original pixel art created for Vitaverse
- © [Your Name/Studio]
- All rights reserved
```

---

## FAQ

**Q: Can I mix LPC and custom assets?**
A: Yes! You can replace individual tiles while keeping others as LPC. Just update your tileset PNG incrementally.

**Q: What if I can't do pixel art?**
A: Options:
1. Hire a pixel artist (itch.io, Fiverr, r/gameDevClassifieds)
2. Use AI generation + manual pixel cleanup
3. Commission from the community
4. Keep using LPC (it's good!)

**Q: Do I have to use 32x32?**
A: Technically you could change to 16x16 or 64x64, but you'd need to update `TILE_SIZE` in `world_constants.gd` and regenerate all worlds. Stick with 32x32.

**Q: Can I sell Vitaverse with LPC assets?**
A: Yes, but you must:
1. Provide attribution (CC-BY-SA)
2. License your derivative art as CC-BY-SA too
3. Better to create custom assets for commercial projects

**Q: How long does it take to create a full custom tileset?**
A: Depends on skill and detail:
- Minimal set (20 tiles): 10-20 hours
- Complete set (100+ tiles): 40-100 hours
- Professional quality: 100-200+ hours

**Q: What resolution should I work at?**
A: Work at 1x scale (32x32 pixels). Do NOT upscale and work larger - you'll lose the pixel art aesthetic.

---

## Next Steps

1. **Get comfortable with placeholders** - Build your game mechanics first
2. **Plan your custom style** - Mood boards, color palettes, concepts
3. **Start small** - Replace 5-10 tiles as a test
4. **Get feedback** - Show your art to players
5. **Iterate** - Refine based on feedback
6. **Expand** - Gradually replace all assets
7. **Swap** - One line change to go live!

---

**Questions?** Check the main Vitaverse documentation or ask in the community.
