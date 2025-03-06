# Setup Guide

## Prerequisites

Before setting up the project, ensure you have the following installed:

- Docker & Docker Compose
- Just (Command runner)
- Python 3.11+
- Poetry (Dependency management)

## 1. Init: Preparing the Environment

To initialize and install dependencies, run:

```sh
just init
```

This will:
- Create an `.env` file if it doesn't exist.
- Update the environment settings based on the mode.
- Check and generate a `poetry.lock` file if missing.

## 2. Check Lock: Ensuring Dependencies Are Locked

To check if `poetry.lock` exists and lock dependencies if necessary, use:

```sh
just check-lock
```

This will:
- Verify if `poetry.lock` is present.
- If not, it will run Poetry inside a Docker container to generate the lock file.

## 3. Install: Installing Dependencies

To install dependencies using Poetry, run:

```sh
just install
```

This will:
- Create a virtual environment.
- Install dependencies inside the virtual environment.
- Ensure correct ownership of the `.venv` folder.

## 4. Config: Environment Configuration

Environment variables are managed through `.env` files:
- `.env` for local development.
- `.env.<mode>` for other environments (`development`, `testing`, `staging`, `production`).

Ensure the correct `.env` file exists before running the project.

## 5. Share: Exposing Local Development for External Access

To share the local development environment for external access, use:

```sh
just share
```

This will:
- Expose the local development server to the internet.
- Allow external users to access the running application for demo purposes.

## Next Steps

- [Local Development Guide](local-development.md)
- [Deployment Guide](deployment.md)

