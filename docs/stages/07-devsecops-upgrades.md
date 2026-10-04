# Stage 7: Advanced DevSecOps Upgrades

Building a basic CI pipeline is only the first step. To make a pipeline truly enterprise-grade, it must be **Deterministic, Predictable, and Deeply Secure**. 

Here are the three advanced DevSecOps upgrades we applied to our pipeline.

## 1. Deterministic Builds (`npm ci`)
A common rookie mistake is using `RUN npm install` inside a Dockerfile. `npm install` evaluates package version ranges and may install a newer version of a library than what you tested on your laptop. This means a container built on Tuesday could behave differently than a container built on Friday.

**The Fix:** We replaced it with `RUN npm ci` (Clean Install). 
* `npm ci` ignores `package.json` and strictly reads `package-lock.json`. 
* It installs the exact, byte-for-byte identical dependencies that were tested locally, guaranteeing that the Docker container is a 100% deterministic mirror of your secure local environment.

## 2. Predictable Artifacts (Docker Compose)
By default, when you run `docker compose build`, Docker auto-generates ugly, unpredictable names for your images (e.g., `devops-sandbox_backend-api_1`). This makes it nearly impossible to tell an automated security scanner which image to scan.

**The Fix:** We explicitly tagged our images in `docker-compose.yml`:
```yaml
  backend-api:
    build: ./server
    image: devops-sandbox-backend:local
```
This gives our CI pipeline a reliable, predictable target artifact.

## 3. The Dual-Scan Strategy (Filesystem + Image)
Our initial pipeline only scanned the filesystem. While that catches NPM vulnerabilities, it misses critical OS-level flaws. We upgraded Trivy to perform a **Dual-Scan**:

1. **Filesystem Scan (`scan-type: 'fs'`):** Scans the `package-lock.json` in the repository to ensure no vulnerable application dependencies (like Express or Mongoose) are deployed.
2. **Container Scan (`scan-type: 'image'`):** Scans the actual compiled Docker images (`devops-sandbox-backend:local` and `devops-sandbox-frontend:local`) to catch critical vulnerabilities inside the underlying Linux OS (like Alpine or Nginx flaws).

### The Upgraded YAML Block:
```yaml
      # 1. SCAN REPOSITORY FILESYSTEM (App Dependencies)
      - name: Run Trivy Filesystem Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'table'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'

      # 2. BUILD IMAGES
      - name: Build Application Containers
        run: docker compose build

      # 3. SCAN OS CONTAINER IMAGE (OS Vulnerabilities)
      - name: Run Trivy on Backend Container
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'image'
          image-ref: 'devops-sandbox-backend:local'
          format: 'table'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'
```
