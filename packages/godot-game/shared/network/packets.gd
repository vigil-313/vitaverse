extends RefCounted
class_name Packets
## Network packet definitions and encoding/decoding
##
## This class defines all packet types and provides helper functions
## for creating and parsing network messages.

## Packet type enumeration
enum PacketType {
	# Connection (0-9)
	HANDSHAKE = 0,
	HANDSHAKE_RESPONSE = 1,
	DISCONNECT = 2,

	# Player state (10-29)
	PLAYER_MOVE = 10,
	PLAYER_STATE = 11,
	PLAYER_SPAWN = 12,
	PLAYER_DESPAWN = 13,

	# World data (30-49)
	CHUNK_DATA = 30,
	CHUNK_REQUEST = 31,
	TILE_UPDATE = 32,
	TILE_BATCH_UPDATE = 33,

	# Actions (50-69)
	PLAYER_ACTION = 50,
	BUILD_TILE = 51,
	DESTROY_TILE = 52,

	# Chat & social (70-89)
	CHAT_MESSAGE = 70,
	CHAT_BROADCAST = 71,

	# System (90-99)
	PING = 90,
	PONG = 91,
	ERROR = 99,
}

## ============================================================================
## Connection Packets
## ============================================================================

## Client → Server: Initial connection handshake
static func encode_handshake(username: String, game_version: String, protocol_version: String) -> Dictionary:
	return {
		"type": PacketType.HANDSHAKE,
		"username": username,
		"game_version": game_version,
		"protocol_version": protocol_version,
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: Handshake response with player ID
static func encode_handshake_response(player_id: int, success: bool, message: String = "") -> Dictionary:
	return {
		"type": PacketType.HANDSHAKE_RESPONSE,
		"player_id": player_id,
		"success": success,
		"message": message,
		"timestamp": Time.get_ticks_msec()
	}

## Either direction: Graceful disconnect
static func encode_disconnect(reason: String = "") -> Dictionary:
	return {
		"type": PacketType.DISCONNECT,
		"reason": reason,
		"timestamp": Time.get_ticks_msec()
	}

## ============================================================================
## Player State Packets
## ============================================================================

## Client → Server: Player movement input
static func encode_player_move(position: Vector2, velocity: Vector2) -> Dictionary:
	return {
		"type": PacketType.PLAYER_MOVE,
		"pos": [position.x, position.y],
		"vel": [velocity.x, velocity.y],
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: Other player's state
static func encode_player_state(player_id: int, position: Vector2, velocity: Vector2) -> Dictionary:
	return {
		"type": PacketType.PLAYER_STATE,
		"player_id": player_id,
		"pos": [position.x, position.y],
		"vel": [velocity.x, velocity.y],
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: New player spawned
static func encode_player_spawn(player_id: int, username: String, position: Vector2) -> Dictionary:
	return {
		"type": PacketType.PLAYER_SPAWN,
		"player_id": player_id,
		"username": username,
		"pos": [position.x, position.y],
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: Player disconnected
static func encode_player_despawn(player_id: int) -> Dictionary:
	return {
		"type": PacketType.PLAYER_DESPAWN,
		"player_id": player_id,
		"timestamp": Time.get_ticks_msec()
	}

## ============================================================================
## World Data Packets
## ============================================================================

## Server → Client: Full chunk data
static func encode_chunk_data(chunk: Chunk) -> Dictionary:
	return {
		"type": PacketType.CHUNK_DATA,
		"chunk_x": chunk.position.x,
		"chunk_y": chunk.position.y,
		"tiles": chunk.tiles,
		"timestamp": Time.get_ticks_msec()
	}

## Client → Server: Request chunk data
static func encode_chunk_request(chunk_x: int, chunk_y: int) -> Dictionary:
	return {
		"type": PacketType.CHUNK_REQUEST,
		"chunk_x": chunk_x,
		"chunk_y": chunk_y,
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: Single tile changed
static func encode_tile_update(chunk_x: int, chunk_y: int, local_x: int, local_y: int, tile_id: int) -> Dictionary:
	return {
		"type": PacketType.TILE_UPDATE,
		"chunk_x": chunk_x,
		"chunk_y": chunk_y,
		"local_x": local_x,
		"local_y": local_y,
		"tile_id": tile_id,
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: Multiple tiles changed (batch for efficiency)
static func encode_tile_batch_update(updates: Array) -> Dictionary:
	return {
		"type": PacketType.TILE_BATCH_UPDATE,
		"updates": updates,
		"timestamp": Time.get_ticks_msec()
	}

## ============================================================================
## Action Packets
## ============================================================================

## Client → Server: Build a tile
static func encode_build_tile(world_x: float, world_y: float, tile_id: int) -> Dictionary:
	return {
		"type": PacketType.BUILD_TILE,
		"world_x": world_x,
		"world_y": world_y,
		"tile_id": tile_id,
		"timestamp": Time.get_ticks_msec()
	}

## Client → Server: Destroy a tile
static func encode_destroy_tile(world_x: float, world_y: float) -> Dictionary:
	return {
		"type": PacketType.DESTROY_TILE,
		"world_x": world_x,
		"world_y": world_y,
		"timestamp": Time.get_ticks_msec()
	}

## ============================================================================
## Chat Packets
## ============================================================================

## Client → Server: Send chat message
static func encode_chat_message(message: String) -> Dictionary:
	return {
		"type": PacketType.CHAT_MESSAGE,
		"message": message,
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: Broadcast chat message
static func encode_chat_broadcast(player_id: int, username: String, message: String) -> Dictionary:
	return {
		"type": PacketType.CHAT_BROADCAST,
		"player_id": player_id,
		"username": username,
		"message": message,
		"timestamp": Time.get_ticks_msec()
	}

## ============================================================================
## System Packets
## ============================================================================

## Either direction: Ping for latency measurement
static func encode_ping() -> Dictionary:
	return {
		"type": PacketType.PING,
		"timestamp": Time.get_ticks_msec()
	}

## Either direction: Pong response
static func encode_pong(original_timestamp: int) -> Dictionary:
	return {
		"type": PacketType.PONG,
		"original_timestamp": original_timestamp,
		"timestamp": Time.get_ticks_msec()
	}

## Server → Client: Error message
static func encode_error(error_code: int, error_message: String) -> Dictionary:
	return {
		"type": PacketType.ERROR,
		"error_code": error_code,
		"error_message": error_message,
		"timestamp": Time.get_ticks_msec()
	}

## ============================================================================
## Utility Functions
## ============================================================================

## Convert packet dictionary to JSON string for network transmission
static func to_json(packet: Dictionary) -> String:
	return JSON.stringify(packet)

## Parse JSON string to packet dictionary
static func from_json(json_string: String) -> Dictionary:
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("Failed to parse packet JSON: " + json.get_error_message())
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("Packet JSON is not a dictionary")
		return {}

	return json.data

## Get packet type from dictionary
static func get_type(packet: Dictionary) -> int:
	return packet.get("type", -1)

## Get packet timestamp
static func get_timestamp(packet: Dictionary) -> int:
	return packet.get("timestamp", 0)

## Calculate latency from ping/pong
static func calculate_latency(pong_packet: Dictionary) -> int:
	var original_timestamp = pong_packet.get("original_timestamp", 0)
	var current_time = Time.get_ticks_msec()
	return current_time - original_timestamp
