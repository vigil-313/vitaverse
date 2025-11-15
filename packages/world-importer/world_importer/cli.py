"""
Command-line interface for world importer
"""

import click
from .osm_fetcher import OSMFetcher, SEATTLE_DOWNTOWN, AMAZON_SLU
from .tile_converter import TileConverter
from .chunk_writer import ChunkWriter


@click.group()
@click.version_option(version="0.1.0")
def main():
    """Vitaverse World Importer - Import real-world data into Vitaverse"""
    pass


@main.command()
@click.option("--lat", type=float, required=True, help="Center latitude")
@click.option("--lon", type=float, required=True, help="Center longitude")
@click.option("--radius", type=float, default=1.0, help="Radius in kilometers")
@click.option(
    "--output",
    type=click.Path(),
    default="../godot-game/server/data/world/chunks",
    help="Output directory for chunks",
)
def import_area(lat: float, lon: float, radius: float, output: str):
    """Import an area from OpenStreetMap"""
    click.echo(f"Importing area at ({lat}, {lon}) with radius {radius}km...")

    # Fetch OSM data
    fetcher = OSMFetcher()
    osm_data = fetcher.fetch_area(lat, lon, radius)

    click.echo(f"Fetched {len(osm_data['ways'])} ways and {len(osm_data['nodes'])} nodes")

    # Convert to chunks
    converter = TileConverter()
    chunks = converter.osm_to_chunks(osm_data)

    click.echo(f"Converted to {len(chunks)} chunks")

    # Write to disk
    writer = ChunkWriter(output)
    count = writer.write_chunks(chunks)

    click.echo(f"✓ Successfully imported {count} chunks to {output}")


@main.command()
def import_seattle():
    """Import Seattle downtown to Amazon SLU (preset)"""
    click.echo("Importing Seattle downtown area...")

    # Calculate center point between downtown and Amazon SLU
    center_lat = (SEATTLE_DOWNTOWN["lat"] + AMAZON_SLU["lat"]) / 2
    center_lon = (SEATTLE_DOWNTOWN["lon"] + AMAZON_SLU["lon"]) / 2

    # Use 2km radius to cover the area
    radius = 2.0

    click.echo(f"Center: ({center_lat}, {center_lon}), Radius: {radius}km")

    # Fetch OSM data
    fetcher = OSMFetcher()
    osm_data = fetcher.fetch_area(center_lat, center_lon, radius)

    click.echo(f"Fetched {len(osm_data['ways'])} ways and {len(osm_data['nodes'])} nodes")

    # Convert to chunks
    converter = TileConverter()
    chunks = converter.osm_to_chunks(osm_data)

    click.echo(f"Converted to {len(chunks)} chunks")

    # Write to disk
    writer = ChunkWriter()
    count = writer.write_chunks(chunks)

    click.echo(f"✓ Successfully imported Seattle! {count} chunks created.")
    click.echo("\nYou can now start the Vitaverse server and explore Seattle!")


@main.command()
@click.argument("lat", type=float)
@click.argument("lon", type=float)
def coords(lat: float, lon: float):
    """Get information about coordinates"""
    click.echo(f"Coordinates: ({lat}, {lon})")

    # Convert to world coordinates (relative to Seattle downtown)
    converter = TileConverter()
    world_x, world_y = converter.latlon_to_world(
        lat, lon, SEATTLE_DOWNTOWN["lat"], SEATTLE_DOWNTOWN["lon"]
    )

    click.echo(f"World coordinates: ({world_x:.1f}, {world_y:.1f})")

    chunk_x, chunk_y = converter.world_to_chunk(world_x, world_y)
    click.echo(f"Chunk coordinates: ({chunk_x}, {chunk_y})")


if __name__ == "__main__":
    main()
