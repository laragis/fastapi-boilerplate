# Deployment Guide

## Preparing for Deployment

Before deploying, ensure:
- All required environment variables are set.
- The `.env.<mode>` file exists for the deployment environment (`staging`, `production`).

## 1. Build: Creating a Production-Ready Image

To build the Docker image for production, use:

```sh
just build
```

This will:
- Build a production-ready Docker image.
- Use the appropriate `.env.production` file.
- Optimize for deployment.

## 2. Push: Uploading the Image to Docker Hub

To push the built image to Docker Hub:

```sh
just push
```

This will:
- Tag the built image.
- Authenticate with Docker Hub.
- Upload the image to the registry.

## Checking Logs

To monitor logs for debugging:

```sh
just logs
```

This will:
- Stream logs from the running application container.
- Help diagnose issues in real time.

## Next Steps

- [Setup Guide](setup.md)
- [Local Development Guide](local-development.md)

