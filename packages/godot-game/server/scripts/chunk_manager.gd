extends Node
class_name ChunkManager
## Manages chunk loading, unloading, and persistence
##
## Handles chunk streaming based on player positions and saves modified chunks.

## Reference to world manager
var world_manager: WorldManager

## Loaded chunks: Vector2i(chunk_x, chunk_y) -> Chunk
var loaded_chunks: Dictionary = {}

## Chunks marked as modified (need saving)
var modified_chunks: Array[Vector2i] = []

## Database/file storage
var use_database: bool = false  # false = file-based, true = SQLite
var chunk_directory: String = "user://world/chunks/"

func _ready() -> void:
	# Create chunk directory if it doesn't exist
	if not DirAccess.dir_exists_absolute(chunk_directory):
		DirAccess.make_dir_recursive_absolute(chunk_directory)

	print("[ChunkManager] Initialized")
	print("[ChunkManager] Chunk directory: ", chunk_directory)

## Update (called each frame)
func update(delta: float) -> void:
	# Periodic save of modified chunks
	if modified_chunks.size() > 0 and Engine.get_frames_drawn() % 300 == 0:  # Every 5 seconds
		save_modified_chunks()

## Get chunk at position (returns null if not loaded)
func get_chunk(chunk_pos: Vector2i) -> Chunk:
	return loaded_chunks.get(chunk_pos, null)

## Get or create chunk at position (always returns a chunk)
func get_or_create_chunk(chunk_pos: Vector2i) -> Chunk:
	# Check if already loaded
	if loaded_chunks.has(chunk_pos):
		return loaded_chunks[chunk_pos]

	# Try to load from storage
	var chunk = _load_chunk_from_storage(chunk_pos)

	if chunk == null:
		# Create new empty chunk
		chunk = _generate_new_chunk(chunk_pos)

	# Add to loaded chunks
	loaded_chunks[chunk_pos] = chunk

	if Config.is_debug_mode():
		print("[ChunkManager] Loaded chunk (", chunk_pos.x, ", ", chunk_pos.y, ")")

	return chunk

## Load chunk from file storage
func _load_chunk_from_storage(chunk_pos: Vector2i) -> Chunk:
	var file_path = _get_chunk_file_path(chunk_pos)

	if not FileAccess.file_exists(file_path):
		return null

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[ChunkManager] Failed to open chunk file: ", file_path)
		return null

	var json_string = file.get_as_text()
	file.close()

	var chunk = Chunk.from_json(json_string)

	if chunk == null:
		push_error("[ChunkManager] Failed to parse chunk: ", file_path)
		return null

	return chunk

## Generate new chunk (placeholder - will be replaced with generation/OSM import)
func _generate_new_chunk(chunk_pos: Vector2i) -> Chunk:
	var chunk = Chunk.new(chunk_pos)

	# Simple procedural generation for now
	# Fill with grass
	chunk.fill(TileDefinitions.TileType.GRASS)

	# Add some variety
	for y in range(WorldConstants.CHUNK_SIZE):
		for x in range(WorldConstants.CHUNK_SIZE):
			# Random trees (5% chance)
			if randf() < 0.05:
				chunk.set_tile(x, y, TileDefinitions.TileType.TREE_OAK)
			# Random bushes (10% chance)
			elif randf() < 0.10:
				chunk.set_tile(x, y, TileDefinitions.TileType.BUSH)

	chunk.is_modified = false  # Don't save empty generated chunks immediately
	return chunk

## Save chunk to storage
func save_chunk(chunk: Chunk) -> void:
	var file_path = _get_chunk_file_path(chunk.position)

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("[ChunkManager] Failed to open chunk file for writing: ", file_path)
		return

	file.store_string(chunk.to_json())
	file.close()

	chunk.is_modified = false

	if Config.is_debug_mode():
		print("[ChunkManager] Saved chunk (", chunk.position.x, ", ", chunk.position.y, ")")

## Save all modified chunks
func save_modified_chunks() -> void:
	if modified_chunks.is_empty():
		return

	var save_count = 0

	for chunk_pos in modified_chunks:
		var chunk = loaded_chunks.get(chunk_pos, null)
		if chunk and chunk.is_modified:
			save_chunk(chunk)
			save_count += 1

	modified_chunks.clear()

	if save_count > 0:
		print("[ChunkManager] Saved ", save_count, " modified chunks")

## Save all loaded chunks
func save_all_chunks() -> void:
	print("[ChunkManager] Saving all chunks...")

	var save_count = 0
	for chunk in loaded_chunks.values():
		if chunk.is_modified:
			save_chunk(chunk)
			save_count += 1

	print("[ChunkManager] ✓ Saved ", save_count, " chunks")

## Mark chunk as modified (needs saving)
func mark_chunk_modified(chunk_pos: Vector2i) -> void:
	if not modified_chunks.has(chunk_pos):
		modified_chunks.append(chunk_pos)

## Unload chunk (remove from memory)
func unload_chunk(chunk_pos: Vector2i) -> void:
	var chunk = loaded_chunks.get(chunk_pos, null)
	if chunk == null:
		return

	# Save if modified
	if chunk.is_modified:
		save_chunk(chunk)

	# Remove from loaded chunks
	loaded_chunks.erase(chunk_pos)

	if Config.is_debug_mode():
		print("[ChunkManager] Unloaded chunk (", chunk_pos.x, ", ", chunk_pos.y, ")")

## Update active chunks based on player positions
func update_active_chunks() -> void:
	# TODO: Implement smart chunk loading/unloading
	# - Get all player positions
	# - Calculate which chunks should be loaded
	# - Unload chunks that are too far from all players
	# - Load chunks that are near players
	pass

## Get chunk file path
func _get_chunk_file_path(chunk_pos: Vector2i) -> String:
	return chunk_directory + "chunk_%d_%d.json" % [chunk_pos.x, chunk_pos.y]

## Get loaded chunk count
func get_loaded_chunk_count() -> int:
	return loaded_chunks.size()

## Get chunk statistics
func get_stats() -> Dictionary:
	return {
		"loaded_chunks": loaded_chunks.size(),
		"modified_chunks": modified_chunks.size(),
	}
