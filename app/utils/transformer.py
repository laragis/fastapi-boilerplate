from pyproj import Transformer
from shapely import Geometry
from shapely.ops import transform

to_mercator = Transformer.from_crs("EPSG:4326", "EPSG:3857", always_xy=True)
from_mercator = Transformer.from_crs("EPSG:3857", "EPSG:4326", always_xy=True)


@staticmethod
def transform_to_mecator(geometry: Geometry) -> Geometry:
    """
    Transforms a given geometry from WGS84 (EPSG:4326) to Web Mercator (EPSG:3857) projection.

    Parameters:
    geometry (Geometry): The input geometry to be transformed. It should be a Shapely Geometry object.

    Returns:
    Geometry: The transformed geometry in Web Mercator projection.
    """
    transformed_geometry = transform(to_mercator.transform, geometry)
    return transformed_geometry


@staticmethod
def transform_from_mecator(geometry: Geometry) -> Geometry:
    """
    Transforms a given geometry from Web Mercator (EPSG:3857) to WGS84 (EPSG:4326) projection.

    Parameters:
    geometry (Geometry): The input geometry to be transformed. It should be a Shapely Geometry object.

    Returns:
    Geometry: The transformed geometry in WGS84 projection.
    """
    transformed_geometry = transform(from_mercator.transform, geometry)
    return transformed_geometry
