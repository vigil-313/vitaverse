# World Importer

Python package for importing real-world data from OpenStreetMap into Vitaverse game format.

## Features

- ✅ Fetch data from OpenStreetMap (Overpass API)
- ✅ Convert OSM data to game tile format
- ✅ Generate chunks compatible with Godot server
- ✅ Command-line interface for easy imports
- ✅ Pre-configured Seattle import

## Installation

```bash
cd packages/world-importer
pip install -e .
```

Or from root directory:
```bash
pip install -e packages/world-importer
```

## Quick Start

### Import Seattle (Preset)

```bash
world-importer import-seattle
```

This imports the area from downtown Seattle to Amazon SLU offices.

### Import Custom Area

```bash
world-importer import-area --lat 47.6062 --lon -122.3321 --radius 5
```

Parameters:
- `--lat`: Center latitude
- `--lon`: Center longitude
- `--radius`: Radius in kilometers (default: 1.0)
- `--output`: Output directory (default: `../godot-game/server/data/world/chunks`)

### Check Coordinates

```bash
world-importer coords 47.6062 -122.3321
```

Shows world coordinates and chunk coordinates for a given lat/lon.

## Python API Usage

```python
from world_importer import OSMFetcher, TileConverter, ChunkWriter

# Fetch OSM data
fetcher = OSMFetcher()
osm_data = fetcher.fetch_area(
    lat=47.6062,
    lon=-122.3321,
    radius_km=2.0
)

# Convert to game chunks
converter = TileConverter()
chunks = converter.osm_to_chunks(osm_data)

# Write to disk
writer = ChunkWriter(output_dir="../godot-game/server/data/world/chunks")
writer.write_chunks(chunks)

print(f"Imported {len(chunks)} chunks!")
```

## How It Works

### 1. Fetching (OSMFetcher)

Queries OpenStreetMap Overpass API for:
- Buildings (`building=*`)
- Roads (`highway=*`)
- Natural features (`natural=*`)

### 2. Conversion (TileConverter)

- Converts lat/lon to world coordinates (Mercator projection)
- Maps OSM tags to game tile IDs
- Rasterizes ways (buildings, roads) into tiles
- Organizes tiles into 32×32 chunks

### 3. Writing (ChunkWriter)

- Saves chunks as JSON files
- Format matches Godot `Chunk.to_dict()` structure
- Files named: `chunk_X_Y.json`

## Tile Mapping

OSM features are mapped to game tiles:

| OSM Feature | Tile Type |
|-------------|-----------|
| `building=*` | Brick Wall |
| `highway:primary` | Asphalt Road |
| `highway:footway` | Sidewalk |
| `natural:tree` | Oak Tree |
| `natural:water` | Water |
| (default) | Grass |

## Configuration

### Custom Tile Mappings

Edit `world_importer/tile_converter.py`:

```python
OSM_TO_TILE = {
    "building:house": TileType.WALL_BRICK,
    "highway:motorway": TileType.ROAD_ASPHALT,
    # Add your custom mappings here
}
```

### Coordinate Reference

Pre-defined locations in `osm_fetcher.py`:

```python
SEATTLE_DOWNTOWN = {"lat": 47.6062, "lon": -122.3321}
AMAZON_SLU = {"lat": 47.6205, "lon": -122.3365}
```

## Development

### Running Tests

```bash
pytest tests/
```

### Code Formatting

```bash
black world_importer/
ruff check world_importer/
```

## Troubleshooting

### Overpass API Timeout

If queries timeout for large areas:
```python
fetcher = OSMFetcher(timeout=300)  # 5 minutes
```

### No Data Returned

- Check internet connection
- Verify coordinates are correct
- Try smaller radius
- Check Overpass API status: https://overpass-api.de/api/status

### Chunks Not Loading in Game

- Verify output directory matches server's chunk directory
- Check JSON format is valid
- Ensure chunk coordinates are reasonable (not too large)

## Examples

See `examples/` directory for:
- `import_seattle.py` - Import Seattle area
- `import_custom.py` - Import custom location
- `batch_import.py` - Import multiple areas

## Performance

| Area Size | Chunks | Time |
|-----------|--------|------|
| 1 km² | ~100 | ~30s |
| 5 km² | ~500 | ~2min |
| 10 km² | ~1000 | ~5min |

*Times approximate, depends on OSM data density and internet speed*

## Future Enhancements

- [ ] Support for more OSM features (amenities, shops, etc.)
- [ ] Better building interior generation
- [ ] Multi-level buildings
- [ ] Terrain elevation from SRTM data
- [ ] Batch import from GPX/KML files
- [ ] Caching of OSM data

## License

[To be determined]

## Credits

- OpenStreetMap contributors
- Overpy library for OSM API access
