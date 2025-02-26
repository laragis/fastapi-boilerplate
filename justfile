
# Load environment variables from .env file

# export ENV := env('ENV', '')
# export ENV_FILE := if "$ENV" == "" { ".env" } else { ".env.$ENV" }

# set dotenv-filename := shell('if [ -z "$ENV" ]; then echo ".env"; else echo ".env.$ENV"; fi')
# set dotenv-load

# Specify the default Docker Compose file
COMPOSE_FILE := if "$ENV" == "" { "docker-compose.yaml" } else { "docker-compose.$ENV.yaml" }

[positional-arguments]
env +args:
  #!/usr/bin/env sh
  mode=$1
  valid_modes="production staging local"
  if echo "$valid_modes" | grep -wq "$mode"; then
    shift 1
    just --dotenv-filename .env.$mode $@
  else
    just --dotenv-filename .env $@
  fi
  
@test:
  echo "Hello $APP_ENV"

# Default command to list all available commands.
default:
    @just --list

# build: Build Docker images.
@build:
  echo "🔨 Building Docker images..."
  docker compose -f {{COMPOSE_FILE}} build

# up: Start up all containers.
@up:
  echo "🚀 Starting up containers..."
  docker compose -f {{COMPOSE_FILE}} up -d --remove-orphans

# down: Stop all running containers.
@down:
  echo "🛑 Stopping containers..."
  docker compose -f {{COMPOSE_FILE}} down

# prune: Remove all stopped containers and unused volumes.
@prune:
  echo "🗑️  Removing containers and volumes..."
  docker compose -f {{COMPOSE_FILE}} down -v

# shell: Open a shell inside the running container.
@shell *args:
  echo "🐚 Opening a shell inside the container..."
  if [ -n "{{args}}" ]; then \
    docker compose -f {{COMPOSE_FILE}} exec --user={{args}} $APP_SERVICE bash; \
  else \
    docker compose -f {{COMPOSE_FILE}} exec $APP_SERVICE bash; \
  fi

# exec: Execute a command inside a running container.
@exec +args:
  echo "💻 Executing command inside container..."
  docker compose -f {{COMPOSE_FILE}} exec $APP_SERVICE {{args}}

# logs: View container logs.
@logs *args:
  echo "📜 Fetching logs..."
  docker compose -f {{COMPOSE_FILE}} logs -f {{args}}

# push: Push Docker images to registry.
@push *args:
  echo "📤 Pushing images to registry..."
  if [ "{{args}}" = "latest" ]; then \
    docker tag ${ORG_NAME}/${APP_SLUG}:${APP_VERSION} ${ORG_NAME}/${APP_SLUG}:latest; \
    docker push ${ORG_NAME}/${APP_SLUG}:latest; \
  else \
    docker push $ORG_NAME/$APP_SLUG:$APP_VERSION; \
  fi 

@lock:
  docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/app" \
    -w /app \
    ttungbmt/python:3.11 \
    poetry lock