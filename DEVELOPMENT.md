# Development Guide

Complete guide for developing Vitaverse locally.

## Prerequisites

### Required Software

| Tool | Version | Download |
|------|---------|----------|
| Godot | 4.2+ | https://godotengine.org/download |
| Python | 3.9+ | https://www.python.org/downloads/ |
| Git | Latest | https://git-scm.com/downloads |

### Optional Tools

- **VS Code** with Godot extension (recommended)
- **Docker** for infrastructure testing
- **PostgreSQL** for database development

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/vitaverse.git
cd vitaverse
```

### 2. Run Setup Script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

This will:
- ✅ Check for required dependencies
- ✅ Install Python packages
- ✅ Download free asset packs
- ✅ Initialize database structure

### 3. Verify Installation

```bash
# Check Godot
godot --version
# Should output: 4.x.x.stable.official

# Check Python packages
pip list | grep world-importer
# Should show: world-importer 0.1.0
```

## Running the Game

### Option 1: Quick Start (Recommended)

```bash
./scripts/run_local.sh
```

This runs both server and client in the background.

### Option 2: Separate Terminals

**Terminal 1 - Server:**
```bash
cd packages/godot-game
godot --headless server/server_main.tscn
```

**Terminal 2 - Client:**
```bash
cd packages/godot-game
godot client/scenes/game_world.tscn
```

### Option 3: Godot Editor (Best for Development)

1. Open Godot
2. Click "Import"
3. Select `packages/godot-game/project.godot`
4. Press **F5** to run client
5. In another terminal: `godot --headless server/server_main.tscn`

## Development Workflow

### Daily Development Loop

```bash
# 1. Pull latest changes
git pull origin main

# 2. Start server in background
cd packages/godot-game
godot --headless server/server_main.tscn &

# 3. Open Godot Editor
godot

# 4. Make changes, test with F5

# 5. When done, kill server
pkill -f "godot.*server_main"
```

### Making Changes

#### Client Code
1. Edit files in `packages/godot-game/client/`
2. Press **F5** in Godot Editor to test
3. Changes are hot-reloaded

#### Server Code
1. Edit files in `packages/godot-game/server/`
2. Restart server: `pkill -f godot; godot --headless server/server_main.tscn`
3. Reconnect client

#### Shared Code
1. Edit files in `packages/godot-game/shared/`
2. Restart both client and server
3. Critical: These changes affect both!

## Common Development Tasks

### Adding a New Tile Type

**1. Define tile in `shared/world/tile_definitions.gd`:**
```gdscript
enum TileType {
    GRASS = 1,
    WATER = 2,
    NEW_TILE = 3,  # Add here
}
```

**2. Add sprite to tileset:**
- Place image in `client/assets/tilesets/`
- Open `client/assets/tilesets/world_tileset.tres` in Godot
- Add new tile with ID matching `TileType` enum

**3. Test:**
```gdscript
# In editor mode, place the new tile
world_renderer.set_tile(position, TileType.NEW_TILE)
```

### Creating a New Network Packet

**1. Add to `shared/network/packets.gd`:**
```gdscript
enum PacketType {
    PLAYER_MOVE = 0,
    NEW_PACKET = 1,  # Add here
}

static func encode_new_packet(data) -> Dictionary:
    return {
        "type": PacketType.NEW_PACKET,
        "data": data,
        "timestamp": Time.get_ticks_msec()
    }
```

**2. Handle on server (`server/scripts/game_server.gd`):**
```gdscript
func _handle_packet(packet: Dictionary, player_id: int):
    match packet.type:
        Packets.PacketType.NEW_PACKET:
            _handle_new_packet(packet, player_id)
```

**3. Handle on client (`client/scripts/network_client.gd`):**
```gdscript
func _on_packet_received(packet: Dictionary):
    match packet.type:
        Packets.PacketType.NEW_PACKET:
            _handle_new_packet(packet)
```

### Importing World Data

```bash
# Import Seattle downtown
cd packages/world-importer
python -m world_importer import \
    --lat 47.6062 \
    --lon -122.3321 \
    --radius 2 \
    --output ../godot-game/server/data/world/

