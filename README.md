# FastAPI Boilerplate

FastAPI Boilerplate is a structured and scalable template for developing FastAPI applications. It includes essential configurations for local development, testing, and deployment using Docker.

## Features

- 🏗 **Modular architecture** for scalable and maintainable FastAPI projects.
- 🐳 **Docker-based development** for consistency across environments.
- 🛠 **Built-in linting and testing** tools to ensure code quality.
- 🚀 **Optimized deployment process** with Docker Compose and containerized builds.

## Getting Started

To get started with the project, refer to the following documentation:

## 🚀 Installation

```sh
git clone https://github.com/laragis/fastapi-boilerplate.git
cd fastapi-boilerplate
```

## 📂 Project Structure

```sh
fastapi-boilerplate
├── CHANGELOG.md
├── CONTRIBUTORS.md
├── Dockerfile
├── docker-compose.production.yaml
├── docker-compose.yaml
├── entrypoint.sh
├── justfile
├── poetry.lock
├── pyproject.toml
├── LICENSE
├── README.md
├── app
│   ├── main.py
│   ├── configs.py
│   ├── controllers
│   │   └── geofencing_controller.py
│   ├── middlewares
│   │   └── cors_middleware.py
│   ├── models
│   │   └── geofencing_models.py
│   ├── services
│   │   └── geofencing_services.py
│   └── utils
│       ├── lifespan.py
│       └── transformer.py
├── docs
│   ├── DEPLOYMENT.md
│   ├── LOCAL-DEVELOPMENT.md
│   └── SETUP.md
├── scripts
│   ├── build.sh
│   ├── lint.sh
│   └── test.sh
└── tests
    ├── controllers
    │   └── test_geofencing_controller.py
    └── services
        └── test_geofencing_services.py
```

### 📖 Documentation

- [Setup Guide](docs/setup.md) - Instructions to initialize and configure the project.
- [Local Development Guide](docs/local-development.md) - Steps to set up a development environment.
- [Deployment Guide](docs/deployment.md) - Guide to deploying the application in production.
