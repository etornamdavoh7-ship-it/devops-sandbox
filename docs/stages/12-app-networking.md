# Stage 12: Application Networking & Remote State

## Goal
Connect our application infrastructure to the central Terraform state bucket we built in Stage 11, and provision a highly available, enterprise-grade 3-Tier Virtual Private Cloud (VPC).

---

## 1. The Remote Backend & State Locking
To achieve true CI/CD automation, Terraform cannot store its `.tfstate` memory locally on a developer's laptop. 

We created `terraform-app/providers.tf` and configured the `backend "s3"` block.
* **S3 Bucket**: Terraform now stores its memory in our encrypted cloud bucket.
* **DynamoDB Locking**: We attached the `devops-sandbox-state-locks` table. If two GitHub Action pipelines trigger at the exact same second, the second pipeline will see the DynamoDB lock and patiently wait. This prevents state file corruption and environment destruction.

---

## 2. The Enterprise 3-Tier Network (6 Subnets)
We provisioned `10.0.0.0/16` and split it into 6 distinct subnets to maximize logical separation and security across two Availability Zones (`1a` and `1b`):

1. **The Web Tier (Public Subnets)**: The "DMZ". The only resources here are the Application Load Balancer (ALB) and the NAT Gateway. They have direct access to the Internet Gateway.
2. **The App Tier (Private Subnets)**: Where our ECS Fargate Docker containers will live. They are completely invisible to the internet.
3. **The Data Tier (Private Subnets)**: For highly secure databases (e.g., RDS). 

### The NAT Gateway (The Escape Hatch)
Because the App Tier is strictly private, the containers cannot reach the internet to download Docker images from AWS ECR. We built a **NAT Gateway** (attached to an Elastic IP) in the Public Subnet. It acts as a proxy, safely fetching internet data for the private containers without exposing them to inbound attacks.

---

## 3. Route Tables & The `for_each` DRY Principle
Route Tables act as the traffic cops for our subnets.
* **Public Route Table**: Directs all outbound traffic (`0.0.0.0/0`) to the Internet Gateway.
* **Private Route Table**: Directs all outbound traffic (`0.0.0.0/0`) to the NAT Gateway.

### The `for_each` Masterclass
Normally, attaching 6 subnets to Route Tables requires writing 6 repetitive `aws_route_table_association` blocks. To adhere to the **DRY (Don't Repeat Yourself)** principle, we used a Terraform `for_each` map to drastically clean up the code.

**Example of our DRY Private Route Table Association:**
```terraform
resource "aws_route_table_association" "devops_sandbox_private_rt_assoc" {
  for_each = {
    "1a" = aws_subnet.sandbox_private_subnet_1a.id
    "1b" = aws_subnet.sandbox_private_subnet_1b.id
    "2a" = aws_subnet.sandbox_private_subnet_2a.id
    "2b" = aws_subnet.sandbox_private_subnet_2b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.devops_sandbox_private_rt.id
}
```
By iterating over the map, Terraform dynamically generates the 4 private associations with a single, elegant block of code.
