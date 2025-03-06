from fastapi import FastAPI
from rich.traceback import install

from app.middlewares import cors_middleware
from app.utils import lifespan
from app.configs import app_settings
from app.controllers import geofencing_controller

app = FastAPI(lifespan=lifespan.lifespan)

cors_middleware.add(app)

app.include_router(geofencing_controller.router)

if app_settings.APP_ENV == "development":
    install(show_locals=True)
