from fastapi import APIRouter
from app.controllers import geofencing_controller

api_v1_router = APIRouter(prefix="/v1")
api_v1_router.include_router(geofencing_controller.router)
