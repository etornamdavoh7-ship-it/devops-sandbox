# Stage 1.6: Identity and Access Management (IAM)

## Goal
Securely grant our ECS containers the exact permissions they need to operate in AWS, following the principle of least privilege, without hardcoding any access keys or passwords.

## Core Concepts

* **IAM Roles (The "Badge"):** A temporary identity that an AWS service can assume. It doesn't have a static password; AWS generates temporary security tokens dynamically.
* **Trust Policy (`assume_role_policy`):** The "Bouncer". This dictates *who* or *what* is allowed to put on the IAM role. For our containers, we restrict this strictly to the AWS ECS service (`ecs-tasks.amazonaws.com`).
* **Policy Attachments:** The actual permissions stamped onto the badge. We used an AWS Managed Policy (`AmazonECSTaskExecutionRolePolicy`), which means AWS automatically maintains the list of permissions required for basic ECS tasks.

## The Two ECS Roles

AWS ECS separates container permissions into two distinct roles. This separation of concerns is a standard enterprise security question.

1. **ECS Task Execution Role (The "Setup" Badge)**
   * **Who wears it:** The underlying AWS ECS infrastructure agent.
   * **What it does:** It is used *before* the container starts. It grants ECS permission to authenticate to ECR (to `docker pull` our images) and permission to stream the container's standard output (`console.log`) directly to AWS CloudWatch Logs.
2. **ECS Task Role (The "App" Badge)**
   * **Who wears it:** The actual running application code inside the container (Node.js or React).
   * **What it does:** It allows the application to securely talk to other AWS services. For example, if the Node backend needed to upload user avatars to an S3 bucket, or read records from DynamoDB, those permissions would be attached to this role. 

## Outputs
We exposed the ARNs (Amazon Resource Names) for both roles. In a real-world enterprise, the Security/IAM team builds these roles in a separate Terraform module. The Application team needs these ARNs outputted so they can securely attach them to their ECS cluster definitions.
