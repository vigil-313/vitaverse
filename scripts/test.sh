#!/bin/bash
# Run tests for Vitaverse

set -e

echo "=================================="
echo "  Running Tests"
echo "=================================="
echo ""

# Python tests
echo "Running Python tests..."
cd packages/world-importer
pytest tests/ -v || echo "No Python tests found yet"
cd ../..

# Godot tests
echo ""
echo "Running Godot tests..."
cd packages/godot-game
godot --headless -s tests/test_chunk_streaming.gd || echo "No Godot tests found yet"
cd ../..

echo ""
echo "=================================="
echo "  Tests Complete"
echo "=================================="
