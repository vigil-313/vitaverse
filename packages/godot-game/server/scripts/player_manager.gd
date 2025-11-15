extends Node
class_name PlayerManager
## Manages all connected players
##
## Handles player creation, removal, and state management.

## Dictionary of all players: peer_id -> Player
var players: Dictionary = {}

## Next player spawn position (simple for now)
var next_spawn_position: Vector2 = Vector2.ZERO

## Create a new player
func create_player(peer_id: int, username: String) -> Player:
	var player = Player.new(peer_id, username)
	player.position = _get_spawn_position()
	players[peer_id] = player

	print("[PlayerManager] Created player: ", username, " (ID: ", peer_id, ")")
	return player

## Remove a player
func remove_player(peer_id: int) -> void:
	if players.has(peer_id):
		var player = players[peer_id]
		print("[PlayerManager] Removed player: ", player.username, " (ID: ", peer_id, ")")
		players.erase(peer_id)

## Get player by peer ID
func get_player(peer_id: int) -> Player:
	return players.get(peer_id, null)

## Get all players
func get_all_players() -> Array:
	return players.values()

## Get player count
func get_player_count() -> int:
	return players.size()

## Update all players
func update(delta: float) -> void:
	for player in players.values():
		player.update(delta)

		# TODO: Check for chunk transitions and update chunk manager
		# TODO: Check for player interactions
		# TODO: Check for health/death conditions

## Get all player states for broadcasting
func get_all_player_states() -> Array:
	var states = []
	for player in players.values():
		states.append({
			"player_id": player.id,
			"username": player.username,
			"position": player.position,
			"velocity": player.velocity,
			"health": player.health
		})
	return states

## Get spawn position for new player
func _get_spawn_position() -> Vector2:
	# For now, spawn players in a grid pattern
	# TODO: Later, use spawn markers from world data

	var spawn = next_spawn_position
	next_spawn_position.x += 100

	if next_spawn_position.x > 500:
		next_spawn_position.x = 0
		next_spawn_position.y += 100

	return spawn

## Save all player data (called on server shutdown)
func save_all_players() -> void:
	print("[PlayerManager] Saving all players...")

	var save_data = {
		"version": Version.GAME_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"players": {}
	}

	for peer_id in players:
		var player = players[peer_id]
		save_data["players"][str(peer_id)] = player.to_dict()

	# Save to file
	var file = FileAccess.open("user://players.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("[PlayerManager] ✓ Saved ", players.size(), " players")
	else:
		push_error("[PlayerManager] Failed to save players")

## Load player data (called on server startup)
func load_all_players() -> void:
	if not FileAccess.file_exists("user://players.json"):
		print("[PlayerManager] No saved players found")
		return

	print("[PlayerManager] Loading players...")

	var file = FileAccess.open("user://players.json", FileAccess.READ)
	if not file:
		push_error("[PlayerManager] Failed to open players.json")
		return

	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()

	if error != OK:
		push_error("[PlayerManager] Failed to parse players.json")
		return

	var save_data = json.data
	var player_data = save_data.get("players", {})

	for peer_id_str in player_data:
		var data = player_data[peer_id_str]
		var player = Player.from_dict(data)
		# Don't actually add to active players - they'll reconnect
		# This is just for persistent data

	print("[PlayerManager] ✓ Loaded player data")
