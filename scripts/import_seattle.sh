#!/bin/bash
# Import Seattle area using world-importer

set -e

echo "=================================="
echo "  Importing Seattle"
echo "=================================="
echo ""

# Check if world-importer is installed
if ! command -v world-importer &> /dev/null; then
    echo "Error: world-importer not found"
    echo "Run './scripts/setup.sh' first"
    exit 1
fi

echo "This will import Seattle downtown to Amazon SLU area"
echo "This may take 2-5 minutes depending on your connection..."
echo ""

# Run importer
world-importer import-seattle

echo ""
echo "=================================="
echo "  Import Complete!"
echo "=================================="
echo ""
echo "Chunks have been saved to:"
echo "  packages/godot-game/server/data/world/chunks/"
echo ""
echo "Start the server to explore Seattle:"
echo "  ./scripts/run_local.sh"
echo ""
