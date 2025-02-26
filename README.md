# FastAPI Boilerplate

## Steps

```shell
cp .env.example .env

docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/app" \
    -w /app \
    ttungbmt/python:3.11 \
    curl -sSL https://install.python-poetry.org | python3 - && poetry lock
```