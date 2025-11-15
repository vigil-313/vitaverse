"""
Tile converter

Converts OpenStreetMap data to Vitaverse tile format.
"""

from typing import Dict, List, Any, Tuple
import math


# Tile type IDs (must match shared/world/tile_definitions.gd in Godot project)
class TileType:
    VOID = 0
    GRASS = 1
    DIRT = 2
    STONE = 3
    SAND = 4
    WATER = 5
    TREE_OAK = 51
    TREE_PINE = 52
    ROAD_ASPHALT = 101
    SIDEWALK = 103
    WALL_BRICK = 152


# Mapping from OSM tags to game tile types
OSM_TO_TILE = {
    # Buildings
    "building": TileType.WALL_BRICK,
    "building:house": TileType.WALL_BRICK,
    "building:commercial": TileType.WALL_BRICK,
    # Roads
    "highway:primary": TileType.ROAD_ASPHALT,
    "highway:secondary": TileType.ROAD_ASPHALT,
    "highway:residential": TileType.ROAD_ASPHALT,
    "highway:footway": TileType.SIDEWALK,
    "highway:path": TileType.SIDEWALK,
    # Natural
    "natural:tree": TileType.TREE_OAK,
    "natural:wood": TileType.TREE_PINE,
    "natural:water": TileType.WATER,
    "natural:grassland": TileType.GRASS,
}


