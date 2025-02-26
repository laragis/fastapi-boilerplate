ifneq (,$(wildcard .env))
    ENV_FILE := .env
else ifneq (,$(wildcard .env.example))
    ENV_FILE := .env.example
else
    $(error "Neither .env nor .env.example file exists!")
endif

include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))

# Set variables to pass
APP := fastapi

up:
	docker compose up -d $(APP)

shell:
	docker compose exec --user=1000 $(APP) bash

shell-root:
	docker compose exec --user=root $(APP) bash

down:
	docker compose down $(APP)

down-v:
	docker compose down -v $(APP)

build:
	docker buildx build \
		--tag ${ORG_NAME}/${APP_SLUG}:${APP_VERSION} \
		--build-arg BASE_IMAGE=${BASE_IMAGE} \
		--build-arg TZ=${TZ} \
		--build-arg APP_PORT=${APP_PORT} \
		--target development \
		.

push:
	docker push ${ORG_NAME}/${APP_SLUG}:${APP_VERSION}

push-latest:
	docker tag ${ORG_NAME}/${APP_SLUG}:${APP_VERSION} ${ORG_NAME}/${APP_SLUG}:latest
	docker push ${ORG_NAME}/${APP_SLUG}:latest

push-all: push push-latest

lock:
	docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/app" \
    -w /app \
    ttungbmt/python:3.11 \
    poetry lock
