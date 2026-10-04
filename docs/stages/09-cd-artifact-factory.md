# Stage 9: Continuous Delivery (CD) & The Artifact Factory

While Continuous Integration (CI) is the "Bouncer" that tests code, Continuous Delivery (CD) is the "Factory". Its job is to take approved code, package it into a runnable format, and store it securely so it can be deployed at any time.

## The Objective
We created a new workflow (`release.yml`) that only triggers when code is merged into `main`. This prevents us from wasting server resources building Docker images for unapproved feature branches.

## The 3 Rules of Enterprise CD

### 1. Immutable Tagging (`${{ github.sha }}`)
Never rely solely on the `latest` tag in production. Our pipeline tags every Docker image with the exact 40-character Git Commit ID (SHA). 
If a production server crashes, you can look at the running container and instantly trace it back to the exact line of code that caused the bug.

### 2. Passwordless Authentication (Native Tokens)
Instead of creating a Docker Hub account and hardcoding a password into GitHub Secrets, we used GitHub Container Registry (GHCR). By using `${{ secrets.GITHUB_TOKEN }}`, GitHub provisions a temporary, highly secure password that expires the moment the pipeline finishes. 

### 3. Dedicated Artifact Storage (The Warehouse)
The output of a CD pipeline must be a physical artifact. In our case, the CI pipeline generated two artifacts:
* `devops-sandbox/backend`
* `devops-sandbox/frontend`

These are now securely stored under the "Packages" tab on GitHub. They are frozen in time, containing exactly the code, dependencies, and OS libraries that our CI pipeline verified.

## The Code (`release.yml`)
```yaml
name: CD Release Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-and-push:
    name: Build and Push Docker Images
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry (GHCR)
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and Push Backend
        uses: docker/build-push-action@v5
        with:
          context: ./server
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/backend:${{ github.sha }}
            ghcr.io/${{ github.repository }}/backend:latest

      - name: Build and Push Frontend
        uses: docker/build-push-action@v5
        with:
          context: ./client
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/frontend:${{ github.sha }}
            ghcr.io/${{ github.repository }}/frontend:latest
          build-args: |
            VITE_API_URL=http://localhost:5000/api
```
