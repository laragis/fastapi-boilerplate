from shapely import Geometry, Point, buffer, within
from shapely.geometry import shape

from app.models import geofencing_models
from app.utils import transformer


def create_area_from_radius(lon: float, lat: float, radius: float) -> Geometry:
    """
    Create a circular geofence area from a given longitude, latitude, and radius.

    Parameters:
    lon (float): The longitude of the center point of the geofence area.
    lat (float): The latitude of the center point of the geofence area.
    radius (float): The radius of the circular geofence area in meters.

    Returns:
    Geometry: A Shapely Geometry object representing the circular geofence area.
    """
    center_pt = transformer.transform_to_mecator(Point(lon, lat))
    return transformer.transform_from_mecator(buffer(center_pt, radius))


def create_area_from_geom(geom: geofencing_models.PolygonFeatureModel) -> Geometry:
    """
    Create a geofence area from a given polygon geometry.

    Parameters:
    geom (geofencing_models.PolygonFeatureModel): A PolygonFeatureModel object containing the polygon geometry.
        The PolygonFeatureModel object should have a 'geometry' attribute, which is a dictionary representing the polygon.

    Returns:
    Geometry: A Shapely Geometry object representing the geofence area.
        The returned Geometry object can be used for geometric operations such as checking if points are within the area.
    """
    return shape(geom.geometry)


def check_points_inside_area(points: list[geofencing_models.GeofencePoint], area: Geometry) -> list:
    """
    Check if a list of points are within a given geofence area.

    This function takes a list of points and a geofence area as input,
    and returns a list of dictionaries indicating whether each point is inside the area.

    Parameters:
    points (list[geofencing_models.GeofencePoint]): A list of GeofencePoint objects representing the points to be checked.
        Each GeofencePoint object should have 'lon' and 'lat' attributes representing the longitude and latitude of the point.
    area (Geometry): A Shapely Geometry object representing the geofence area.
        The Geometry object can be created using the create_area_from_radius or create_area_from_polygon functions.

    Returns:
    list: A list of dictionaries. Each dictionary contains the 'id' of the point and a boolean value indicating whether the point is inside the area.
        The 'id' is obtained from the 'id' attribute of the GeofencePoint object.
        The boolean value is True if the point is inside the area, and False otherwise.
    """
    data: list = []

    for geom in points:
        pt = Point(geom.lon, geom.lat)
        is_inside = within(pt, area)
        data.append({"id": geom.id, "is_inside": bool(is_inside)})

    return data
