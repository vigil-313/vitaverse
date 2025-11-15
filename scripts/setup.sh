#!/bin/bash
# Initial setup script for Vitaverse development environment

set -e  # Exit on error

echo "=================================="
echo "  Vitaverse Setup"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Godot
echo "Checking for Godot..."
if command -v godot &> /dev/null; then
    GODOT_VERSION=$(godot --version 2>&1 | head -n 1)
    echo -e "${GREEN}✓ Godot found: $GODOT_VERSION${NC}"
else
    echo -e "${RED}✗ Godot not found${NC}"
    echo "  Please install Godot 4.x from https://godotengine.org/download"
    echo "  Make sure 'godot' command is in your PATH"
    exit 1
fi

# Check Python
echo "Checking for Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python found: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}✗ Python 3 not found${NC}"
    echo "  Please install Python 3.9+ from https://www.python.org/downloads/"
    exit 1
fi

# Check pip
echo "Checking for pip..."
if command -v pip3 &> /dev/null; then
    echo -e "${GREEN}✓ pip found${NC}"
else
    echo -e "${RED}✗ pip not found${NC}"
    echo "  Please install pip"
    exit 1
fi

# Install Python packages
echo ""
echo "Installing Python packages..."
cd packages/world-importer
pip3 install -e . || {
    echo -e "${RED}✗ Failed to install world-importer package${NC}"
    exit 1
}
cd ../..
echo -e "${GREEN}✓ Python packages installed${NC}"

# Create directories
echo ""
echo "Creating directories..."
mkdir -p packages/godot-game/server/data/world/chunks
mkdir -p packages/godot-game/server/data/players
mkdir -p packages/godot-game/build
echo -e "${GREEN}✓ Directories created${NC}"

# TODO: Download free assets
# This would download Kenney assets or other free packs
echo ""
echo -e "${YELLOW}⚠ Asset download not yet implemented${NC}"
echo "  You can manually download assets from:"
echo "  - https://kenney.nl/assets (free CC0 assets)"
echo "  - https://opengameart.org/"

echo ""
echo -e "${GREEN}=================================="
echo "  Setup Complete! ✓"
echo "==================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Run './scripts/run_local.sh' to start the game"
echo "  2. Or open the Godot project:"
echo "     cd packages/godot-game && godot"
echo ""
