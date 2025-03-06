from typing import Optional

from geojson_pydantic import Feature, Polygon
from pydantic import BaseModel, Field


PolygonFeatureModel = Feature[Polygon, dict]


class GeofencePoint(BaseModel):
    id: str = Field(..., description="Geometry center ID cannot be empty")
    lon: float = Field(..., ge=-180, le=180, description="Longitude must be between -180 and 180")
    lat: float = Field(..., ge=-90, le=90, description="Latitude must be between -90 and 90")


class RequestModel(BaseModel):
    points: list[GeofencePoint] = Field(..., min_length=1, description="Geometry centers cannot be empty")
    radius: Optional[int] = Field(None, gt=0)
    lon: Optional[float] = Field(None, ge=-180, le=180)
    lat: Optional[float] = Field(None, ge=-90, le=90)
    geom: Optional[PolygonFeatureModel] = None
