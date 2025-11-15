extends Node
## Network client for connecting to game server
##
## Handles connection, disconnection, and packet communication with the server.

## Signals
signal connected_to_server
signal disconnected_from_server
signal connection_failed(reason: String)
signal chunk_received(chunk: Chunk)
signal tile_updated(chunk_pos: Vector2i, local_pos: Vector2i, tile_id: int)
signal player_spawned(player_id: int, username: String, position: Vector2)
signal player_despawned(player_id: int)
signal player_state_updated(player_id: int, position: Vector2, velocity: Vector2)
signal chat_received(username: String, message: String)

## Network peer
var peer: ENetMultiplayerPeer

## Connection state
var connection_state: Protocol.ConnectionState = Protocol.ConnectionState.DISCONNECTED
var player_id: int = -1
var latency: int = 0

## Configuration
var server_host: String = "127.0.0.1"
var server_port: int = 9000
var username: String = "Player"

## Ping tracking
var last_ping_time: int = 0
var ping_interval: int = 5000  # 5 seconds

func _ready() -> void:
	# Load config
	server_host = Config.get_server_host()
	server_port = Config.get_server_port()

	# Get username from config (set by main menu)
	username = Config.get_value("username", "Player")

	# Auto-connect to server
	print("[NetworkClient] Auto-connecting to ", server_host, ":", server_port, " as ", username)
	connect_to_server()

func _process(delta: float) -> void:
	# Send periodic ping
	if connection_state == Protocol.ConnectionState.AUTHENTICATED:
		var current_time = Time.get_ticks_msec()
		if current_time - last_ping_time > ping_interval:
			send_ping()
			last_ping_time = current_time

## ============================================================================
## Connection Management
## ============================================================================

## Connect to game server
func connect_to_server(p_username: String = "") -> void:
	if connection_state != Protocol.ConnectionState.DISCONNECTED:
		push_warning("[Client] Already connected or connecting")
		return

	if not p_username.is_empty():
		username = p_username

	print("[Client] Connecting to ", server_host, ":", server_port)
	connection_state = Protocol.ConnectionState.CONNECTING

	# Create ENet peer
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(server_host, server_port)

	if error != OK:
		push_error("[Client] Failed to create client: ", error)
		connection_state = Protocol.ConnectionState.DISCONNECTED
		connection_failed.emit("Failed to create client")
		return

	# Set as multiplayer peer
	multiplayer.multiplayer_peer = peer

	# Connect signals
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

## Disconnect from server
func disconnect_from_server(reason: String = "") -> void:
	if connection_state == Protocol.ConnectionState.DISCONNECTED:
		return

	print("[Client] Disconnecting from server: ", reason)

	# Send disconnect packet
	if connection_state == Protocol.ConnectionState.AUTHENTICATED:
		send_packet(Packets.encode_disconnect(reason))

	# Close connection
	if peer:
		peer.close()

	connection_state = Protocol.ConnectionState.DISCONNECTED
	player_id = -1

	disconnected_from_server.emit()

## ============================================================================
## Network Event Handlers
## ============================================================================

func _on_connected_to_server() -> void:
	print("[Client] Connected to server")
	connection_state = Protocol.ConnectionState.CONNECTED

	# Send handshake
	var handshake = Packets.encode_handshake(
		username,
		Version.GAME_VERSION,
		Version.PROTOCOL_VERSION
	)
	send_packet(handshake)

func _on_connection_failed() -> void:
	print("[Client] Connection failed")
	connection_state = Protocol.ConnectionState.DISCONNECTED
	connection_failed.emit("Connection failed")

func _on_server_disconnected() -> void:
	print("[Client] Server disconnected")
	connection_state = Protocol.ConnectionState.DISCONNECTED
	disconnected_from_server.emit()

## ============================================================================
## Packet Sending
## ============================================================================

## Send packet to server
func send_packet(packet: Dictionary) -> void:
	if connection_state == Protocol.ConnectionState.DISCONNECTED:
		push_warning("[Client] Cannot send packet - not connected")
		return

	rpc_id(1, "receive_packet", Packets.to_json(packet))

## Send player movement
func send_player_move(position: Vector2, velocity: Vector2) -> void:
	send_packet(Packets.encode_player_move(position, velocity))

## Request chunk data
func request_chunk(chunk_x: int, chunk_y: int) -> void:
	send_packet(Packets.encode_chunk_request(chunk_x, chunk_y))

## Send build tile action
func send_build_tile(world_pos: Vector2, tile_id: int) -> void:
	send_packet(Packets.encode_build_tile(world_pos.x, world_pos.y, tile_id))

## Send destroy tile action
func send_destroy_tile(world_pos: Vector2) -> void:
	send_packet(Packets.encode_destroy_tile(world_pos.x, world_pos.y))

## Send chat message
func send_chat(message: String) -> void:
	send_packet(Packets.encode_chat_message(message))

