output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.devops_sandbox_vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value = [
    aws_subnet.sandbox_public_subnet_1a.id,
    aws_subnet.sandbox_public_subnet_1b.id
  ]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value = [
    aws_subnet.sandbox_private_subnet_1a.id,
    aws_subnet.sandbox_private_subnet_1b.id,
    aws_subnet.sandbox_private_subnet_2a.id,
    aws_subnet.sandbox_private_subnet_2b.id
  ]
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.devops_sandbox_alb_sg.id
}

output "app_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.devops_sandbox_app_sg.id
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.devops_sandbox_db_sg.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.devops_sandbox_alb.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the ALB. The canonical hosted zone ID is required for creating Route 53 alias records."
  value       = aws_lb.devops_sandbox_alb.zone_id
}

output "frontend_target_group_arn" {
  description = "The ARN of the frontend target group"
  value       = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  description = "The ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}

output "frontend_ecr_repository_url" {
  description = "The URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "The URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.devops_sandbox_cluster.name
}

output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.internal.id
}

output "mongodb_internal_url" {
  value = "${aws_service_discovery_service.db.name}.${aws_service_discovery_private_dns_namespace.internal.name}"
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.devops_sandbox_cluster.arn
}

output "ecs_frontend_service_name" {
  value = aws_ecs_service.frontend.name
}

output "ecs_backend_service_name" {
  value = aws_ecs_service.backend.name
}

output "ecs_db_service_name" {
  value = aws_ecs_service.db.name
}

output "mongo_uri_ssm_arn" {
  value = aws_ssm_parameter.mongo_uri.arn
}