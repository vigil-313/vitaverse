# Vitaverse

> A living, breathing 2D multiplayer open-world simulator built with Godot 4

## 🌟 Vision

Vitaverse is a massively scalable virtual world where users can explore, build, and interact in a persistent, simulated environment. Starting with a faithful recreation of Seattle, we aim to expand to cities worldwide, eventually supporting AI agents as autonomous participants in this living universe.

**Key Features:**
- 🌍 Real-world city recreation using OpenStreetMap data
- 🎮 Cross-platform: Web, Desktop (Mac/Windows/Linux), Mobile
- 🔨 Fully destructible and buildable world
- 🤖 AI agent integration (future)
- 🏢 Virtual offices and collaborative spaces
- 🌱 Living world simulation (growth, decay, weather)

## 🚀 Quick Start

### Prerequisites
- [Godot 4.x](https://godotengine.org/download) installed
- Python 3.9+ installed
- Git installed

### Installation

```bash
# Clone the repository
git clone https://github.com/vigil-313/vitaverse.git
cd vitaverse

# Run setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Running Locally

```bash
# Start both client and server
./scripts/run_local.sh

# Or run separately:
# Terminal 1 - Server
cd packages/godot-game
godot --headless server/server_main.tscn

# Terminal 2 - Client
cd packages/godot-game
godot client/scenes/game_world.tscn
# OR press F5 in Godot Editor
```

## 📁 Project Structure

```
vitaverse/
├── packages/
│   ├── godot-game/          # Main game (Godot 4)
│   │   ├── client/          # Player-facing client
│   │   ├── server/          # Authoritative server
│   │   └── shared/          # Shared code
│   ├── world-importer/      # OSM import tools (Python)
│   └── infrastructure/      # Deployment configs
├── docs/                    # Documentation
└── scripts/                 # Development helpers
```

## 📚 Documentation

- **[Architecture Overview](docs/ARCHITECTURE.md)** - System design and technical details
- **[Development Guide](DEVELOPMENT.md)** - How to develop locally
- **[World Building](docs/WORLD_BUILDING.md)** - Creating world content
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Deploying to production
- **[API Reference](docs/API.md)** - Network protocol documentation
- **[Roadmap](docs/ROADMAP.md)** - Development timeline and goals

## 🛠️ Technology Stack

| Component | Technology |
|-----------|-----------|
| Game Engine | Godot 4.x (GDScript) |
| Server | Godot Headless |
| Database | SQLite → PostgreSQL |
| World Import | Python + OpenStreetMap |
| Deployment | Docker |
| Platforms | Web (WASM), macOS, Windows, Linux, iOS, Android |

## 🎯 Current Status

**Phase 1: Foundation** - In Progress
- ✅ Project structure established
- 🔄 Basic networking implementation
- 🔄 Chunk loading system
- 🔄 Player movement
- ⏳ Web + Mac builds

See [ROADMAP.md](docs/ROADMAP.md) for detailed progress.

## 🤝 Contributing

This project is currently in early development. Contribution guidelines will be added soon.

## 📝 License

Copyright © 2025 vigil-313. All Rights Reserved.

This project is proprietary software. No part of this software may be used, copied, modified, or distributed without prior written permission from the copyright holder. See [LICENSE](LICENSE) for full details.

## 🔗 Links

- Website: [Coming soon]
- Discord: [Coming soon]
- Documentation: [docs/](docs/)

---

**Built with ❤️ for creating living, persistent virtual worlds**
