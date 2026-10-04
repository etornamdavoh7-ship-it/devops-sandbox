# Stage 10: Cloud Identity, Secrets, & Integration Testing

Before we deploy to the cloud, we must firmly establish the boundaries between **Pipeline responsibilities** and **Application responsibilities**, particularly regarding secrets and testing.

## 1. The Two Domains of Secrets
A common DevOps mistake is mixing up pipeline credentials with application credentials. They must be kept strictly separated.

### A. Pipeline Secrets (What the Robot Needs)
The CI/CD robot only needs credentials to build code and push it to storage/cloud. It should **never** know your production database password.
* **For 3rd-Party APIs (e.g., Docker Hub, Slack):** We use traditional **GitHub Secrets**.
* **For Cloud Providers (e.g., AWS, GCP):** We use **OIDC (OpenID Connect)**. Hardcoding AWS Access Keys in GitHub is an extreme security risk. OIDC acts as a "Secret Handshake" where GitHub requests a temporary, 15-minute VIP pass to deploy the infrastructure, which then evaporates.

### B. Application Secrets (What Node.js Needs)
Your application needs credentials to function (e.g., `MONGO_URI`, Stripe API Keys).
* **The Solution:** We use Cloud Native Secret Managers (like **AWS SSM Parameter Store** or AWS Secrets Manager). 
* When the Docker container boots up inside the AWS Cloud, it reaches into the AWS vault, grabs the `.env` variables, and connects to the database. GitHub is completely bypassed.

## 2. End-to-End (E2E) Integration Testing in CI
How do we know the database connection works before deploying to the cloud if the Pipeline doesn't have the production database password?

**We use GitHub Service Containers.**
If your developers write automated tests (like Jest or Cypress), we add a testing job to the `ci.yml` (The Bouncer) pipeline:
1. The GitHub Runner spins up a temporary, throwaway MongoDB container right next to the Node.js container.
2. We inject a *fake* `.env` file (e.g., `MONGO_URI=mongodb://localhost/test`) just for the GitHub Runner.
3. The automated tests run against the temporary database.
4. If they pass, the database is immediately deleted, and the approved Node.js Docker image is pushed to the CD pipeline.

This guarantees the application's logic works without ever risking production data.

---
*Note: In the next step, we will actively configure the OIDC handshake between GitHub and our Cloud Provider.*
