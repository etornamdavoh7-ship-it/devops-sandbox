# Stage 19: Application Monitoring & Instrumentation

## Goal
To implement Layer 2 "Application Monitoring" (The Four Golden Signals) by instrumenting the Node.js backend with Prometheus metrics.

## What We Did (Phase 1)
Instead of relying purely on infrastructure metrics (CPU/RAM), we modified the application's core logic to report its own health. We used the "Tripwire" methodology to track every incoming HTTP request.

### 1. Installed the Client
We installed `prom-client` in the Node.js backend to allow the application to generate Prometheus-formatted metrics.

### 2. Initialized Default Metrics
We added `promClient.collectDefaultMetrics()` to automatically track Layer 1 infrastructure data from within the Node container (e.g., Node.js event loop lag, memory heap, CPU time).

### 3. Created the Tripwire (Global Middleware)
We instantiated a custom Prometheus Counter (`http_requests_total`) and injected a global Express middleware:
```javascript
app.use((req, res, next) => {
  res.on("finish", () => {
    httpRequestCounter.inc({
      method: req.method,
      route: req.path,
      status_code: res.statusCode,
    });
  });
  next();
});
```
*Why this matters:* This tracks the **Traffic** (Total requests) and **Errors** (Status Codes) of Google's Four Golden Signals.

### 4. Exposed the `/metrics` Endpoint
We opened a dedicated route (`/metrics`) that serves as the pickup location. When Prometheus scrapes this URL, the server responds with a giant wall of text containing the current value of the counters.

## The Environment Variable "Gotcha"
When attempting to test the new `/metrics` endpoint locally via `npm run dev`, the application crashed with a `FATAL ARCHITECTURE ERROR: MONGO_URI is not defined!`.
* **The Lesson:** In a modern DevOps architecture, applications rely on the Orchestrator (like Docker Compose or Kubernetes) to inject their environment variables. Running an app "naked" on the host machine will trigger its fail-safe mechanisms. 
* **The Fix:** The app must be tested by spinning up the entire stack using `docker compose up`.
