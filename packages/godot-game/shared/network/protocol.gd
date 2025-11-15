extends RefCounted
class_name Protocol
## Network protocol utilities and helpers
##
## Provides common network functionality used by both client and server.

## Connection states
enum ConnectionState {
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
	AUTHENTICATED,
	DISCONNECTING
}

## Error codes
enum ErrorCode {
	NONE = 0,
	INVALID_VERSION = 1,
	SERVER_FULL = 2,
	INVALID_CREDENTIALS = 3,
	TIMEOUT = 4,
	ALREADY_CONNECTED = 5,
	BANNED = 6,
	KICKED = 7,
	PROTOCOL_MISMATCH = 8,
	UNKNOWN = 99
}

## Get human-readable error message
static func get_error_message(error_code: int) -> String:
	match error_code:
		ErrorCode.NONE:
			return "No error"
		ErrorCode.INVALID_VERSION:
			return "Invalid game version"
		ErrorCode.SERVER_FULL:
			return "Server is full"
		ErrorCode.INVALID_CREDENTIALS:
			return "Invalid credentials"
		ErrorCode.TIMEOUT:
			return "Connection timeout"
		ErrorCode.ALREADY_CONNECTED:
			return "Already connected to server"
		ErrorCode.BANNED:
			return "You are banned from this server"
		ErrorCode.KICKED:
			return "You were kicked from the server"
		ErrorCode.PROTOCOL_MISMATCH:
			return "Protocol version mismatch - please update your client"
		_:
			return "Unknown error"

## Validate packet structure
static func validate_packet(packet: Dictionary, required_fields: Array) -> bool:
	for field in required_fields:
		if not packet.has(field):
			push_warning("Packet missing required field: " + field)
			return false
	return true

## Sanitize chat message (basic filtering)
static func sanitize_chat_message(message: String) -> String:
	# Remove leading/trailing whitespace
	message = message.strip_edges()

	# Limit length
	const MAX_LENGTH = 256
	if message.length() > MAX_LENGTH:
		message = message.substr(0, MAX_LENGTH)

	# Remove control characters
	var clean_message = ""
	for i in range(message.length()):
		var c = message[i]
		var code = c.unicode_at(0)
		# Allow printable ASCII and common Unicode
		if code >= 32 and code != 127:
			clean_message += c

	return clean_message

## Validate username (basic rules)
static func validate_username(username: String) -> bool:
	# Length check
	if username.length() < 3 or username.length() > 20:
		return false

	# Alphanumeric + underscore only
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9_]+$")
	return regex.search(username) != null

## Rate limiting helper class
class RateLimiter:
	var max_per_second: int
	var timestamps: Array[int] = []

	func _init(p_max_per_second: int):
		max_per_second = p_max_per_second

	## Check if action is allowed
	func is_allowed() -> bool:
		var current_time = Time.get_ticks_msec()

		# Remove old timestamps (older than 1 second)
		timestamps = timestamps.filter(
			func(ts): return current_time - ts < 1000
		)

		if timestamps.size() >= max_per_second:
			return false

		timestamps.append(current_time)
		return true

	## Reset the limiter
	func reset() -> void:
		timestamps.clear()

## Packet compression (future enhancement)
static func compress_packet(packet: Dictionary) -> PackedByteArray:
	# TODO: Implement packet compression for large payloads
	# For now, just use JSON
	var json = JSON.stringify(packet)
	return json.to_utf8_buffer()

## Packet decompression (future enhancement)
static func decompress_packet(data: PackedByteArray) -> Dictionary:
	# TODO: Implement packet decompression
	# For now, just parse JSON
	var json_string = data.get_string_from_utf8()
	return Packets.from_json(json_string)

## Calculate checksum for data integrity (future enhancement)
static func calculate_checksum(data: PackedByteArray) -> int:
	# Simple checksum for now
	var checksum = 0
	for byte in data:
		checksum = (checksum + byte) % 65536
	return checksum

## Verify checksum
static func verify_checksum(data: PackedByteArray, expected_checksum: int) -> bool:
	return calculate_checksum(data) == expected_checksum
