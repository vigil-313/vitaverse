extends Node
## Main game server
##
## This is the entry point for the headless server.
## Manages networking, players, world state, and game logic.

## Child managers
var player_manager: PlayerManager
var world_manager: WorldManager
var chunk_manager: ChunkManager

## Network peer
var peer: ENetMultiplayerPeer

## Server state
var is_running: bool = false
var tick_count: int = 0
var server_start_time: int = 0

## Configuration
var max_players: int = 100
var server_port: int = 9000

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("VITAVERSE SERVER")
	print("=".repeat(50))

	# Print version info
	Version.print_version_info()

	# Load configuration
	max_players = Config.get_max_players()
	server_port = Config.get_server_port()

	# Initialize managers
	_initialize_managers()

	# Start server
	_start_server()

func _initialize_managers() -> void:
	print("\n[Server] Initializing managers...")

	# Create manager instances
	player_manager = PlayerManager.new()
	world_manager = WorldManager.new()
	chunk_manager = ChunkManager.new()

	# Add as children
	add_child(player_manager)
	add_child(world_manager)
	add_child(chunk_manager)

	# Connect managers
	chunk_manager.world_manager = world_manager

	print("[Server] ✓ Managers initialized")

func _start_server() -> void:
	print("\n[Server] Starting server...")
	print("[Server] Port: ", server_port)
	print("[Server] Max players: ", max_players)

	# Create ENet peer
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(server_port, max_players)

	if error != OK:
		push_error("[Server] Failed to start server: " + str(error))
		get_tree().quit(1)
		return

	# Set as multiplayer peer
	multiplayer.multiplayer_peer = peer

	# Connect network signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Mark as running
	is_running = true
	server_start_time = Time.get_unix_time_from_system()

	print("[Server] ✓ Server started successfully")
	print("[Server] Listening on port ", server_port)
	print("[Server] Waiting for players...\n")

func _process(delta: float) -> void:
	if not is_running:
		return

	tick_count += 1

	# Update managers
	player_manager.update(delta)
	world_manager.update(delta)
	chunk_manager.update(delta)

	# Broadcast state to players
	_broadcast_game_state()

	# Performance warning (if tick takes too long)
	if Config.is_debug_mode() and tick_count % 60 == 0:
		var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
		if frame_time > 16.0:  # 60 FPS = 16ms per frame
			print("[Server] WARNING: Slow tick: %.2f ms" % frame_time)

func _broadcast_game_state() -> void:
	# Send player states to all clients
	var player_states = player_manager.get_all_player_states()

	for peer_id in multiplayer.get_peers():
		# Don't send player's own state back to them
		var other_players = player_states.filter(
			func(state): return state["player_id"] != peer_id
		)

		for state in other_players:
			_send_to_peer(peer_id, Packets.encode_player_state(
				state["player_id"],
				state["position"],
				state["velocity"]
			))

## ============================================================================
## Network Event Handlers
## ============================================================================

func _on_peer_connected(id: int) -> void:
	print("[Server] Peer connected: ", id)
	# Wait for handshake packet from client
	# Actual player creation happens in _handle_handshake()

func _on_peer_disconnected(id: int) -> void:
	print("[Server] Peer disconnected: ", id)

	# Remove player
	var player = player_manager.get_player(id)
	if player:
		print("[Server] Player '", player.username, "' left the game")

		# Notify other players
		_broadcast_packet(Packets.encode_player_despawn(id))

		# Remove from manager
		player_manager.remove_player(id)

## ============================================================================
## Packet Handling (Called via RPC from clients)
## ============================================================================

## Main packet receiver (called from clients via RPC)
@rpc("any_peer", "call_remote", "reliable")
func receive_packet(packet_json: String) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	var packet = Packets.from_json(packet_json)

	if packet.is_empty():
		push_warning("[Server] Received invalid packet from peer ", sender_id)
		return

	# Handle packet based on type
	var packet_type = Packets.get_type(packet)

	match packet_type:
		Packets.PacketType.HANDSHAKE:
			_handle_handshake(packet, sender_id)
		Packets.PacketType.PLAYER_MOVE:
			_handle_player_move(packet, sender_id)
		Packets.PacketType.BUILD_TILE:
			_handle_build_tile(packet, sender_id)
		Packets.PacketType.DESTROY_TILE:
			_handle_destroy_tile(packet, sender_id)
		Packets.PacketType.CHUNK_REQUEST:
			_handle_chunk_request(packet, sender_id)
		Packets.PacketType.CHAT_MESSAGE:
			_handle_chat_message(packet, sender_id)
		Packets.PacketType.PING:
			_handle_ping(packet, sender_id)
		_:
			push_warning("[Server] Unknown packet type from peer ", sender_id, ": ", packet_type)

