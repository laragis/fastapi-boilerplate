from fastapi import APIRouter, HTTPException, status

from app.models import geofencing_models
from app.services import geofencing_services

router = APIRouter()

@router.post("/v1")
def geofencing(model: geofencing_models.RequestModel):
    """
    This function performs geofencing checks based on provided radius or geometry.
    It creates an area from the given parameters and checks if the points fall within the area.

    Parameters:
    model (geofencing_models.RequestModel): An instance of the RequestModel containing the following attributes:
        - radius (float): The radius of the area to be created.
        - geom (str): The geometry string representing the area.
        - lon (float): The longitude coordinate for creating an area from radius.
        - lat (float): The latitude coordinate for creating an area from radius.
        - points (List[Tuple[float, float]]): A list of tuples representing the points to be checked.

    Returns:
    dict: A dictionary containing the HTTP status code, message, and data.
        - code (int): The HTTP status code (200 for success, 400 for bad request).
        - message (str): A message indicating the result of the geofencing check.
        - data (dict): A dictionary containing the results of the geofencing check.
    """
    if not (model.radius or model.geom):
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            {"code": status.HTTP_400_BAD_REQUEST, "message": "Radius or geom must be provided", "data": None},
        )

    if model.radius:
        if not (model.lon and model.lat):
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                {"code": status.HTTP_400_BAD_REQUEST, "message": "Lon, lat must be provided", "data": None},
            )
        area = geofencing_services.create_area_from_radius(model.lon, model.lat, model.radius)
    elif model.geom:
        area = geofencing_services.create_area_from_geom(model.geom)

    if not area:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            {"code": status.HTTP_400_BAD_REQUEST, "message": "Invalid geometry", "data": None},
        )

    data = geofencing_services.check_points_inside_area(model.points, area)

    return {"code": status.HTTP_200_OK, "message": "Geofencing check passed", "data": data}

