resource "aws_ecs_cluster" "devops_sandbox_cluster" {
  name = "devops-sandbox-cluster"
}

resource "aws_cloudwatch_log_group" "frontend_logs" {
  name              = "/ecs/devops-sandbox-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "backend_logs" {
  name              = "/ecs/devops-sandbox-backend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "db_logs" {
  name              = "/ecs/devops-sandbox-db"
  retention_in_days = 7
}