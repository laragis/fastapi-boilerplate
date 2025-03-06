# Local Development Guide

## 1. Build: Building the Development Environment

To build the development environment, run:

```sh
just build
```

This will:

- Build the necessary Docker images.
- Prepare the environment for running the application.

## 2. Up: Starting the Development Environment

To start the development environment, run:

```sh
just up
```

This will:

- Start all required services using Docker Compose.
- Load configurations from `.env`.

## 2. Shell: Accessing the Development Environment

To open a shell session inside the running container, use:

```sh
just shell
```

This allows you to:
- Run commands inside the container.
- Interact with the FastAPI environment.
- Execute database operations if needed.

## 3. Exec: Running a Command Inside a Running Container

To execute a command inside the running application container, use:

```sh
just exec <command>
```

This will:

- Run the specified command inside the container.
- Use `docker compose exec` with the appropriate service.
- Ensure that the command runs in the correct application context.

## 4. Lint: Formatting and Linting Code

To format and lint the source code, use:

```sh
just linting-code
```

This will:
- Run `black`, `isort`, and `flake8` to enforce code style guidelines.
- Ensure consistency in the codebase.

## 5. Test: Running Unit and Integration Tests

To execute all tests, run:

```sh
just testing-code
```

This will:
- Run unit tests and integration tests using `pytest`.
- Ensure code correctness before deployment.

## 6. Down: Stopping the Development Environment

To stop the running containers, execute:

```sh
just down
```

This will:
- Stop and remove all running containers.
- Clean up associated networks and volumes.

## Next Steps

- [Setup Guide](setup.md)
- [Deployment Guide](deployment.md)