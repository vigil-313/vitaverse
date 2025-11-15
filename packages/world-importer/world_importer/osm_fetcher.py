"""
OpenStreetMap data fetcher

Fetches map data from OpenStreetMap using the Overpass API.
"""

import overpy
from typing import Optional, Dict, Any


class OSMFetcher:
    """Fetches OpenStreetMap data via Overpass API"""

    def __init__(self, timeout: int = 180):
        """
        Initialize OSM fetcher

        Args:
            timeout: API request timeout in seconds
        """
        self.api = overpy.Overpass()
        self.timeout = timeout

    def fetch_area(
        self,
        lat: float,
        lon: float,
        radius_km: float = 1.0,
        include_buildings: bool = True,
        include_roads: bool = True,
        include_natural: bool = True,
    ) -> Dict[str, Any]:
        """
        Fetch map data for a circular area

        Args:
            lat: Latitude (center point)
            lon: Longitude (center point)
            radius_km: Radius in kilometers
            include_buildings: Include building data
            include_roads: Include road/highway data
            include_natural: Include natural features (trees, water, etc.)

        Returns:
            Dictionary containing OSM data organized by type
        """
        radius_m = radius_km * 1000

        query_parts = []

        if include_buildings:
            query_parts.append(f'way(around:{radius_m},{lat},{lon})["building"];')

        if include_roads:
            query_parts.append(f'way(around:{radius_m},{lat},{lon})["highway"];')

        if include_natural:
            query_parts.append(f'way(around:{radius_m},{lat},{lon})["natural"];')
            query_parts.append(f'node(around:{radius_m},{lat},{lon})["natural"="tree"];')

        query = f"""
        [out:json][timeout:{self.timeout}];
        (
            {''.join(query_parts)}
        );
        (._;>;);
        out body;
        """

        print(f"[OSMFetcher] Fetching data for ({lat}, {lon}) radius {radius_km}km...")
        result = self.api.query(query)

        return {
            "center": {"lat": lat, "lon": lon},
            "radius_km": radius_km,
            "ways": result.ways,
            "nodes": result.nodes,
            "relations": result.relations,
        }

    def fetch_bbox(
        self,
        min_lat: float,
        min_lon: float,
        max_lat: float,
        max_lon: float,
    ) -> Dict[str, Any]:
        """
        Fetch map data for a bounding box

        Args:
            min_lat: Minimum latitude (south)
            min_lon: Minimum longitude (west)
            max_lat: Maximum latitude (north)
            max_lon: Maximum longitude (east)

        Returns:
            Dictionary containing OSM data
        """
        query = f"""
        [out:json][timeout:{self.timeout}];
        (
            way({min_lat},{min_lon},{max_lat},{max_lon})["building"];
            way({min_lat},{min_lon},{max_lat},{max_lon})["highway"];
            way({min_lat},{min_lon},{max_lat},{max_lon})["natural"];
            node({min_lat},{min_lon},{max_lat},{max_lon})["natural"="tree"];
        );
        (._;>;);
        out body;
        """

        print(f"[OSMFetcher] Fetching bbox ({min_lat}, {min_lon}) to ({max_lat}, {max_lon})...")
        result = self.api.query(query)

        return {
            "bbox": {
                "min_lat": min_lat,
                "min_lon": min_lon,
                "max_lat": max_lat,
                "max_lon": max_lon,
            },
            "ways": result.ways,
            "nodes": result.nodes,
            "relations": result.relations,
        }


# Seattle coordinates for quick reference
SEATTLE_DOWNTOWN = {"lat": 47.6062, "lon": -122.3321}
AMAZON_SLU = {"lat": 47.6205, "lon": -122.3365}