# Or use the helper script
cd ../..
./scripts/import_seattle.sh
```

## Testing

### Running Tests

```bash
# Run all Godot tests
cd packages/godot-game
godot --headless -s tests/test_chunk_streaming.gd

# Run Python tests
cd packages/world-importer
pytest tests/
```

### Manual Testing Checklist

- [ ] Player can move in all directions
- [ ] Client connects to server successfully
- [ ] Chunks load when player moves
- [ ] Tiles can be placed and destroyed
- [ ] Changes persist after reconnecting
- [ ] Multiple clients can connect simultaneously

## Debugging

### Server Debugging

```bash
# Run server with verbose logging
cd packages/godot-game
godot --headless --verbose server/server_main.tscn
```

**Look for:**
- `[SERVER] Player connected: <id>`
- `[SERVER] Chunk loaded: (x, y)`
- `[SERVER] Tile updated: (x, y) -> tile_id`

### Client Debugging

Press **F12** in Godot Editor to open debugger while game is running.

**Useful breakpoints:**
- `client/scripts/network_client.gd:_on_packet_received()`
- `client/scripts/world_renderer.gd:render_chunk()`
- `client/scripts/player_controller.gd:_physics_process()`

### Network Debugging

```bash
# Monitor WebSocket traffic (requires wscat)
npm install -g wscat
wscat -c ws://localhost:9000
```

## Building for Distribution

### Web Build

```bash
cd packages/godot-game
godot --headless --export-release "Web" build/web/index.html

# Test locally
cd build/web
python -m http.server 8080
# Visit http://localhost:8080
```

### macOS Build

```bash
cd packages/godot-game
godot --headless --export-release "macOS" build/Vitaverse.app
```

### Server Build

```bash
cd packages/godot-game
godot --headless --export-release "Linux/X11" build/server/vitaverse-server

# Deploy to Linux mini PC
scp -r build/server/ user@minipc:/opt/vitaverse/
ssh user@minipc "cd /opt/vitaverse && ./vitaverse-server"
```

## Performance Profiling

### Client Performance

In Godot Editor:
1. Run game (F5)
2. Debug → Profiler
3. Look for frame time spikes
4. Optimize hot code paths

**Common bottlenecks:**
- Too many chunks loaded
- Inefficient rendering
- Network packet parsing

### Server Performance

```gdscript
# Add to server/scripts/game_server.gd
func _process(delta):
    var start = Time.get_ticks_usec()

    # Your server logic here
    world_manager.update(delta)

    var elapsed = Time.get_ticks_usec() - start
    if elapsed > 16000:  # 16ms = 60 FPS target
        print("WARNING: Slow tick: ", elapsed / 1000.0, "ms")
```

## Troubleshooting

### Server won't start

```bash
# Check if port is already in use
lsof -i :9000

# Kill existing server
pkill -f "godot.*server"
```

### Client can't connect

1. Check server is running: `ps aux | grep godot`
2. Check firewall settings
3. Verify port in `shared/config.gd` matches server

### Chunks not loading

1. Check server logs for errors
2. Verify chunk files exist: `ls packages/godot-game/server/data/world/chunks/`
3. Check chunk coordinates are correct

### World importer fails

```bash
# Verify Python dependencies
pip install -r packages/world-importer/requirements.txt

# Test OSM connection
curl "https://overpass-api.de/api/status"
```

## Best Practices

### Code Style

```gdscript
# Use clear variable names
var player_position: Vector2  # Good
var pp: Vector2  # Bad

# Add type hints
func update_chunk(chunk: Chunk) -> void:
    pass

# Comment complex logic
# Calculate chunk coordinates from world position
# World (1024, 512) → Chunk (32, 16)
var chunk_x = floor(world_x / CHUNK_SIZE)
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-system

# Make changes, commit often
git add .
git commit -m "Add new system"

# Push and create PR
git push origin feature/new-system
```

### Documentation

- **Always update README** when adding features
- **Comment non-obvious code**
- **Update ARCHITECTURE.md** for system changes

## Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [OpenStreetMap Wiki](https://wiki.openstreetmap.org/)

## Getting Help

1. Check [docs/](docs/) folder
2. Search GitHub issues
3. Ask in Discord (coming soon)

---

**Happy developing! 🚀**
