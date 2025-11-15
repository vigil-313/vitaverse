extends RefCounted
class_name Chunk
## Chunk data structure
##
## Represents a 32x32 section of the world.
## Contains tile data and metadata for persistence and streaming.

## Chunk position in chunk coordinates (not world pixels)
var position: Vector2i = Vector2i.ZERO

## Tile data - flat array of tile IDs (1024 elements for 32x32)
## Index = y * CHUNK_SIZE + x
var tiles: Array[int] = []

## Metadata
var created_at: int = 0  # Unix timestamp
var modified_at: int = 0  # Unix timestamp
var is_modified: bool = false  # Dirty flag for saving
var name: String = ""  # Optional human-readable name

## Active entities in this chunk (transient, not saved)
var entities: Array = []

## Constructor
func _init(chunk_pos: Vector2i = Vector2i.ZERO) -> void:
	position = chunk_pos
	created_at = Time.get_unix_time_from_system()
	modified_at = created_at

	# Initialize tiles array with VOID
	tiles.resize(WorldConstants.CHUNK_SIZE_SQUARED)
	tiles.fill(TileDefinitions.TileType.VOID)

## Get tile at local position (0-31, 0-31)
func get_tile(local_x: int, local_y: int) -> int:
	if not _is_valid_local_pos(local_x, local_y):
		push_error("Invalid tile position: (%d, %d)" % [local_x, local_y])
		return TileDefinitions.TileType.VOID

	var index = _pos_to_index(local_x, local_y)
	return tiles[index]

## Set tile at local position (0-31, 0-31)
func set_tile(local_x: int, local_y: int, tile_id: int) -> void:
	if not _is_valid_local_pos(local_x, local_y):
		push_error("Invalid tile position: (%d, %d)" % [local_x, local_y])
		return

	var index = _pos_to_index(local_x, local_y)
	if tiles[index] != tile_id:
		tiles[index] = tile_id
		mark_modified()

## Mark chunk as modified (needs saving)
func mark_modified() -> void:
	is_modified = true
	modified_at = Time.get_unix_time_from_system()

## Serialize chunk to dictionary (for saving/network)
func to_dict() -> Dictionary:
	return {
		"chunk_x": position.x,
		"chunk_y": position.y,
		"tiles": tiles,
		"created_at": created_at,
		"modified_at": modified_at,
		"name": name
	}

## Deserialize chunk from dictionary
static func from_dict(data: Dictionary) -> Chunk:
	var chunk = Chunk.new(Vector2i(data.get("chunk_x", 0), data.get("chunk_y", 0)))

	var tiles_data = data.get("tiles", [])
	if tiles_data.size() == WorldConstants.CHUNK_SIZE_SQUARED:
		chunk.tiles = tiles_data
	else:
		push_warning("Invalid tile data size, using empty chunk")

	chunk.created_at = data.get("created_at", Time.get_unix_time_from_system())
	chunk.modified_at = data.get("modified_at", chunk.created_at)
	chunk.name = data.get("name", "")
	chunk.is_modified = false

	return chunk

## Serialize to JSON string
func to_json() -> String:
	return JSON.stringify(to_dict())

## Deserialize from JSON string
static func from_json(json_string: String) -> Chunk:
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("Failed to parse chunk JSON: " + json.get_error_message())
		return null

	return from_dict(json.data)

## Serialize to packed byte array (more efficient for network)
func to_bytes() -> PackedByteArray:
	var bytes = PackedByteArray()

	# Write chunk position (8 bytes)
	bytes.append_array(_int_to_bytes(position.x))
	bytes.append_array(_int_to_bytes(position.y))

	# Write tile data (2048 bytes - 2 bytes per tile)
	for tile_id in tiles:
		bytes.append_array(_short_to_bytes(tile_id))

	return bytes

## Deserialize from packed byte array
static func from_bytes(bytes: PackedByteArray) -> Chunk:
	if bytes.size() < 2056:  # 8 + 2048
		push_error("Invalid chunk byte data size")
		return null

	# Read chunk position
	var chunk_x = _bytes_to_int(bytes.slice(0, 4))
	var chunk_y = _bytes_to_int(bytes.slice(4, 8))
	var chunk = Chunk.new(Vector2i(chunk_x, chunk_y))

	# Read tile data
	for i in range(WorldConstants.CHUNK_SIZE_SQUARED):
		var offset = 8 + (i * 2)
		var tile_id = _bytes_to_short(bytes.slice(offset, offset + 2))
		chunk.tiles[i] = tile_id

	chunk.is_modified = false
	return chunk

## Fill entire chunk with a single tile type
func fill(tile_id: int) -> void:
	tiles.fill(tile_id)
	mark_modified()

## Check if chunk is empty (all VOID)
func is_empty() -> bool:
	return tiles.all(func(tile): return tile == TileDefinitions.TileType.VOID)

## Get world position (pixels) of chunk's top-left corner
func get_world_position() -> Vector2:
	return WorldConstants.chunk_to_world(position)

## Private helper functions

func _is_valid_local_pos(x: int, y: int) -> bool:
	return x >= 0 and x < WorldConstants.CHUNK_SIZE and y >= 0 and y < WorldConstants.CHUNK_SIZE

func _pos_to_index(x: int, y: int) -> int:
	return y * WorldConstants.CHUNK_SIZE + x

static func _int_to_bytes(value: int) -> PackedByteArray:
	var bytes = PackedByteArray()
	bytes.resize(4)
	bytes.encode_s32(0, value)
	return bytes

static func _bytes_to_int(bytes: PackedByteArray) -> int:
	return bytes.decode_s32(0)

static func _short_to_bytes(value: int) -> PackedByteArray:
	var bytes = PackedByteArray()
	bytes.resize(2)
	bytes.encode_s16(0, value)
	return bytes

static func _bytes_to_short(bytes: PackedByteArray) -> int:
	return bytes.decode_s16(0)
