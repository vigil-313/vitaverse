extends Node2D
## World renderer
##
## Renders chunks using TileMap and manages chunk streaming.

## TileMap for rendering
@onready var tilemap: TileMap = $TileMap

## Loaded chunks: Vector2i -> Chunk
var loaded_chunks: Dictionary = {}

## Network client reference
var network_client: Node

## Player reference (for chunk streaming)
var player: Node2D

## Current player chunk
var current_player_chunk: Vector2i = Vector2i.ZERO

func _ready() -> void:
	# TileMap will be created as child node
	# For now, chunks will be rendered as colored rectangles until tileset is set up
	pass

func _process(delta: float) -> void:
	if player:
		_update_chunk_streaming()

## Update chunk streaming based on player position
func _update_chunk_streaming() -> void:
	var player_chunk = WorldConstants.world_to_chunk(player.global_position)

	if player_chunk != current_player_chunk:
		current_player_chunk = player_chunk
		_request_nearby_chunks()

## Request chunks around player
func _request_nearby_chunks() -> void:
	if not network_client or not network_client.is_connected():
		return

	# Request chunks in view radius
	for y in range(-WorldConstants.CHUNK_VIEW_RADIUS, WorldConstants.CHUNK_VIEW_RADIUS + 1):
		for x in range(-WorldConstants.CHUNK_VIEW_RADIUS, WorldConstants.CHUNK_VIEW_RADIUS + 1):
			var chunk_pos = current_player_chunk + Vector2i(x, y)

			# Skip if already loaded
			if loaded_chunks.has(chunk_pos):
				continue

			# Request from server
			network_client.request_chunk(chunk_pos.x, chunk_pos.y)

## Handle chunk received from server
func on_chunk_received(chunk: Chunk) -> void:
	loaded_chunks[chunk.position] = chunk
	render_chunk(chunk)

## Render chunk
func render_chunk(chunk: Chunk) -> void:
	# TODO: Render using TileMap when tileset is configured
	# For now, just store the chunk data

	if Config.is_debug_mode():
		print("[WorldRenderer] Rendered chunk (", chunk.position.x, ", ", chunk.position.y, ")")

## Handle tile update
func on_tile_updated(chunk_pos: Vector2i, local_pos: Vector2i, tile_id: int) -> void:
	var chunk = loaded_chunks.get(chunk_pos, null)
	if chunk:
		chunk.set_tile(local_pos.x, local_pos.y, tile_id)
		# TODO: Update TileMap cell
		# tilemap.set_cell(0, chunk_pos * CHUNK_SIZE + local_pos, tile_id)

## Set player reference
func set_player(p_player: Node2D) -> void:
	player = p_player

## Set network client reference
func set_network_client(p_network_client: Node) -> void:
	network_client = p_network_client
