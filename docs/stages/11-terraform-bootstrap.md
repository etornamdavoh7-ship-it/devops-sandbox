# Stage 11: Terraform Bootstrap & Keyless OIDC

## Goal
Establish the foundational cloud infrastructure required for our CI/CD pipelines to securely deploy code to AWS. This must be done *before* we write any application infrastructure.

## The "Chicken and Egg" Problem
To deploy infrastructure via GitHub Actions, we need an S3 bucket to store Terraform state, and an OIDC IAM Role to authenticate. But we need Terraform to create those things! 
**Solution:** We created a one-time `terraform-bootstrap` directory and applied it locally using our personal AWS credentials. 

## 1. Remote State Backend
Terraform state (`.tfstate`) tracks the mapping between our code and real-world AWS resources. It contains plain-text secrets, so it must be secured.
* **S3 Bucket (`aws_s3_bucket`)**: We used the `random_id` provider to generate a globally unique bucket name.
* **Versioning**: Enabled on the S3 bucket to prevent data loss. If a state file gets corrupted, we can revert to a previous version in S3.
* **Encryption**: Enforced AES-256 Server-Side Encryption because state files contain sensitive data.
* **DynamoDB State Lock**: Created a table with a `LockID` string partition key. This prevents two GitHub Actions pipelines from running `terraform apply` simultaneously and corrupting the state.

## 2. Keyless OIDC (Identity Provider)
Instead of storing long-lived AWS Access Keys in GitHub Secrets (a massive security risk), we use OpenID Connect (OIDC).
* **The Bouncer (OIDC Provider):** AWS verifies the GitHub token's cryptographic signature. **Note:** Because a previous project already created the OIDC provider for this AWS account, we used a `data` block to reference it. Creating it twice would result in a `409 EntityAlreadyExists` error and a dangerous "split-brain" state.
* **The VIP Badge (IAM Role):** We created `github-actions-role` with `AdministratorAccess`.
* **The Guest List (Trust Policy):** We strictly bound the IAM Role so that it can **only** be assumed by `repo:etornamdavoh7-ship-it/devops-sandbox:*`. Any other repository trying to assume this role will be denied.

## Outputs Generated
* **State Bucket:** `devops-sandbox-terraform-state-96a110b7`
* **DynamoDB Table:** `devops-sandbox-state-locks`
* **Role ARN:** `arn:aws:iam::308916794074:role/github-actions-role`

## Next Steps
With the bootstrap complete, our future Application Terraform can now safely use the S3 backend, and our GitHub Actions `.yml` workflows can securely authenticate using the Role ARN.

## 💡 Pro-Tips for Enterprise Environments
* **Guaranteeing the Plan (`-out`)**: When running Terraform in strict production environments, someone might manually alter AWS between your `plan` and your `apply`. To guarantee Terraform only does exactly what you saw in the plan, save the blueprint to a file:
  1. `terraform plan -out=myplan.tfplan`
  2. `terraform apply myplan.tfplan` (If the environment changed, this will fail rather than doing something unexpected).
* **Dynamic OIDC Thumbprints (`tls_certificate`)**: In this sandbox, we hardcoded the GitHub certificate thumbprint. In a production environment, hardcoded thumbprints can break pipelines if GitHub rotates their certificates. The pro-level fix is to use the HashiCorp `tls` provider to fetch the thumbprint dynamically on the fly:
  ```terraform
  data "tls_certificate" "github" {
    url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
  }
  # Then in the OIDC provider (if creating it):
  # thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  ```
