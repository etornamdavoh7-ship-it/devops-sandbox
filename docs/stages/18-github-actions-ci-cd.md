# Stage 18: GitHub Actions CI/CD Pipelines

## 1. Overview
In a modern DevOps environment, we want to automate the testing, provisioning, and deployment of our infrastructure and applications. We achieve this using **GitHub Actions**.

Our pipeline is split into three main workflows located in `.github/workflows/`:
1. **CI Pipeline (`ci.yml`)**: Runs on Pull Requests to validate code before it gets merged.
2. **Deploy Pipeline (`deploy.yml`)**: Runs on merges/pushes to the `main` branch to provision infrastructure and deploy the application.
3. **Manual Pipeline (`terraform-manual.yml`)**: A fail-safe utility that allows us to manually run Terraform commands from the GitHub UI.

---

## 2. OIDC Authentication (The "Why")

### What is OIDC?
OIDC stands for **OpenID Connect**. It allows GitHub Actions to securely authenticate with AWS **without** using long-lived IAM Access Keys and Secret Keys.

### Why is this important?
- **Security**: Hardcoding IAM Access Keys in GitHub Secrets is a security risk. If they are leaked, an attacker has permanent access until the keys are rotated.
- **Short-Lived Credentials**: With OIDC, GitHub Actions requests temporary, short-lived security tokens from AWS STS (`sts:AssumeRoleWithWebIdentity`) for each job. Once the job finishes, the token expires.
- **Maintenance**: No need to manually rotate IAM keys every 90 days.

We configured our AWS account to trust GitHub's OIDC provider specifically for our repository. This is why we created the `terraform-bootstrap` directory earlier!

---

## 3. The CI Pipeline (`ci.yml`)
**Trigger**: Pull Request to `main`.

**Goal**: Validate our Terraform code before we allow it to be merged.
1. **Code Formatting (`terraform fmt -check`)**: Ensures all `.tf` files follow standard Terraform formatting.
2. **Validation (`terraform validate`)**: Checks for syntax errors and valid module configurations.
3. **Planning (`terraform plan`)**: Generates a speculative execution plan. It shows us *what* Terraform will change in AWS if the PR is merged, allowing reviewers to catch destructive changes before they happen.

---

## 4. The Deploy Pipeline (`deploy.yml`)
**Trigger**: Push/Merge to `main`.

**Goal**: Deploy the infrastructure and application to AWS.
This workflow consists of three main phases:

### Phase 1: Infrastructure Provisioning
- Authenticates with AWS via OIDC.
- Navigates to `terraform-app/`.
- Runs `terraform apply -auto-approve` to provision or update any infrastructure (VPC, ALB, ECS, etc.).

### Phase 2: Docker Build & Push
- Logs into AWS Elastic Container Registry (ECR).
- Builds the **Frontend** React app. Note: React environment variables (like `VITE_API_URL`) must be injected at *build-time* via GitHub Action secrets/vars so they are baked into the static assets.
- Builds the **Backend** Node.js app.
- Pushes both Docker images to their respective ECR repositories with a unique image tag (usually the Git commit SHA).

### Phase 3: ECS Deployment
- Uses the AWS CLI (`aws ecs update-service`) to force the ECS services to pull the latest Docker image from ECR and start new containers.
- The ECS backend container pulls runtime environment variables (like `MONGO_URI`) directly from AWS SSM Parameter Store on startup.

---

## 5. The Manual Pipeline (`terraform-manual.yml`)
**Trigger**: Manual trigger via `workflow_dispatch` in the GitHub Actions UI.

**Goal**: Provide a "break glass" utility to manage Terraform states outside the standard push/PR flow.
- Allows you to manually trigger a `plan`, `apply`, or `destroy`.
- Crucial for emergency tear-downs (e.g., stopping billing overnight by running `destroy`).

---

## Next Steps
Now that the pipelines are documented, the final step is to push our code up to GitHub to trigger the workflows and watch the magic happen!