class TileConverter:
    """Converts OSM data to game tile format"""

    def __init__(self, tile_size: int = 32, chunk_size: int = 32):
        """
        Initialize converter

        Args:
            tile_size: Size of each tile in pixels
            chunk_size: Number of tiles per chunk (width/height)
        """
        self.tile_size = tile_size
        self.chunk_size = chunk_size
        self.chunk_pixel_size = tile_size * chunk_size

    def latlon_to_world(self, lat: float, lon: float, center_lat: float, center_lon: float) -> Tuple[float, float]:
        """
        Convert lat/lon to world coordinates (pixels)

        Uses simple Mercator projection
        Args:
            lat: Latitude
            lon: Longitude
            center_lat: Center latitude (origin)
            center_lon: Center longitude (origin)

        Returns:
            (world_x, world_y) in pixels
        """
        # Approximate meters per degree at this latitude
        meters_per_lat = 111000
        meters_per_lon = 111000 * math.cos(math.radians(center_lat))

        # Convert to meters from center
        delta_lat = lat - center_lat
        delta_lon = lon - center_lon

        meters_x = delta_lon * meters_per_lon
        meters_y = -delta_lat * meters_per_lat  # Negative because north is up

        # Convert meters to pixels (1 meter = 1 pixel for now)
        world_x = meters_x
        world_y = meters_y

        return (world_x, world_y)

    def world_to_chunk(self, world_x: float, world_y: float) -> Tuple[int, int]:
        """Convert world coordinates to chunk coordinates"""
        chunk_x = int(math.floor(world_x / self.chunk_pixel_size))
        chunk_y = int(math.floor(world_y / self.chunk_pixel_size))
        return (chunk_x, chunk_y)

    def osm_to_chunks(self, osm_data: Dict[str, Any]) -> Dict[Tuple[int, int], List[List[int]]]:
        """
        Convert OSM data to chunk format

        Args:
            osm_data: OSM data from OSMFetcher

        Returns:
            Dictionary mapping (chunk_x, chunk_y) to 2D tile array
        """
        center_lat = osm_data["center"]["lat"]
        center_lon = osm_data["center"]["lon"]

        chunks: Dict[Tuple[int, int], List[List[int]]] = {}

        # Initialize chunks with grass
        # We'll determine bounds first
        min_chunk_x, min_chunk_y = float('inf'), float('inf')
        max_chunk_x, max_chunk_y = float('-inf'), float('-inf')

        # Process ways (buildings, roads, etc.)
        for way in osm_data.get("ways", []):
            self._process_way(way, center_lat, center_lon, chunks)

            # Update bounds
            for node in way.nodes:
                world_x, world_y = self.latlon_to_world(
                    float(node.lat), float(node.lon), center_lat, center_lon
                )
                chunk_x, chunk_y = self.world_to_chunk(world_x, world_y)
                min_chunk_x = min(min_chunk_x, chunk_x)
                min_chunk_y = min(min_chunk_y, chunk_y)
                max_chunk_x = max(max_chunk_x, chunk_x)
                max_chunk_y = max(max_chunk_y, chunk_y)

        # Process nodes (individual trees, etc.)
        for node in osm_data.get("nodes", []):
            self._process_node(node, center_lat, center_lon, chunks)

        print(f"[TileConverter] Converted to {len(chunks)} chunks")
        return chunks

    def _process_way(self, way, center_lat: float, center_lon: float, chunks: Dict):
        """Process an OSM way (building, road, etc.)"""
        # Determine tile type from tags
        tile_id = self._get_tile_from_tags(way.tags)

        if tile_id == TileType.VOID:
            return  # Skip unknown types

        # Convert all nodes to world coordinates
        points = []
        for node in way.nodes:
            world_x, world_y = self.latlon_to_world(
                float(node.lat), float(node.lon), center_lat, center_lon
            )
            points.append((world_x, world_y))

        # Rasterize the way (fill the area)
        for i in range(len(points) - 1):
            self._draw_line(points[i], points[i + 1], tile_id, chunks)

    def _process_node(self, node, center_lat: float, center_lon: float, chunks: Dict):
        """Process an OSM node (tree, etc.)"""
        tile_id = self._get_tile_from_tags(node.tags)

        if tile_id == TileType.VOID:
            return

        world_x, world_y = self.latlon_to_world(
            float(node.lat), float(node.lon), center_lat, center_lon
        )

        self._set_tile(world_x, world_y, tile_id, chunks)

    def _get_tile_from_tags(self, tags: Dict[str, str]) -> int:
        """Get game tile ID from OSM tags"""
        for key, value in tags.items():
            tag_str = f"{key}:{value}"
            if tag_str in OSM_TO_TILE:
                return OSM_TO_TILE[tag_str]

            # Try just the key
            if key in OSM_TO_TILE:
                return OSM_TO_TILE[key]

        return TileType.VOID

    def _set_tile(self, world_x: float, world_y: float, tile_id: int, chunks: Dict):
        """Set a tile at world coordinates"""
        chunk_x, chunk_y = self.world_to_chunk(world_x, world_y)

        # Create chunk if it doesn't exist
        if (chunk_x, chunk_y) not in chunks:
            chunks[(chunk_x, chunk_y)] = [
                [TileType.GRASS for _ in range(self.chunk_size)]
                for _ in range(self.chunk_size)
            ]

        # Calculate local tile position
        local_x = int(
            (world_x - chunk_x * self.chunk_pixel_size) / self.tile_size
        ) % self.chunk_size
        local_y = int(
            (world_y - chunk_y * self.chunk_pixel_size) / self.tile_size
        ) % self.chunk_size

        # Set the tile
        chunks[(chunk_x, chunk_y)][local_y][local_x] = tile_id

    def _draw_line(
        self, p1: Tuple[float, float], p2: Tuple[float, float], tile_id: int, chunks: Dict
    ):
        """Draw a line between two points (Bresenham's algorithm)"""
        x1, y1 = int(p1[0] / self.tile_size), int(p1[1] / self.tile_size)
        x2, y2 = int(p2[0] / self.tile_size), int(p2[1] / self.tile_size)

        dx = abs(x2 - x1)
        dy = abs(y2 - y1)
        sx = 1 if x1 < x2 else -1
        sy = 1 if y1 < y2 else -1
        err = dx - dy

        while True:
            self._set_tile(x1 * self.tile_size, y1 * self.tile_size, tile_id, chunks)

            if x1 == x2 and y1 == y2:
                break

            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x1 += sx
            if e2 < dx:
                err += dx
                y1 += sy
