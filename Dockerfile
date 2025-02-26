# syntax=docker/dockerfile:1  # Enable Docker BuildKit features
# Keep this syntax directive! It's used to enable Docker BuildKit

########################################################
# BASE
# Sets up all our shared environment variables
########################################################
ARG BASE_IMAGE=python:3.11.8-slim
FROM ${BASE_IMAGE} AS base

LABEL maintainer="Truong Thanh Tung <ttungbmt@gmail.com>"

ARG TZ=UTC
ARG APP_PATH=/app

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

# Set the timezone to UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PU=fastapi
ARG PG=fastapi
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ARG PGID=1000
ENV PGID ${PGID}

# RUN userdel -r ${PU}
RUN groupadd --force -g ${PGID} ${PG}
RUN useradd -u ${PUID} -g ${PG} -s /bin/bash -m ${PU}

# Install system tools and libraries.
# Utilize --mount flag of Docker Buildx to cache downloaded packages, avoiding repeated downloads
RUN --mount=type=cache,id=apt-build,target=/var/cache/apt \
    apt-get update && \ 
    apt-get install -y --no-install-recommends \
        curl \
        gettext

# Cleanup apt update lists to keep the image size small
RUN apt-get autoremove --purge &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables for Python and Poetry
ENV \
    # Python -----------------------------------
    # Ensures Python output is sent directly to the terminal
    PYTHONUNBUFFERED=1 \
    # Prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip --------------------------------------
    PIP_NO_CACHE_DIR=off \
    # Disables unnecessary version check for pip    
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    # Sets a timeout for pip operations to prevent hangs
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # Poetry -----------------------------------
    # Specifies the Poetry version to use
    POETRY_VERSION=$POETRY_VERSION \
    # Specifies the directory where Poetry is installed
    POETRY_HOME="/opt/poetry" \
    # Disables interactive prompts during Poetry installation
    POETRY_NO_INTERACTION=1 \
    # Instructs Poetry not to create virtual environments (since the container itself acts as an isolated environment)
    POETRY_VIRTUALENVS_CREATE=false \
    # Path to the virtual environment (created by Poetry)
    VIRTUAL_ENV="/venv"

# Prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VIRTUAL_ENV/bin:$PATH"

# Create and prepare the virtual environment
RUN python -m venv $VIRTUAL_ENV && \
    python -m pip install --upgrade pip
    # pip cache purge && rm -Rf /root/.cache/pip/http

ENV APP_PATH=${APP_PATH}

# Set the working directory inside the container
WORKDIR ${APP_PATH}

RUN mkdir -p ${APP_PATH}

########################################################
# BUILDER
# Used to build deps + create our virtual environment
########################################################
FROM base AS builder

ARG POETRY_VERSION=1.7.1
ARG POETRY_INSTALL_OPTS='--no-root --only main'

# Set environment variables for Poetry
ENV \
    # Poetry -----------------------------------
    # Specifies the Poetry version to use
    POETRY_VERSION=$POETRY_VERSION

# Install poetry - respects $POETRY_VERSION & $POETRY_HOME
# The --mount will mount the buildx cache directory to where
# Poetry and Pip store their cache so that they can re-use it
RUN --mount=type=cache,target=/root/.cache \
    curl -sSL https://install.python-poetry.org | python3 - && poetry --version && poetry config --list

# Set the working directory inside the container
WORKDIR ${APP_PATH}

COPY poetry.lock pyproject.toml ./

# Install dependencies with Poetry, caching downloaded packages
RUN --mount=type=cache,target=/root/.cache \
    poetry install ${POETRY_INSTALL_OPTS}

########################################################
# RUNNER
########################################################
FROM base AS runner

# Set the working directory inside the container
WORKDIR ${APP_PATH}

COPY --from=builder \
    ${APP_PATH}/poetry.lock \
    ${APP_PATH}/pyproject.toml \
    ./
# Copy in our built poetry + venv
COPY --from=builder $POETRY_HOME $POETRY_HOME
COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

# Copy the application code to the working directory
COPY . .

# Copying in our entrypoint
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the port the app runs on
EXPOSE 8000

########################################################
# DEVELOPMENT
# Image used during development / testing
########################################################
FROM runner AS development

# Not installing the app itself in the venv to keep venv and app in separate paths
ARG POETRY_INSTALL_OPTS='--no-root'

# Set the working directory inside the container
WORKDIR ${APP_PATH}

# Quicker install as runtime deps are already installed
RUN --mount=type=cache,target=/root/.cache \
    poetry install ${POETRY_INSTALL_OPTS}

ENTRYPOINT ["/entrypoint.sh"]

# Run the FastAPI application using uvicorn server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]

########################################################
# LINT
# Running in check mode means build will fail if any linting errors occur
########################################################
FROM development AS lint
RUN black --config ./pyproject.toml --check app tests
RUN isort --settings-path ./pyproject.toml --recursive --check-only
CMD ["tail", "-f", "/dev/null"]

########################################################
# TEST
# Build will fail if test coverage is under 95%
########################################################
FROM development AS test
RUN coverage run --rcfile ./pyproject.toml -m pytest ./tests
RUN coverage report --fail-under 95

########################################################
# PRODUCTION
# Final image used for runtime
########################################################
FROM runner AS production

# Set the working directory inside the container
WORKDIR ${APP_PATH}

# Switch to user
RUN chown -R ${PUID}:${PGID} ./

USER ${PUID}:${PGID}

ENTRYPOINT ["/entrypoint.sh"]

# Run the FastAPI application using uvicorn server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]