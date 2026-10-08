# Stage 1.5: Elastic Container Registry (ECR)

## Goal
Create a highly secure, private storage location (a "warehouse") within our AWS environment to store the built Docker images for our frontend and backend applications.

## Core Concepts

* **ECR (Elastic Container Registry):** AWS's fully managed Docker container registry. It replaces the need for a public registry like Docker Hub, keeping our proprietary code strictly within our AWS account boundaries.
* **The Hand-Off Point:** ECR acts as the middleman between our Continuous Integration (CI) and Continuous Deployment (CD). 
  * **GitHub Actions** builds the Docker image and pushes it to ECR.
  * **AWS ECS** pulls the Docker image from ECR to run it.
* **Image Tag Mutability (`MUTABLE`):** Allows us to overwrite existing Docker tags (like `latest`). While strict production environments often use `IMMUTABLE` to prevent accidental overwrites, `MUTABLE` is preferred for our CI/CD sandbox pipeline.
* **Image Scanning (`scan_on_push`):** ECR acts as a security guard. The moment an image is pushed to the repository, AWS automatically scans the operating system and packages inside the container for known vulnerabilities (CVEs).
* **Force Delete (`force_delete = true`):** A critical configuration for sandbox/development environments. It allows Terraform to destroy the ECR repository even if it contains Docker images, preventing manual cleanup overhead during a `terraform destroy`.

## Architecture Flow

```mermaid
flowchart LR
    GH[GitHub Actions\n(CI)] -->|docker push| ECR[(Amazon ECR\nDocker Registry)]
    ECR -->|docker pull| ECS[Amazon ECS\n(Fargate)]
```

## Outputs
We exposed the `repository_url` for both the frontend and backend registries. 
* **Why:** GitHub Actions needs the exact URL of these repositories so it knows the specific destination to push the built Docker images during the CI/CD pipeline.
