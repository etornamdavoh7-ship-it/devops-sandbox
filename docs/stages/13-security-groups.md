# Stage 13: The 3-Tier Security Model

## Goal
Now that the physical subnets are built (Stage 12), we need to wrap them in invisible, stateful firewalls (Security Groups). Our goal is to implement the principle of **Least Privilege** by creating a strict "Chain of Trust."

---

## 1. The Architecture: The Chain of Trust
To achieve military-grade network isolation, we built three distinct Security Groups. Traffic is only allowed to flow sequentially; no tier is allowed to skip a step.

### Tier 1: The ALB (The Front Door)
* **Ingress**: Allows Port `80` (HTTP) from the entire internet (`0.0.0.0/0`). 
* **Role**: This is the only resource in our entire AWS environment that the public internet is allowed to touch.

### Tier 2: The App / ECS Containers (The Brains)
* **Ingress**: Allows Ports `3000` (React) and `5000` (Node.js).
* **Security Rule**: We completely blocked `0.0.0.0/0`. Traffic is *only* accepted if it originates directly from the ALB Security Group. If a bad actor discovers the private IP of our container, their requests will be instantly dropped because they didn't pass through the Load Balancer first.

### Tier 3: The Database (The Vault)
* **Ingress**: Allows Port `27017` (MongoDB).
* **Security Rule**: Traffic is *only* accepted if it originates from the App Security Group. The Load Balancer cannot talk to the DB, and the Internet cannot talk to the DB.

---

## 2. Terraform Implementation Best Practice
To enforce this Chain of Trust in Terraform, we did not use hardcoded IP addresses or CIDR blocks for the internal tiers. Instead, we dynamically referenced the Security Group IDs.

**Example: The App Security Group Ingress Rule**
```terraform
  ingress {
    description     = "React Frontend"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    # This is the magic line that creates the Chain of Trust:
    security_groups = [aws_security_group.devops_sandbox_alb_sg.id]
  }
```

## 3. Centralized File Structure
We placed all three Security Groups in a single `security.tf` file. Because Security Groups heavily reference one another, keeping them in a centralized "Security Hub" file makes auditing the firewall rules and tracing the dependencies significantly easier than scattering them across network and application files.
