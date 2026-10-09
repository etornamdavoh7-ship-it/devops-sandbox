# Stage 20: Monitoring Infrastructure & Orchestration

## Goal
To deploy the monitoring tools (Prometheus and Grafana) alongside our main application using Docker Compose, establishing the "Collectors" and "Visualization" tiers of our Observability stack.

## What We Did (Phase 2)

### 1. Updated Docker Compose
We added two new services to our `docker-compose.yml` file:
* **Prometheus (`prom/prometheus:latest`):** The scraper that fetches metrics from our Node.js backend. Exposed on port `9090`.
* **Grafana (`grafana/grafana:latest`):** The visualization dashboard. Exposed on port `3001` to avoid conflicting with the React frontend on `3000`.

### 2. The Prometheus "Phonebook"
Prometheus requires a configuration file to know what to scrape. We created `./prometheus/prometheus.yml`:
```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "devops-sandbox-backend"
    static_configs:
      - targets: ["backend-api:5000"]
```
* **Internal DNS:** Notice that we used `backend-api:5000` instead of `localhost`. Because Prometheus and the Node app share the same Docker network, Prometheus can resolve the container's name directly via internal DNS, bypassing the host machine entirely.

### 3. Docker Volumes vs. Custom Images
To pass the `prometheus.yml` file into the Prometheus container, we used a Docker Volume mount:
`./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml`

* **Best Practice Note:** Volume mounts are perfect for local development and basic EC2 deployments (where the repo is cloned to the host). However, for advanced cloud deployments (like AWS ECS Fargate or Kubernetes), DevOps engineers usually build a custom Docker image (`COPY prometheus.yml /etc/prometheus/prometheus.yml`) to "bake" the config directly into the container so it can run anywhere without local file dependencies.

### 4. Grafana Security Considerations
We passed the Grafana admin password via an environment variable in the compose file:
`GF_SECURITY_ADMIN_PASSWORD=admin`

* **Security Warning:** Hardcoding plaintext passwords in a Git-tracked file is a severe security violation. We did this purely to bypass the initial setup screen in our local sandbox.
* **The Fix:** In production, this must be passed securely via a `.env` file (e.g., `GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}`) or AWS Secrets Manager. Alternatively, enterprises disable passwords entirely and use OIDC (Single Sign-On) like GitHub OAuth.

### 5. The `--build` Flag (CRITICAL STEP)
Because we modified the application's source code in Stage 19 (editing `server.js` and adding `prom-client` to `package.json`), we could not simply run `docker compose up -d`. 

Docker caches images to save time. If we had run the standard command, Docker would have used the old Node.js image that did not contain our Prometheus tripwires.

* **The Command:** `docker compose up -d --build`
* **Why:** The `--build` flag forces Docker to run `npm install` and rebuild the `backend-api` container from scratch before launching the network, ensuring our monitoring code is included.
