# Vitaverse - Godot Game

Main game client and server built with Godot 4.

## Structure

```
godot-game/
├── client/          # Player-facing game client
│   ├── scenes/      # Game scenes (.tscn files)
│   ├── scripts/     # Client-side scripts
│   └── assets/      # Graphics, audio, fonts
├── server/          # Authoritative game server
│   ├── scripts/     # Server-side scripts
│   ├── data/        # Saved world data
│   └── server_main.tscn
├── shared/          # Code used by both client & server
│   ├── world/       # World data structures
│   ├── entities/    # Player, NPCs, etc.
│   └── network/     # Network protocol
└── tests/           # Unit tests
```

## Development

### Opening in Godot Editor

```bash
cd packages/godot-game
godot
# Or: godot project.godot
```

### Running Client

**Option 1: In Editor**
- Press **F5** to run the client

**Option 2: Command Line**
```bash
godot client/scenes/game_world.tscn
```

### Running Server

```bash
godot --headless server/server_main.tscn
```

### Running Both (Local Multiplayer Testing)

```bash
# From repository root
./scripts/run_local.sh
```

## Configuration

### Game Settings

Edit `shared/config.gd`:

```gdscript
# Change environment
Config.set_environment(Config.Environment.PRODUCTION)

# Or via environment variable
export VITAVERSE_ENV=production
godot --headless server/server_main.tscn
```

### Input Controls

Configured in `project.godot`:
- **WASD**: Movement
- **E**: Toggle editor mode (future)
- **Mouse Left**: Interact/build

## Exporting

### Web (WASM)

```bash
godot --headless --export-release "Web" build/web/index.html

# Test locally
cd build/web
python -m http.server 8000
# Visit http://localhost:8000
```

### macOS

```bash
godot --headless --export-release "macOS" build/Vitaverse.app
```

### Linux Server (Headless)

```bash
godot --headless --export-release "Linux Server" build/server/vitaverse-server
```

## Code Organization

### Client Scripts

| File | Purpose |
|------|---------|
| `network_client.gd` | Connects to server, handles packets |
| `player_controller.gd` | Local player movement and input |
| `camera_controller.gd` | Camera following and zoom |
| `world_renderer.gd` | Renders chunks using TileMap |

### Server Scripts

| File | Purpose |
|------|---------|
| `game_server.gd` | Main server entry point |
| `player_manager.gd` | Manages connected players |
| `world_manager.gd` | World simulation (time, weather, etc.) |
| `chunk_manager.gd` | Chunk loading, saving, streaming |

### Shared Scripts

| File | Purpose |
|------|---------|
| `shared/world/chunk.gd` | Chunk data structure |
| `shared/world/tile_definitions.gd` | Tile types and properties |
| `shared/network/packets.gd` | Network packet definitions |
| `shared/network/protocol.gd` | Protocol utilities |
| `shared/entities/player.gd` | Player entity data |

## Network Protocol

### Client → Server

- `HANDSHAKE` - Initial connection with username
- `PLAYER_MOVE` - Movement input
- `BUILD_TILE` - Place a tile
- `DESTROY_TILE` - Remove a tile
- `CHUNK_REQUEST` - Request chunk data
- `CHAT_MESSAGE` - Send chat

### Server → Client

- `HANDSHAKE_RESPONSE` - Connection accepted/rejected
- `CHUNK_DATA` - Full chunk data
- `TILE_UPDATE` - Single tile changed
- `PLAYER_SPAWN` - New player joined
- `PLAYER_STATE` - Other player's position/velocity
- `CHAT_BROADCAST` - Chat message from another player

See `shared/network/packets.gd` for full protocol documentation.

## World Data

### Chunk Storage

Chunks are saved to `server/data/world/chunks/` as JSON files:

```json
{
  "chunk_x": 0,
  "chunk_y": 0,
  "tiles": [1, 1, 1, ...],  // 1024 tile IDs (32×32)
  "created_at": 1700000000,
  "modified_at": 1700000100,
  "name": "Downtown Seattle"
}
```

### Tile IDs

Defined in `shared/world/tile_definitions.gd`:

| ID | Name | Walkable | Destructible |
|----|------|----------|--------------|
| 0 | Void | Yes | No |
| 1 | Grass | Yes | Yes |
| 2 | Dirt | Yes | Yes |
| 5 | Water | No | No |
| 51 | Tree (Oak) | No | Yes |
| 101 | Road (Asphalt) | Yes | Yes |
| 151 | Wall (Brick) | No | Yes |

## Testing

### Unit Tests

```bash
godot --headless -s tests/test_chunk_streaming.gd
```

### Manual Testing

1. Start server: `godot --headless server/server_main.tscn`
2. Start client: Press F5 in Godot Editor
3. Test:
   - Player movement (WASD)
   - Camera follows player
   - Connection status shows in console

## Debugging

### Server Logs

```bash
godot --headless --verbose server/server_main.tscn
```

Look for:
- `[SERVER] Server started successfully`
- `[SERVER] Player connected: <id>`
- `[SERVER] Peer disconnected: <id>`

### Client Logs

Enable in `shared/config.gd`:
```gdscript
"verbose_logging": true
```

Press **F12** in editor to open debugger.

## Performance

### Target Metrics

- **Client**: 60 FPS (minimum 30 FPS on web)
- **Server**: 60 TPS (ticks per second)
- **Latency**: < 100ms player input to visual feedback
- **Memory**: < 500MB server with 1000 chunks loaded

### Optimization Tips

- Use `Config.is_debug_mode()` to disable debug rendering in production
- Limit chunk view radius for lower-end devices
- Use object pooling for entities
- Profile with Godot's built-in profiler (Debug → Profiler)

## Troubleshooting

### "Cannot find peer"

Client tried to connect but server isn't running. Start server first.

### "Connection timeout"

Check firewall settings. Server must allow connections on port 9000.

### "Protocol version mismatch"

Client and server versions don't match. Update both to same version.

### Chunks not rendering

- Check if TileMap is configured in `world_renderer.gd`
- Verify tileset is assigned
- Check console for chunk loading messages

## Resources

- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Networking Tutorial](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)

## Next Steps

1. ✅ Basic client-server connection
2. ✅ Player movement
3. ✅ Chunk streaming
4. ⏳ Tile rendering with TileMap
5. ⏳ Building/destroying tiles
6. ⏳ Multiple players visible to each other

See [../../docs/ROADMAP.md](../../docs/ROADMAP.md) for full development plan.
