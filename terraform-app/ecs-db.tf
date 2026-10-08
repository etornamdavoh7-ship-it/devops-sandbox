resource "aws_ecs_task_definition" "db" {
  family                   = "devops-sandbox-db"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "mongodb"
      image     = "mongo:7.0"
      essential = true
      portMappings = [
        {
          containerPort = 27017
          hostPort      = 27017
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.db_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

}


resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "devops.local"
  description = "Private DNS namespace for ECS microservices"
  vpc         = aws_vpc.devops_sandbox_vpc.id

}

resource "aws_service_discovery_service" "db" {
  name = "mongodb"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id
    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "db" {
  name            = "devops-sandbox-db"
  cluster         = aws_ecs_cluster.devops_sandbox_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.db.arn
  desired_count   = 1

  network_configuration {
    subnets = [
      aws_subnet.sandbox_private_subnet_2a.id,
      aws_subnet.sandbox_private_subnet_2b.id
    ]
    security_groups  = [aws_security_group.devops_sandbox_db_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.db.arn
  }
}