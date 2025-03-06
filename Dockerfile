# syntax=docker/dockerfile:1  # Enable Docker BuildKit features
# Keep this syntax directive! It's used to enable Docker BuildKit

########################################################
# BUILDER
# Used to build deps + create our virtual environment
########################################################
ARG BASE_IMAGE=ttungbmt/python:3.11-slim
FROM ${BASE_IMAGE} AS builder

ARG APP_PATH=/app
ARG POETRY_INSTALL_OPTS='--no-root --only main'

# Set the working directory inside the container
WORKDIR ${APP_PATH}

COPY poetry.lock pyproject.toml ./

# Install dependencies with Poetry, caching downloaded packages
RUN --mount=type=cache,target=/root/.cache \
    poetry install ${POETRY_INSTALL_OPTS}

########################################################
# RUNNER
########################################################
FROM builder AS runner

ARG APP_PORT=8000
ENV APP_PORT=${APP_PORT}

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
EXPOSE ${APP_PORT}

########################################################
# DEVELOPMENT
# Image used during development / testing
########################################################
FROM runner AS development

ENV APP_ENV=development

# Not installing the app itself in the venv to keep venv and app in separate paths
ARG POETRY_INSTALL_OPTS='--no-root'

# Install system tools and libraries.
# Utilize --mount flag of Docker Buildx to cache downloaded packages, avoiding repeated downloads
RUN --mount=type=cache,id=apt-build,target=/var/cache/apt \
    apt-get update && \ 
    apt-get install -y --no-install-recommends \
        tmux \
        zsh

# Set the working directory inside the container
WORKDIR ${APP_PATH}

# Quicker install as runtime deps are already installed
RUN --mount=type=cache,target=/root/.cache \
    poetry install ${POETRY_INSTALL_OPTS}

# ENTRYPOINT ["/entrypoint.sh"]

# Run the FastAPI application using uvicorn server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

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

ENV APP_ENV=production

# Set the working directory inside the container
WORKDIR ${APP_PATH}

# Add a non-root user to prevent files being created with root permissions on host machine.
ENV PUID=1000
ENV PGID=1000

# Switch to user
RUN chown -R ${PUID}:${PGID} ./
USER ${PUID}:${PGID}

# ENTRYPOINT ["/entrypoint.sh"]

# Run the FastAPI application using uvicorn server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]