"""
Chunk writer

Writes chunks to Vitaverse game format (JSON files).
"""

import json
import os
from typing import Dict, List, Tuple
from pathlib import Path


class ChunkWriter:
    """Writes chunks to game-compatible format"""

    def __init__(self, output_dir: str = "../godot-game/server/data/world/chunks"):
        """
        Initialize chunk writer

        Args:
            output_dir: Directory to write chunk files
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def write_chunks(self, chunks: Dict[Tuple[int, int], List[List[int]]]) -> int:
        """
        Write chunks to disk

        Args:
            chunks: Dictionary mapping (chunk_x, chunk_y) to 2D tile array

        Returns:
            Number of chunks written
        """
        count = 0

        for (chunk_x, chunk_y), tiles_2d in chunks.items():
            self.write_chunk(chunk_x, chunk_y, tiles_2d)
            count += 1

        print(f"[ChunkWriter] Wrote {count} chunks to {self.output_dir}")
        return count

    def write_chunk(self, chunk_x: int, chunk_y: int, tiles_2d: List[List[int]]) -> None:
        """
        Write a single chunk to disk

        Args:
            chunk_x: Chunk X coordinate
            chunk_y: Chunk Y coordinate
            tiles_2d: 2D array of tile IDs [y][x]
        """
        # Flatten 2D array to 1D (matches Godot format)
        tiles_1d = []
        for row in tiles_2d:
            tiles_1d.extend(row)

        # Create chunk data structure (matches Chunk.to_dict() in Godot)
        chunk_data = {
            "chunk_x": chunk_x,
            "chunk_y": chunk_y,
            "tiles": tiles_1d,
            "created_at": int(__import__("time").time()),
            "modified_at": int(__import__("time").time()),
            "name": f"Imported chunk ({chunk_x}, {chunk_y})",
        }

        # Write to JSON file
        filename = f"chunk_{chunk_x}_{chunk_y}.json"
        filepath = self.output_dir / filename

        with open(filepath, "w") as f:
            json.dump(chunk_data, f, indent=2)

        print(f"[ChunkWriter] Wrote chunk ({chunk_x}, {chunk_y}) to {filename}")

    def get_chunk_path(self, chunk_x: int, chunk_y: int) -> Path:
        """Get path for a chunk file"""
        return self.output_dir / f"chunk_{chunk_x}_{chunk_y}.json"

    def chunk_exists(self, chunk_x: int, chunk_y: int) -> bool:
        """Check if chunk file already exists"""
        return self.get_chunk_path(chunk_x, chunk_y).exists()