## Send ping
func send_ping() -> void:
	send_packet(Packets.encode_ping())

## ============================================================================
## Packet Receiving (Called via RPC from server)
## ============================================================================

## Main packet receiver
@rpc("authority", "call_remote", "reliable")
func receive_packet_from_server(packet_json: String) -> void:
	var packet = Packets.from_json(packet_json)

	if packet.is_empty():
		push_warning("[Client] Received invalid packet")
		return

	var packet_type = Packets.get_type(packet)

	match packet_type:
		Packets.PacketType.HANDSHAKE_RESPONSE:
			_handle_handshake_response(packet)
		Packets.PacketType.CHUNK_DATA:
			_handle_chunk_data(packet)
		Packets.PacketType.TILE_UPDATE:
			_handle_tile_update(packet)
		Packets.PacketType.PLAYER_SPAWN:
			_handle_player_spawn(packet)
		Packets.PacketType.PLAYER_DESPAWN:
			_handle_player_despawn(packet)
		Packets.PacketType.PLAYER_STATE:
			_handle_player_state(packet)
		Packets.PacketType.CHAT_BROADCAST:
			_handle_chat_broadcast(packet)
		Packets.PacketType.PONG:
			_handle_pong(packet)
		Packets.PacketType.ERROR:
			_handle_error(packet)
		_:
			push_warning("[Client] Unknown packet type: ", packet_type)

## Handle handshake response
func _handle_handshake_response(packet: Dictionary) -> void:
	var success = packet.get("success", false)
	var message = packet.get("message", "")

	if success:
		player_id = packet.get("player_id", -1)
		connection_state = Protocol.ConnectionState.AUTHENTICATED
		print("[Client] ✓ Authenticated as player ", player_id)
		print("[Client] Server message: ", message)
		connected_to_server.emit()
	else:
		print("[Client] ✗ Authentication failed: ", message)
		disconnect_from_server(message)
		connection_failed.emit(message)

## Handle chunk data
func _handle_chunk_data(packet: Dictionary) -> void:
	var chunk_x = packet.get("chunk_x", 0)
	var chunk_y = packet.get("chunk_y", 0)
	var tiles = packet.get("tiles", [])

	var chunk = Chunk.new(Vector2i(chunk_x, chunk_y))
	chunk.tiles = tiles

	chunk_received.emit(chunk)

## Handle tile update
func _handle_tile_update(packet: Dictionary) -> void:
	var chunk_x = packet.get("chunk_x", 0)
	var chunk_y = packet.get("chunk_y", 0)
	var local_x = packet.get("local_x", 0)
	var local_y = packet.get("local_y", 0)
	var tile_id = packet.get("tile_id", 0)

	tile_updated.emit(
		Vector2i(chunk_x, chunk_y),
		Vector2i(local_x, local_y),
		tile_id
	)

## Handle player spawn
func _handle_player_spawn(packet: Dictionary) -> void:
	var p_id = packet.get("player_id", -1)
	var p_username = packet.get("username", "")
	var pos = packet.get("pos", [0, 0])

	player_spawned.emit(p_id, p_username, Vector2(pos[0], pos[1]))

## Handle player despawn
func _handle_player_despawn(packet: Dictionary) -> void:
	var p_id = packet.get("player_id", -1)
	player_despawned.emit(p_id)

## Handle player state update
func _handle_player_state(packet: Dictionary) -> void:
	var p_id = packet.get("player_id", -1)
	var pos = packet.get("pos", [0, 0])
	var vel = packet.get("vel", [0, 0])

	player_state_updated.emit(
		p_id,
		Vector2(pos[0], pos[1]),
		Vector2(vel[0], vel[1])
	)

## Handle chat broadcast
func _handle_chat_broadcast(packet: Dictionary) -> void:
	var p_username = packet.get("username", "")
	var message = packet.get("message", "")

	chat_received.emit(p_username, message)

## Handle pong (calculate latency)
func _handle_pong(packet: Dictionary) -> void:
	latency = Packets.calculate_latency(packet)

	if Config.is_debug_mode():
		print("[Client] Latency: ", latency, " ms")

## Handle error
func _handle_error(packet: Dictionary) -> void:
	var error_code = packet.get("error_code", 0)
	var error_message = packet.get("error_message", "")

	push_error("[Client] Server error: ", error_message, " (code: ", error_code, ")")

## ============================================================================
## Utility Functions
## ============================================================================

## Check if connected and authenticated
func is_client_connected() -> bool:
	return connection_state == Protocol.ConnectionState.AUTHENTICATED

## Get connection state string
func get_connection_state_string() -> String:
	match connection_state:
		Protocol.ConnectionState.DISCONNECTED:
			return "Disconnected"
		Protocol.ConnectionState.CONNECTING:
			return "Connecting..."
		Protocol.ConnectionState.CONNECTED:
			return "Connected"
		Protocol.ConnectionState.AUTHENTICATED:
			return "Playing"
		_:
			return "Unknown"
