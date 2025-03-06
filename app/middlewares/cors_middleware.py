from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


def add(app: FastAPI) -> None:
    """
    Adds a CORS middleware to the FastAPI application.

    The CORS middleware allows cross-origin requests to be made from any origin.
    It sets the appropriate headers to enable CORS for all origins, credentials, methods, and headers.

    Parameters:
    - app (FastAPI): The FastAPI application to which the middleware will be added.

    Returns:
    - None: The function does not return any value.
    """
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
