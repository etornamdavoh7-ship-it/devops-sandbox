# Stage 21: Visualization & ChatOps (Slack Alerts)

## Goal
To connect the Prometheus scraper to the Grafana dashboard, visualize the Application Golden Signals, and establish a real-time Incident Response pipeline using Slack Webhooks.

## What We Did (Phase 3)

### 1. Connecting the Data Source
We logged into Grafana and added Prometheus as the default Data Source. 
* **The Configuration:** Instead of using `localhost`, we used the internal Docker DNS URL: `http://prometheus:9090`. This ensures that even if this stack is deployed to an AWS ECS cluster, Grafana can always find Prometheus securely within its own private network.

### 2. Creating the Golden Signals Dashboard
We built a dashboard panel to monitor **Traffic** and **Errors** (Two of the Four Golden Signals).
* **The PromQL Query:** `sum(rate(http_requests_total[1m])) by (status_code)`
* **Why this matters:** This single query plots different colored lines for successful requests (`200 OK`) and failed requests (`500 Internal Server Error`). It provides an instant visual indicator of application health.

### 3. Integrating Slack (ChatOps)
DevOps engineers don't stare at dashboards all day; they rely on push notifications. We configured Grafana to send messages to a Slack workspace.
* **The Webhook:** We generated an Incoming Webhook URL in the Slack API portal. This URL acts as a secure "key" allowing Grafana to post messages into a specific channel.
* **The Contact Point:** We created a new Contact Point in Grafana named `Slack Alerts` and pasted the Webhook URL.
* **The Routing:** We updated Grafana's Default Notification Policy to route all alerts to Slack instead of the default email system.

### 4. Designing the Alert Rule
We created an Alert Rule named `Database Crash (500 Errors)` completely independent of the dashboard (a modern Grafana feature).
* **The Tripwire Query:** `sum(rate(http_requests_total{status_code="500"}[1m]))`
* **The Condition:** Trigger when the value is `> 0`.
* **The Pending Period:** `1m`. This is crucial for avoiding "Alert Fatigue." If a 500 error happens once and recovers immediately (a 1-second blip), the alert stays in a Yellow "Pending" state and self-resolves. It only turns Red "Firing" and pings Slack if the outage lasts for an entire minute.
