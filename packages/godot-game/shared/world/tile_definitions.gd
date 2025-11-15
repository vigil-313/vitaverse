extends RefCounted
class_name TileDefinitions
## Tile type definitions and properties
##
## This class defines all available tile types in the game.
## Each tile has an ID, name, and properties.

## Tile type enumeration
## IMPORTANT: Never change existing IDs! Only add new ones at the end.
## Changing IDs will break existing saved worlds.
enum TileType {
	VOID = 0,           # Empty/unloaded tile

	# Natural terrain (1-50)
	GRASS = 1,
	DIRT = 2,
	STONE = 3,
	SAND = 4,
	WATER = 5,
	WATER_DEEP = 6,

	# Vegetation (51-100)
	TREE_OAK = 51,
	TREE_PINE = 52,
	BUSH = 53,
	FLOWER_RED = 54,
	FLOWER_YELLOW = 55,
	GRASS_TALL = 56,

	# Roads & paths (101-150)
	ROAD_ASPHALT = 101,
	ROAD_CONCRETE = 102,
	SIDEWALK = 103,
	PATH_DIRT = 104,

	# Buildings - walls (151-200)
	WALL_WOOD = 151,
	WALL_BRICK = 152,
	WALL_CONCRETE = 153,
	WALL_GLASS = 154,

	# Buildings - floors (201-250)
	FLOOR_WOOD = 201,
	FLOOR_TILE = 202,
	FLOOR_CARPET = 203,
	FLOOR_CONCRETE = 204,

	# Buildings - roofs (251-300)
	ROOF_SHINGLE = 251,
	ROOF_METAL = 252,
	ROOF_FLAT = 253,

	# Furniture & objects (301-400)
	DESK = 301,
	CHAIR = 302,
	BED = 303,
	TABLE = 304,

	# Special (901-999)
	MARKER_SPAWN = 901,
	MARKER_LANDMARK = 902,
}

## Tile properties
class TileProperties:
	var id: int
	var name: String
	var is_walkable: bool = true
	var is_destructible: bool = true
	var is_buildable_on: bool = false
	var blocks_vision: bool = false
	var growth_rate: float = 0.0  # For plants
	var decay_rate: float = 0.0   # For buildings

	func _init(
		p_id: int,
		p_name: String,
		p_walkable: bool = true,
		p_destructible: bool = true,
		p_buildable: bool = false,
		p_blocks_vision: bool = false
	):
		id = p_id
		name = p_name
		is_walkable = p_walkable
		is_destructible = p_destructible
		is_buildable_on = p_buildable
		blocks_vision = p_blocks_vision

## Database of all tile properties
static var tile_properties: Dictionary = {}

## Initialize tile properties database
static func _static_init() -> void:
	# Void
	tile_properties[TileType.VOID] = TileProperties.new(
		TileType.VOID, "Void", true, false, false, false
	)

	# Natural terrain
	tile_properties[TileType.GRASS] = TileProperties.new(
		TileType.GRASS, "Grass", true, true, true, false
	)
	tile_properties[TileType.DIRT] = TileProperties.new(
		TileType.DIRT, "Dirt", true, true, true, false
	)
	tile_properties[TileType.STONE] = TileProperties.new(
		TileType.STONE, "Stone", true, true, true, false
	)
	tile_properties[TileType.SAND] = TileProperties.new(
		TileType.SAND, "Sand", true, true, true, false
	)
	tile_properties[TileType.WATER] = TileProperties.new(
		TileType.WATER, "Water", false, false, false, false
	)
	tile_properties[TileType.WATER_DEEP] = TileProperties.new(
		TileType.WATER_DEEP, "Deep Water", false, false, false, false
	)

	# Vegetation
	tile_properties[TileType.TREE_OAK] = TileProperties.new(
		TileType.TREE_OAK, "Oak Tree", false, true, false, true
	)
	tile_properties[TileType.TREE_PINE] = TileProperties.new(
		TileType.TREE_PINE, "Pine Tree", false, true, false, true
	)
	tile_properties[TileType.BUSH] = TileProperties.new(
		TileType.BUSH, "Bush", true, true, false, false
	)

	# Roads
	tile_properties[TileType.ROAD_ASPHALT] = TileProperties.new(
		TileType.ROAD_ASPHALT, "Asphalt Road", true, true, false, false
	)
	tile_properties[TileType.SIDEWALK] = TileProperties.new(
		TileType.SIDEWALK, "Sidewalk", true, true, false, false
	)

	# Building walls
	tile_properties[TileType.WALL_WOOD] = TileProperties.new(
		TileType.WALL_WOOD, "Wooden Wall", false, true, false, true
	)
	tile_properties[TileType.WALL_BRICK] = TileProperties.new(
		TileType.WALL_BRICK, "Brick Wall", false, true, false, true
	)
	tile_properties[TileType.WALL_GLASS] = TileProperties.new(
		TileType.WALL_GLASS, "Glass Wall", false, true, false, false
	)

	# Floors
	tile_properties[TileType.FLOOR_WOOD] = TileProperties.new(
		TileType.FLOOR_WOOD, "Wooden Floor", true, true, false, false
	)
	tile_properties[TileType.FLOOR_CARPET] = TileProperties.new(
		TileType.FLOOR_CARPET, "Carpet", true, true, false, false
	)

	# Add more as needed...

## Get properties for a tile type
static func get_properties(tile_id: int) -> TileProperties:
	return tile_properties.get(tile_id, tile_properties[TileType.VOID])

## Check if a tile is walkable
static func is_walkable(tile_id: int) -> bool:
	return get_properties(tile_id).is_walkable

## Check if a tile is destructible
static func is_destructible(tile_id: int) -> bool:
	return get_properties(tile_id).is_destructible

## Check if you can build on this tile
static func is_buildable_on(tile_id: int) -> bool:
	return get_properties(tile_id).is_buildable_on

## Get tile name
static func get_tile_name(tile_id: int) -> String:
	return get_properties(tile_id).name
