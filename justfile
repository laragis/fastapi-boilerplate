# 🛠️ Set positional arguments for Justfile.
set positional-arguments

set dotenv-path := "./"

# 🎯 Define aliases for different environments to make calling them easier.
alias dev := development
alias test := testing
alias stag := staging
alias prod := production

# 🏗️ Set the default environment mode (change this value as needed).
mode := "local"

# 📄 Define the environment file based on the selected mode.
# If running in local mode, use `.env`, otherwise use `.env.<mode>`
ENV_FILE := if mode == 'local' { ".env" } else { ".env." + mode }

# 🏗️ Define the Docker Compose file based on the selected mode.
# If running in local mode, use `docker-compose.yaml`,
# Otherwise, use `docker-compose.<mode>.yaml`
COMPOSE_FILE := if mode == 'local' { "docker-compose.yaml" } else { "docker-compose." + mode + ".yaml" }

# 🛠️ Build the Docker Compose command options.
# This combines the compose file and the environment file dynamically.
COMPOSE_OPTIONS := "-f " + COMPOSE_FILE + " --env-file " + ENV_FILE

export SHARE_TOKEN := "b392681b-93dd-4a5a-9ee6-03e656d89be3"
export SHARE_DASHBOARD := "4040"

# 📜 Default command to list all available commands when running `just` without arguments.
default:
  @just --list

# 🚀 Local environment target.
@local +args:
  check-env $0
  echo "🚀 Running on **Local** environment. This is your personal development machine. 🛠️"
  just --dotenv-filename .env mode=$0 {{args}}

# 👨‍💻 Development environment target.
@development +args:
  check-env $0
  echo "👨‍💻 Running on **Development** environment. Used for coding, debugging, and integration. 🔧"
  just --dotenv-filename .env.$0 mode=$0 {{args}}

# 🧪 Testing environment target.
@testing +args:
  check-env $0
  echo "🧪 Running on **Testing** environment. Used for QA and automated tests. ✅"
  just --dotenv-filename .env.$0 mode=$0 {{args}}

# 📦 Staging environment target.
@staging +args:
  check-env $0
  echo "📦 Running on **Staging** environment. Mirrors production for final verification. 🔄"
  just --dotenv-filename .env.$0 mode=$0 {{args}}

# 🌍 Production environment target.
@production +args:
  check-env $0
  echo "🌍 Running on **Production** environment. Live system used by real users. ⚡"
  just --dotenv-filename .env.$0 mode=$0 {{args}}

# 🌱 Initialize the app 
init:
  #!/usr/bin/env bash
  if [ ! -f {{ENV_FILE}} ]; then
    cp .env.example {{ENV_FILE}}
    sed -i 's/^APP_ENV=local$/APP_ENV={{mode}}/' {{ENV_FILE}}
  fi 
  just check-lock

install *args:
  #!/usr/bin/env bash
  uid=$(id -u)
  gid=$(id -g)

  docker run --rm -it \
    -v "$(pwd):/app" \
    -w /app \
    ttungbmt/python:3.11 \
    bash -c "python -m venv --copies .venv && poetry install --no-root {{args}} && chown -R $uid:$gid .venv"

# 🏗️ Build Docker images
@build *args:
  echo "🔨 Building Docker images..."
  docker compose {{COMPOSE_OPTIONS}} build {{args}}

# 🚀 Start up Docker containers
@up *args:
  echo "🚀 Starting up containers..."
  docker compose {{COMPOSE_OPTIONS}} up -d --remove-orphans {{args}}

# 🛑 Stop and remove running containers
@down *args:
  echo "🛑 Stopping containers..."
  docker compose {{COMPOSE_OPTIONS}} down {{args}}

# 🗑️  Stop containers and remove volumes
@prune *args:
  echo "🗑️ Removing containers and volumes..."
  docker compose {{COMPOSE_OPTIONS}} down  -v {{args}}

# 🐚 Open a shell inside a running container
@shell *args:
  echo "🐚 Opening a shell inside the container..."
  if [ -n "{{args}}" ]; then \
    docker compose {{COMPOSE_OPTIONS}} exec --user={{args}} $APP_SERVICE bash; \
  else \
    docker compose {{COMPOSE_OPTIONS}} exec $APP_SERVICE bash; \
  fi

# 💻 Execute a command inside a running container
@exec +args:
  echo "💻 Executing command inside container..."
  docker compose {{COMPOSE_OPTIONS}} exec $APP_SERVICE {{args}}

# 📜 Fetch and follow logs from containers
@logs *args:
  echo "📜 Fetching logs..."
  docker compose {{COMPOSE_OPTIONS}} logs -f {{args}}

# 📤 Push Docker images to a container registry
@push *args:
  echo "📤 Pushing images to registry..."
  if [ "{{args}}" = "latest" ]; then \
    docker tag ${ORG_NAME}/${APP_SLUG}:${APP_VERSION} ${ORG_NAME}/${APP_SLUG}:latest; \
    docker push ${ORG_NAME}/${APP_SLUG}:latest; \
  else \
    docker push $ORG_NAME/$APP_SLUG:$APP_VERSION; \
  fi

# 🌍 Share the local application via Expose 
share:
  #!/usr/bin/env bash
  docker run \
    --init --rm --add-host=host.docker.internal:host-gateway -p "$SHARE_DASHBOARD":4040 -t beyondcodegmbh/expose-server:latest \
    share http://host.docker.internal:"$APP_FORWARD_PORT" --auth="$SHARE_TOKEN"

check-env mode:
  #!/usr/bin/env bash
  env_file=$([ mode = "local" ] && echo ".env" || echo ".env.{{mode}}")
  if [ ! -f "$env_file" ]; then
    echo "❌ '$env_file' does not exist. Aborting."
    exit 1
  fi

# 🔒 Generate or update the `poetry.lock` file
check-lock:
  #!/usr/bin/env bash
  if [ ! -f poetry.lock ]; then
    echo "🔒 Locking dependencies with Poetry..."
    docker run --rm \
      -u "$(id -u):$(id -g)" \
      -v "$(pwd):/app" \
      -w /app \
      ttungbmt/python:3.11 \
      poetry lock
  fi