## Handle initial handshake
func _handle_handshake(packet: Dictionary, peer_id: int) -> void:
	var username = packet.get("username", "")
	var game_version = packet.get("game_version", "")
	var protocol_version = packet.get("protocol_version", "")

	print("[Server] Handshake from '", username, "' (version ", game_version, ")")

	# Validate protocol version
	if not Version.is_protocol_compatible(protocol_version):
		print("[Server] ✗ Protocol mismatch, rejecting")
		var response = Packets.encode_handshake_response(
			-1, false,
			"Protocol version mismatch. Server: " + Version.PROTOCOL_VERSION
		)
		_send_to_peer(peer_id, response)
		peer.disconnect_peer(peer_id)
		return

	# Validate username
	if not Protocol.validate_username(username):
		print("[Server] ✗ Invalid username, rejecting")
		var response = Packets.encode_handshake_response(
			-1, false,
			"Invalid username. Must be 3-20 alphanumeric characters."
		)
		_send_to_peer(peer_id, response)
		return

	# Create player
	var player = player_manager.create_player(peer_id, username)
	print("[Server] ✓ Player '", username, "' joined (ID: ", peer_id, ")")

	# Send success response
	var response = Packets.encode_handshake_response(peer_id, true, "Welcome to Vitaverse!")
	_send_to_peer(peer_id, response)

	# Notify other players
	_broadcast_packet_except(
		Packets.encode_player_spawn(peer_id, username, player.position),
		peer_id
	)

	# Send existing players to new player
	for existing_player in player_manager.get_all_players():
		if existing_player.id != peer_id:
			_send_to_peer(peer_id, Packets.encode_player_spawn(
				existing_player.id,
				existing_player.username,
				existing_player.position
			))

## Handle player movement
func _handle_player_move(packet: Dictionary, peer_id: int) -> void:
	var player = player_manager.get_player(peer_id)
	if not player:
		return

	var pos = packet.get("pos", [0, 0])
	var vel = packet.get("vel", [0, 0])

	player.position = Vector2(pos[0], pos[1])
	player.velocity = Vector2(vel[0], vel[1])

	# Server validates and updates
	# State is broadcast in _broadcast_game_state()

## Handle tile building
func _handle_build_tile(packet: Dictionary, peer_id: int) -> void:
	var world_x = packet.get("world_x", 0.0)
	var world_y = packet.get("world_y", 0.0)
	var tile_id = packet.get("tile_id", 0)

	var world_pos = Vector2(world_x, world_y)
	var chunk_pos = WorldConstants.world_to_chunk(world_pos)
	var local_pos = WorldConstants.world_to_local_tile(world_pos)

	# Validate tile type
	if not TileDefinitions.tile_properties.has(tile_id):
		return

	# Get or create chunk
	var chunk = chunk_manager.get_or_create_chunk(chunk_pos)

	# Set tile
	chunk.set_tile(local_pos.x, local_pos.y, tile_id)

	# Broadcast to all players
	_broadcast_packet(Packets.encode_tile_update(
		chunk_pos.x, chunk_pos.y,
		local_pos.x, local_pos.y,
		tile_id
	))

	if Config.is_debug_mode():
		print("[Server] Tile built at (", world_x, ", ", world_y, "): ", TileDefinitions.get_tile_name(tile_id))

## Handle tile destruction
func _handle_destroy_tile(packet: Dictionary, peer_id: int) -> void:
	var world_x = packet.get("world_x", 0.0)
	var world_y = packet.get("world_y", 0.0)

	var world_pos = Vector2(world_x, world_y)
	var chunk_pos = WorldConstants.world_to_chunk(world_pos)
	var local_pos = WorldConstants.world_to_local_tile(world_pos)

	var chunk = chunk_manager.get_chunk(chunk_pos)
	if not chunk:
		return

	# Set to void
	chunk.set_tile(local_pos.x, local_pos.y, TileDefinitions.TileType.VOID)

	# Broadcast to all players
	_broadcast_packet(Packets.encode_tile_update(
		chunk_pos.x, chunk_pos.y,
		local_pos.x, local_pos.y,
		TileDefinitions.TileType.VOID
	))

## Handle chunk request
func _handle_chunk_request(packet: Dictionary, peer_id: int) -> void:
	var chunk_x = packet.get("chunk_x", 0)
	var chunk_y = packet.get("chunk_y", 0)

	var chunk = chunk_manager.get_or_create_chunk(Vector2i(chunk_x, chunk_y))
	_send_to_peer(peer_id, Packets.encode_chunk_data(chunk))

## Handle chat message
func _handle_chat_message(packet: Dictionary, peer_id: int) -> void:
	var message = packet.get("message", "")
	var player = player_manager.get_player(peer_id)

	if not player:
		return

	# Sanitize message
	message = Protocol.sanitize_chat_message(message)

	if message.is_empty():
		return

	print("[Chat] <", player.username, "> ", message)

	# Broadcast to all players
	_broadcast_packet(Packets.encode_chat_broadcast(peer_id, player.username, message))

## Handle ping
func _handle_ping(packet: Dictionary, peer_id: int) -> void:
	var timestamp = packet.get("timestamp", 0)
	_send_to_peer(peer_id, Packets.encode_pong(timestamp))

## ============================================================================
## Utility Functions
## ============================================================================

## Send packet to specific peer
func _send_to_peer(peer_id: int, packet: Dictionary) -> void:
	rpc_id(peer_id, "receive_packet_from_server", Packets.to_json(packet))

## Broadcast packet to all peers
func _broadcast_packet(packet: Dictionary) -> void:
	for peer_id in multiplayer.get_peers():
		_send_to_peer(peer_id, packet)

## Broadcast packet to all except one peer
func _broadcast_packet_except(packet: Dictionary, except_peer_id: int) -> void:
	for peer_id in multiplayer.get_peers():
		if peer_id != except_peer_id:
			_send_to_peer(peer_id, packet)

## Shutdown server gracefully
func shutdown() -> void:
	print("\n[Server] Shutting down...")

	# Save world
	chunk_manager.save_all_chunks()

	# Disconnect all players
	for peer_id in multiplayer.get_peers():
		_send_to_peer(peer_id, Packets.encode_disconnect("Server shutting down"))
		peer.disconnect_peer(peer_id)

	is_running = false
	print("[Server] ✓ Shutdown complete")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown()
		get_tree().quit()
