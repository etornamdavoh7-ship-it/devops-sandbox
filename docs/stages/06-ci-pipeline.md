# Stage 6: Continuous Integration (CI) Pipeline

## The Purpose of CI
A Continuous Integration (CI) pipeline acts as a "Ruthless Bouncer" at the door of your `main` branch. It automatically spins up an ephemeral (temporary) server to test your code, scan for security flaws, and ensure the application builds successfully before a human is allowed to merge the Pull Request.

## The Pipeline Code (`ci.yml`)
This YAML file lives strictly inside the `.github/workflows/` directory. 

```yaml
name: CI Pipeline

on:
  pull_request:
    branches:
      - main

jobs:
  security-scan:
    name: Run Gitleaks
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Scan for Secrets
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  build-and-scan:
    name: Docker Build and Trivy Scan
    runs-on: ubuntu-latest
    needs: security-scan
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build Application
        run: docker-compose build

      - name: Run Trivy Vulnerability Scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'table'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'
```

## Reusability Guide: How to Read the Code
When modifying or creating new pipelines, remember these 4 core concepts:

1. **`on:` (The Trigger)** 
   Determines *when* the robot wakes up. Common triggers are `pull_request`, `push`, or `schedule` (cron jobs).
2. **`jobs:` and `runs-on:` (The Server)**
   Every job runs on a brand new, empty Virtual Machine (e.g., `ubuntu-latest`). Jobs run in parallel by default to save time. Use `needs: <job_name>` to force them to run sequentially.
3. **`uses:` (Marketplace Actions)**
   You don't have to write bash scripts for everything. `uses:` allows you to pull in pre-built, open-source plugins from the GitHub Marketplace (like `actions/checkout` or `trivy-action`).
4. **`run:` (Custom Commands)**
   Allows you to execute standard Linux terminal commands (like `docker-compose build` or `npm install`) directly on the runner.

## Official References & Documentation
When building advanced pipelines, always refer to the official documentation for the plugins:
* [GitHub Actions Official Docs](https://docs.github.com/en/actions)
* [Checkout Action](https://github.com/actions/checkout)
* [Gitleaks Action](https://github.com/gitleaks/gitleaks-action)
* [Docker Buildx Action](https://github.com/docker/setup-buildx-action)
* [Trivy Action](https://github.com/aquasecurity/trivy-action)
