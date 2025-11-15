# World Building Guide

Guide for creating and managing world content in Vitaverse.

## Overview

Vitaverse supports three methods for building your world:
1. **OSM Import** - Import real-world cities from OpenStreetMap
2. **Procedural Generation** - Let the server generate terrain
3. **Manual Editing** - Build by hand (future feature)

## Method 1: OSM Import (Recommended)

### Import Seattle

```bash
# Quick preset
./scripts/import_seattle.sh

# Or manually
cd packages/world-importer
world-importer import-seattle
```

This imports the area from downtown Seattle to Amazon SLU.

### Import Custom Location

```bash
world-importer import-area --lat 47.6062 --lon -122.3321 --radius 5
```

Parameters:
- `--lat`: Center latitude
- `--lon`: Center longitude
- `--radius`: Radius in kilometers

### How It Works

1. Fetches building, road, and natural feature data from OpenStreetMap
2. Converts lat/lon to world coordinates
3. Maps OSM features to game tiles:
   - Buildings → Brick walls
   - Roads → Asphalt
   - Trees → Oak trees
   - Default → Grass
4. Saves as chunk files in `server/data/world/chunks/`

## Method 2: Procedural Generation

The server automatically generates basic terrain for any requested chunk that doesn't exist.

**Current Algorithm** (in `chunk_manager.gd`):
- Base: Grass tiles
- 5% chance: Oak tree
- 10% chance: Bush

**Future**: Will support perlin noise, biomes, elevation, etc.

## Method 3: Manual Editing

**Status**: Not yet implemented (planned for Phase 2)

**Planned Features**:
- Press `E` to toggle editor mode
- Click tiles to place/remove
- Tile picker UI
- Undo/redo
- Save directly to server

## Tile Types

See `shared/world/tile_definitions.gd` for complete list.

### Natural Terrain
| ID | Name | Walkable |
|----|------|----------|
| 1 | Grass | Yes |
| 2 | Dirt | Yes |
| 5 | Water | No |

### Vegetation
| ID | Name | Walkable |
|----|------|----------|
| 51 | Oak Tree | No |
| 52 | Pine Tree | No |
| 53 | Bush | Yes |

### Roads
| ID | Name | Walkable |
|----|------|----------|
| 101 | Asphalt Road | Yes |
| 103 | Sidewalk | Yes |

### Buildings
| ID | Name | Walkable |
|----|------|----------|
| 151 | Wooden Wall | No |
| 152 | Brick Wall | No |
| 201 | Wooden Floor | Yes |

## Adding Custom Tiles

1. **Add to tile enum** in `shared/world/tile_definitions.gd`:
```gdscript
enum TileType {
    ...
    MY_NEW_TILE = 999,
}
```

2. **Add properties**:
```gdscript
tile_properties[TileType.MY_NEW_TILE] = TileProperties.new(
    TileType.MY_NEW_TILE, "My Tile", true, true
)
```

3. **Add to OSM mapping** (if importing):
```python
# In world_importer/tile_converter.py
OSM_TO_TILE = {
    ...
    "building:custom": TileType.MY_NEW_TILE,
}
```

4. **Add to tileset** (when you create visual assets)

## World Coordinates

### Understanding the Coordinate System

```
World Position (pixels) → Chunk Coordinates
(1024, 512) → Chunk (32, 16)

Chunk Coordinates → World Position (top-left)
Chunk (32, 16) → (1024, 512)
```

### Useful Commands

```bash
# Get chunk coordinates for a location
world-importer coords 47.6062 -122.3321
```

## Data Storage

Chunks are stored as JSON files:

```
server/data/world/chunks/
├── chunk_0_0.json      (Spawn area)
├── chunk_0_1.json
├── chunk_1_0.json
└── ...
```

### Chunk File Format

```json
{
  "chunk_x": 0,
  "chunk_y": 0,
  "tiles": [1, 1, 1, ...],  // 1024 tile IDs
  "created_at": 1700000000,
  "modified_at": 1700000100,
  "name": "Optional chunk name"
}
```

## Performance Considerations

- **1 chunk** = 32×32 tiles = 1024 pixels × 1024 pixels
- **1 km²** ≈ 100 chunks (roughly)
- **Seattle downtown** (2km radius) ≈ 500-1000 chunks
- **File size**: ~4-8KB per chunk (JSON)

## Backup Your World

```bash
# Backup chunks
tar -czf world-backup.tar.gz packages/godot-game/server/data/world/

# Restore
tar -xzf world-backup.tar.gz
```

## Troubleshooting

### OSM Import Returns No Data

- Check internet connection
- Verify coordinates are correct
- Try smaller radius
- Check Overpass API status: https://overpass-api.de/api/status

### Chunks Not Loading in Game

- Verify files exist in `server/data/world/chunks/`
- Check file permissions
- Check server console for errors
- Ensure JSON is valid

### World Looks Wrong

- OSM data quality varies by location
- Try different tile mappings in `tile_converter.py`
- Consider manual refinement after import

## Future Features

- [ ] In-game editor mode
- [ ] Collaborative editing
- [ ] Version control for worlds
- [ ] Import from other sources (GPX, KML)
- [ ] Terrain elevation from SRTM
- [ ] Building interiors
- [ ] Multi-level structures

---

**Last Updated**: 2025-11-15
