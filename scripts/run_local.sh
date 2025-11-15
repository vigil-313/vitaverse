#!/bin/bash
# Run Vitaverse client and server locally for development

set -e

echo "=================================="
echo "  Starting Vitaverse Locally"
echo "=================================="
echo ""

cd packages/godot-game

# Kill any existing Godot processes (cleanup from previous runs)
echo "Cleaning up any existing processes..."
pkill -f "godot.*server_main" 2>/dev/null || true
sleep 1

# Start server in background
echo "Starting server..."
godot --headless server/server_main.tscn &
SERVER_PID=$!
echo "  Server PID: $SERVER_PID"

# Wait for server to start
echo "Waiting for server to initialize..."
sleep 3

# Start client
echo "Starting client..."
godot client/scenes/game_world.tscn &
CLIENT_PID=$!
echo "  Client PID: $CLIENT_PID"

echo ""
echo "=================================="
echo "  Vitaverse is running!"
echo "=================================="
echo ""
echo "  Server PID: $SERVER_PID"
echo "  Client PID: $CLIENT_PID"
echo ""
echo "Press Ctrl+C to stop both processes"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo "Shutting down..."
    kill $SERVER_PID 2>/dev/null || true
    kill $CLIENT_PID 2>/dev/null || true
    echo "Stopped."
    exit 0
}

# Trap Ctrl+C
trap cleanup INT TERM

# Wait for processes
wait
