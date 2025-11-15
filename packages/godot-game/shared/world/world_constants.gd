extends RefCounted
class_name WorldConstants
## World-wide constants and configuration
##
## This class defines fundamental constants used throughout the world system.
## These values should rarely change, as they affect saved world data.

## Chunk dimensions
const CHUNK_SIZE: int = 32  # 32x32 tiles per chunk
const CHUNK_SIZE_SQUARED: int = CHUNK_SIZE * CHUNK_SIZE  # 1024 tiles total

## Tile dimensions (in pixels)
const TILE_SIZE: int = 32  # Each tile is 32x32 pixels

## Chunk size in world pixels
const CHUNK_PIXEL_SIZE: int = CHUNK_SIZE * TILE_SIZE  # 1024 pixels

## View distance settings
const CHUNK_VIEW_RADIUS: int = 3  # Load chunks within 3 chunks of player
const CHUNK_UNLOAD_RADIUS: int = 4  # Unload chunks beyond 4 chunks

## World boundaries (optional - set to 0 for infinite world)
const WORLD_MIN_X: int = -1000  # Minimum chunk X coordinate
const WORLD_MAX_X: int = 1000   # Maximum chunk X coordinate
const WORLD_MIN_Y: int = -1000  # Minimum chunk Y coordinate
const WORLD_MAX_Y: int = 1000   # Maximum chunk Y coordinate

## Simulation tiers (based on distance from nearest player)
const SIM_TIER_ACTIVE_DISTANCE: float = 100.0   # Full 60 FPS simulation
const SIM_TIER_NEAR_DISTANCE: float = 500.0     # 10 FPS simplified
const SIM_TIER_FAR_DISTANCE: float = 2000.0     # 1 FPS statistical
# Beyond FAR_DISTANCE = dormant (event-based only)

## Helper functions for coordinate conversion

## Converts world position (pixels) to chunk coordinates
static func world_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_pos.x / CHUNK_PIXEL_SIZE),
		floori(world_pos.y / CHUNK_PIXEL_SIZE)
	)

## Converts chunk coordinates to world position (pixels, top-left of chunk)
static func chunk_to_world(chunk_pos: Vector2i) -> Vector2:
	return Vector2(
		chunk_pos.x * CHUNK_PIXEL_SIZE,
		chunk_pos.y * CHUNK_PIXEL_SIZE
	)

## Converts world position to tile position (within chunk)
static func world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_pos.x / TILE_SIZE),
		floori(world_pos.y / TILE_SIZE)
	)

## Converts tile position to world position (pixels, center of tile)
static func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return Vector2(
		tile_pos.x * TILE_SIZE + TILE_SIZE / 2,
		tile_pos.y * TILE_SIZE + TILE_SIZE / 2
	)

## Gets local tile position within a chunk (0-31, 0-31)
static func world_to_local_tile(world_pos: Vector2) -> Vector2i:
	var chunk_pos = world_to_chunk(world_pos)
	var chunk_world_pos = chunk_to_world(chunk_pos)
	var offset = world_pos - chunk_world_pos
	return Vector2i(
		floori(offset.x / TILE_SIZE),
		floori(offset.y / TILE_SIZE)
	)

## Checks if chunk coordinates are within world boundaries
static func is_chunk_in_bounds(chunk_pos: Vector2i) -> bool:
	if WORLD_MIN_X == 0 and WORLD_MAX_X == 0:
		return true  # Infinite world
	return (
		chunk_pos.x >= WORLD_MIN_X and chunk_pos.x <= WORLD_MAX_X and
		chunk_pos.y >= WORLD_MIN_Y and chunk_pos.y <= WORLD_MAX_Y
	)

## Gets simulation tier based on distance from nearest player
static func get_simulation_tier(distance_to_player: float) -> int:
	if distance_to_player <= SIM_TIER_ACTIVE_DISTANCE:
		return 0  # Active - full simulation
	elif distance_to_player <= SIM_TIER_NEAR_DISTANCE:
		return 1  # Near - simplified simulation
	elif distance_to_player <= SIM_TIER_FAR_DISTANCE:
		return 2  # Far - statistical simulation
	else:
		return 3  # Dormant - event-based only
