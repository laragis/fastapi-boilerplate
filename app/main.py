from fastapi import FastAPI
from rich.traceback import install

from app.api import v1
from app.middlewares import cors_middleware
from app.utils import lifespan
from app.configs import app_settings

app = FastAPI(lifespan=lifespan.lifespan)

cors_middleware.add(app)

app.include_router(v1.api_v1_router)

if app_settings.APP_ENV == "development":
    install(show_locals=True)
